`timescale 1ns / 1ps


module fsm_1_tb;
  
  localparam N = 16;
  
  logic clk;
  logic reset;
  
  logic [N-1:0] a_test;
  logic [N-1:0] b_test;
  logic       valid_test;
  logic [N-1:0] result_test;
  
  fsm_1 # (
    .N ( N )
  ) dut (
    .clk    ( clk         ),
    .reset  ( reset       ),
    .a      ( a_test      ), 
    .b      ( b_test      ),
    .valid  ( valid_test  ),
    .result ( result_test )
  );
  
  always #20 clk = ~clk;
  
  initial 
  begin
    clk = 0;
    reset = 1;
    #25
    reset = 0;

    a_test = 16'd2;
    b_test = 16'd2;
    valid_test = 1;
//    clk = 0;
//    for (integer i = 0; i < 9; i = i + 1)
//    begin
//      #10;
//      clk = 1;
//      #10;
//      clk = 0;
//    end
    
    $display("result = %0d", result_test);
  end

endmodule
