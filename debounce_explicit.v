`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2026 17:41:46
// Design Name: 
// Module Name: debounce_explicit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debounce_explicit(input clk,rst_n,sw ,output reg db_level,db_tick
 );
//fsm initializations;
localparam N=21;
localparam [1:0]idle= 2'b00,delay0=2'b01,one=2'b10,delay1=2'b11;
reg [1:0]state_reg,state_nxt;
reg [N-1:0] timer_reg,timer_nxt;
reg timer_zero, timer_inc, timer_tick;
//sequential blk;
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
state_reg<=idle;
timer_reg<=0;
end
else begin
state_reg<=state_nxt;
timer_reg<=timer_nxt;
end
end
//combinational blk
always @ * begin
state_nxt=state_reg;
timer_zero=0;
timer_inc=0;
db_tick=0;
db_level=0;  

case(state_reg)
idle: if(sw==1) begin
timer_zero=1;
state_nxt=delay0;
end
delay0: if(sw==1) begin
							timer_inc=1;
							if(timer_tick) begin 
								state_nxt=one; 
								db_tick=1;
							end
					  end
					  else state_nxt=idle;
one: begin
							db_level=1;
							if(sw==0) begin
								timer_zero=1;  
								state_nxt=delay1;
							end
					  end
		   delay1: begin
                                       db_level=1;
                                       if(sw==0) begin
                                           timer_inc=1;
                                           if(timer_tick)
                                               state_nxt=idle;
                                       end
                                       else state_nxt=one;
                                  end
                        default: state_nxt=idle;
                       endcase                    
                   end
always @* begin
timer_nxt=timer_reg;
if(timer_zero) timer_nxt=0;
else if(timer_inc) timer_nxt=timer_reg+1;
timer_tick=(timer_reg=={N{1'b1}})?1:0;
end



endmodule
