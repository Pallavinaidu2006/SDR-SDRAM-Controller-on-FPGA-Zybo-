`timescale 1ns / 1ps

module tb_top;

    reg clk = 0;
    reg rst_n = 0;
    reg [2:0] key = 3'b111;

    wire [3:0] led;
    wire sdram_clk;
    wire sdram_cke;
    wire sdram_cs_n;
    wire sdram_ras_n;
    wire sdram_cas_n;
    wire sdram_we_n;
    wire [12:0] sdram_addr;
    wire [1:0] sdram_ba;
    wire [1:0] sdram_dqm;
    wire [15:0] sdram_dq;

    tb_sdram dut (
        .clk(clk),
        .rst_n(rst_n),
        .key(key),
        .led(led),
        .sdram_clk(sdram_clk),
        .sdram_cke(sdram_cke),
        .sdram_cs_n(sdram_cs_n),
        .sdram_ras_n(sdram_ras_n),
        .sdram_cas_n(sdram_cas_n),
        .sdram_we_n(sdram_we_n),
        .sdram_addr(sdram_addr),
        .sdram_ba(sdram_ba),
        .sdram_dqm(sdram_dqm),
        .sdram_dq(sdram_dq)
    );

    always #5 clk = ~clk;

    reg [15:0] sdram_mem [0:524287];
    reg [15:0] dq_drive = 16'hzzzz;
    assign sdram_dq = dq_drive;

    integer write_col = 0;
    integer read_col = 0;
    reg [14:0] active_addr = 0;
    reg mem_write_en = 0;
    reg mem_read_en = 0;
    integer cas_ctr = 0;

    always @(posedge sdram_clk) begin
        case ({sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n})
            4'b0011: begin
                active_addr <= {sdram_ba, sdram_addr};
                write_col <= 0;
                read_col <= 0;
                mem_write_en <= 0;
                mem_read_en <= 0;
                dq_drive <= 16'hzzzz;
            end

            4'b0100: begin
                mem_write_en <= 1;
                mem_read_en <= 0;
                write_col <= 1;
                sdram_mem[{active_addr[8:0], 9'd0}] <= sdram_dq;
                dq_drive <= 16'hzzzz;
            end

            4'b0101: begin
                mem_read_en <= 1;
                mem_write_en <= 0;
                read_col <= 0;
                cas_ctr <= 0;
                dq_drive <= 16'hzzzz;
            end

            4'b0010: begin
                mem_write_en <= 0;
                mem_read_en <= 0;
                dq_drive <= 16'hzzzz;
            end

            default: begin
                if (mem_write_en) begin
                    sdram_mem[{active_addr[8:0], write_col[8:0]}] <= sdram_dq;
                    write_col <= write_col + 1;
                    if (write_col >= 512)
                        mem_write_en <= 0;
                end

                if (mem_read_en) begin
                    if (cas_ctr < 3) begin
                        cas_ctr <= cas_ctr + 1;
                        dq_drive <= 16'hzzzz;
                    end
                    else begin
                        dq_drive <= sdram_mem[{active_addr[8:0], read_col[8:0]}];
                        read_col <= read_col + 1;

                        if (read_col >= 512) begin
                            mem_read_en <= 0;
                            dq_drive <= 16'hzzzz;
                        end
                    end
                end
            end
        endcase
    end

    localparam integer DEBOUNCE_HOLD = 2_300_000;

    task auto_press;
        input integer k;
        begin
            $display("[%0t ns] AUTO: key[%0d] pressed", $time, k);
            key[k] = 0;
            repeat(DEBOUNCE_HOLD) @(posedge clk);
            key[k] = 1;
            repeat(20) @(posedge clk);
            $display("[%0t ns] AUTO: key[%0d] released", $time, k);
        end
    endtask

    task wait_for_idle_after_operation;
        begin
            wait(dut.state_q != 0);
            wait(dut.state_q == 0);
        end
    endtask

    initial begin
        $display("================================================");
        $display("        SDRAM CONTROLLER TESTBENCH              ");
        $display("================================================");

        rst_n = 0;
        key = 3'b111;
        repeat(20) @(posedge clk);
        rst_n = 1;
        $display("[%0t ns] Reset released", $time);

        $display("[%0t ns] Waiting for SDRAM init...", $time);
        repeat(36_000) @(posedge clk);
        $display("[%0t ns] SDRAM init done", $time);

        $display("\n------------------------------------------------");
        $display(" TEST 1: BURST WRITE  [error injection OFF]");
        $display("------------------------------------------------");
        key = 3'b111;
        auto_press(0);
        wait(led[1:0] == 2'b11);
        $display("[%0t ns] WRITE DONE", $time);
        $display("[%0t ns] index_q = %0d", $time, dut.index_q);
        $display("[%0t ns] led     = %b", $time, led);
        repeat(50) @(posedge clk);

        $display("\n------------------------------------------------");
        $display(" TEST 2: BURST READ   [expect 0 errors]");
        $display("------------------------------------------------");
        auto_press(1);
        wait_for_idle_after_operation();
        $display("[%0t ns] READ DONE", $time);
        $display("[%0t ns] index_q = %0d", $time, dut.index_q);
        $display("[%0t ns] error_q = %0d", $time, dut.error_q);
        $display("[%0t ns] led     = %b", $time, led);

        if (dut.error_q == 0)
            $display("[%0t ns] >> PASS: 0 errors", $time);
        else
            $display("[%0t ns] >> FAIL: %0d errors", $time, dut.error_q);

        repeat(50) @(posedge clk);

        $display("\n------------------------------------------------");
        $display(" TEST 3: BURST WRITE  [error injection ON]");
        $display("------------------------------------------------");
        key = 3'b011;
        key[0] = 0;
        repeat(DEBOUNCE_HOLD) @(posedge clk);
        key[0] = 1;
        repeat(20) @(posedge clk);

        wait(led[1:0] == 2'b11);
        $display("[%0t ns] INJECTED WRITE DONE", $time);
        $display("[%0t ns] index_q = %0d", $time, dut.index_q);
        $display("[%0t ns] led     = %b", $time, led);

        key = 3'b111;
        repeat(50) @(posedge clk);

        $display("\n------------------------------------------------");
        $display(" TEST 4: BURST READ   [expect 10240 errors]");
        $display("------------------------------------------------");
        auto_press(1);
        wait_for_idle_after_operation();

        $display("[%0t ns] READ DONE", $time);
        $display("[%0t ns] index_q = %0d", $time, dut.index_q);
        $display("[%0t ns] error_q = %0d", $time, dut.error_q);
        $display("[%0t ns] led     = %b", $time, led);

        if (dut.error_q == 20'd10240)
            $display("[%0t ns] >> PASS: error_q = 10240", $time);
        else
            $display("[%0t ns] >> FAIL: %0d errors", $time, dut.error_q);

        $display("\n================================================");
        $display(" FINAL SUMMARY");
        $display("================================================");
        $display(" Test 1 Write  : led[1:0] = %b", led[1:0]);
        $display(" Test 4 Errors : %0d", dut.error_q);
        $display(" Total words   : %0d", dut.index_q);

        if (dut.error_q == 20'd10240)
            $display(" OVERALL       : PASS");
        else
            $display(" OVERALL       : FAIL");

        $display("================================================");
        $finish;
    end

    always @(dut.state_q) begin
        case (dut.state_q)
            0: $display("[%0t ns] FSM -> IDLE", $time);
            1: $display("[%0t ns] FSM -> NEW_WRITE", $time);
            2: $display("[%0t ns] FSM -> WRITE_BURST", $time);
            3: $display("[%0t ns] FSM -> NEW_READ", $time);
            4: $display("[%0t ns] FSM -> READ_BURST", $time);
        endcase
    end

    always @(led) begin
        $display("[%0t ns] LED -> %b", $time, led);

        if (led[1:0] == 2'b11)
            $display("           *** WRITE COMPLETE ***");

        if (led[2])
            $display("           *** READ OPERATION ACTIVE / DONE ***");

        if (led[3])
            $display("           *** ERROR DETECTED ***");
    end

    always @(dut.error_q) begin
        if (dut.error_q > 0)
            $display("[%0t ns] error_q = %0d", $time, dut.error_q);
    end

endmodule
