module sdram_top(
    input clk, rst_n,
    input [2:0] key,

    output [3:0] led,

    // FPGA to SDRAM
    output sdram_clk,
    output sdram_cke,
    output sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n,
    output [12:0] sdram_addr,
    output [1:0] sdram_ba,
    output [1:0] sdram_dqm,
    inout [15:0] sdram_dq
);

    localparam idle        = 0,
               new_write   = 1,
               write_burst = 2,
               new_read    = 3,
               read_burst  = 4;

    reg [2:0] state_q = idle, state_d;
    reg [14:0] f_addr_q = 0, f_addr_d;
    reg [9:0] burst_index_q = 0, burst_index_d;
    reg [3:0] led_q = 0, led_d;
    reg [19:0] error_q = 0, error_d;

    reg rw, rw_en;
    reg [15:0] f2s_data;

    wire ready, s2f_data_valid, f2s_data_valid;
    wire [15:0] s2f_data;
    wire key0_tick, key1_tick;
    wire CLK_OUT;
    wire LOCKED;

    wire [3:0] err0, err1, err2, err3, err4, err5;


    (*KEEP="TRUE"*) reg [36:0] counter_q, index_q, index_d;

    always @(posedge CLK_OUT or negedge rst_n) begin
         if (!rst_n || !LOCKED) begin
            state_q <= idle;
            f_addr_q <= 0;
            burst_index_q <= 0;
            led_q <= 0;
            error_q <= 0;
            counter_q <= 0;
            index_q <= 0;
        end
        else begin
            state_q <= state_d;
            f_addr_q <= f_addr_d;
            burst_index_q <= burst_index_d;
            led_q <= led_d;
            error_q <= error_d;
            counter_q <= (state_q == idle) ? 0 : counter_q + 1'b1;
            index_q <= index_d;
        end
    end

    always @* begin
        state_d = state_q;
        f_addr_d = f_addr_q;
        burst_index_d = burst_index_q;
        led_d = led_q;
        error_d = error_q;

        rw = 0;
        rw_en = 0;
        f2s_data = 0;
        index_d = index_q;

        case (state_q)

            idle: begin
                f_addr_d = 0;
                burst_index_d = 0;

                if (key0_tick) begin
                    state_d = new_write;
                    index_d = 0;
                    led_d = 4'b0000;
                end

                if (key1_tick) begin
                    state_d = new_read;
                    error_d = 0;
                    index_d = 0;
                    led_d[3] = 1'b0;
                end
            end

            new_write: begin
                if (ready) begin
                    led_d[1] = 1'b1;
                    rw_en = 1'b1;
                    rw = 1'b0;
                    state_d = write_burst;
                    burst_index_d = 0;
                end
            end

            write_burst: begin
              f2s_data = 16'hAAAA;
            
            if (key[2])
                f2s_data = 16'h5555;
                if (f2s_data_valid) begin
                    burst_index_d = burst_index_q + 1'b1;
                    index_d = index_q + 1'b1;
                end
                else if (burst_index_q == 512) begin
                    if (counter_q >= 25_000_000) begin
                        led_d[1:0] = 2'b11;
                        state_d = idle;
                    end
                    else begin
                        f_addr_d = f_addr_q + 1'b1;
                        state_d = new_write;
                    end
                end
            end

            new_read: begin
                if (ready) begin
                    led_d[2] = 1'b1;
                    rw_en = 1'b1;
                    rw = 1'b1;
                    state_d = read_burst;
                    burst_index_d = 0;
                end
            end

               read_burst: begin
               if (s2f_data_valid) begin
                   if (s2f_data != 16'hAAAA) begin
                       error_d = error_q + 1'b1;
                       led_d[3] = 1'b1;
                   end
           
                   burst_index_d = burst_index_q + 1'b1;
                   index_d = index_q + 1'b1;
               end
               else if (burst_index_q == 512) begin
                   if (counter_q >= 25_000_000) begin
                       led_d[2] = 1'b1;
                       state_d = idle;
                   end
                   else begin
                       f_addr_d = f_addr_q + 1'b1;
                       state_d = new_read;
                   end
               end
           end

            default: state_d = idle;

        endcase
    end

    assign led = (!rst_n) ? 4'b0000 : led_q;

    sdram_controller m0 (
        .clk(CLK_OUT),
        .rst_n(rst_n & LOCKED),
        .rw(rw),
        .rw_en(rw_en),
        .f_addr(f_addr_q),
        .f2s_data(f2s_data),
        .s2f_data(s2f_data),
        .s2f_data_valid(s2f_data_valid),
        .f2s_data_valid(f2s_data_valid),
        .ready(ready),

        .s_clk(sdram_clk),
        .s_cke(sdram_cke),
        .s_cs_n(sdram_cs_n),
        .s_ras_n(sdram_ras_n),
        .s_cas_n(sdram_cas_n),
        .s_we_n(sdram_we_n),
        .s_addr(sdram_addr),
        .s_ba(sdram_ba),
        .LDQM(sdram_dqm[0]),
        .HDQM(sdram_dqm[1]),
        .s_dq(sdram_dq)
    );

    debounce_explicit m1 (
        .clk(CLK_OUT),
        .rst_n(rst_n & LOCKED),
        .sw(key[0]),
        .db_level(),
        .db_tick(key0_tick)
    );

    debounce_explicit m2 (
        .clk(CLK_OUT),
        .rst_n(rst_n & LOCKED),
        .sw(key[1]),
        .db_level(),
        .db_tick(key1_tick)
    );

    bin2bcd m4 (
        .clk(CLK_OUT),
        .rst_n(rst_n & LOCKED),
        .start(1'b1),
        .bin(error_q),
        .ready(),
        .done_tick(),
        .dig0(err0),
        .dig1(err1),
        .dig2(err2),
        .dig3(err3),
        .dig4(err4),
        .dig5(err5),
        .dig6(),
        .dig7(),
        .dig8(),
        .dig9(),
        .dig10()
    );
    

    clk_wiz_0 clkgen (
        .clk_in1(clk),
        .clk_out1(CLK_OUT),
        .reset(1'b0),
        .locked(LOCKED)
    );
    


endmodule
