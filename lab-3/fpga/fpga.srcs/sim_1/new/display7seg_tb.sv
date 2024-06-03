`timescale 1ns / 1ps

module display7seg_tb;

  logic clk = 0;
  logic arstn = 1;
  
  logic [2:0] data_i = 'b010;
  logic [3:0] number_i = 'b0100;
  logic [7:0] digits_o;
  logic [7:0] segments_o;
  
  display7seg # ( 
    .FREQ_DIV_RATE (1)
  ) dut (
    .clk        ( clk         ),
    .arstn      ( arstn       ),
    .data_i     ( data_i      ),
    .number_i   ( number_i    ),
    .DIGITS_o   ( digits_o    ),
    .SEGMENTS_o ( segments_o  )
);
  
  always #20 clk = ~clk;
  
  initial
  begin
    #10 arstn = 0;
    #5  arstn = 1;
    
    repeat(20) @(posedge clk);
    
    data_i = 'b100;
    
    repeat(20) @(posedge clk);
  
    number_i = 'b0001;
    
    repeat(20) @(posedge clk);

    #30 $stop;
  end

endmodule
