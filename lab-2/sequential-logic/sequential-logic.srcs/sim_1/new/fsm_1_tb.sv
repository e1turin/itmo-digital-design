`timescale 1ns / 1ps


module fsm_1_tb;
  
  localparam N = 8;
  
  logic clk;
  logic reset;
  
  logic   [N-1:0] test_a = $random();
  logic   [N-1:0] test_b = $random();
  logic           test_valid;
  logic   [N-1:0] test_result;
  integer         expect_result = (test_a/2 + test_b)*8 + (test_a - test_b/2)*4;
  integer         expect_result_rem = expect_result % 2**N;

  fsm_1 # (
    .BIT_DEPTH ( N )
  ) dut (
    .clk    ( clk         ),
    .reset  ( reset       ),
    .a      ( test_a      ), 
    .b      ( test_b      ),
    .valid  ( test_valid  ),
    .result ( test_result )
  );
    
  //  always #10 clk = ~clk

  initial 
  begin
    clk = 0;
    reset = 1;
    #10 reset = 0;
    #10 test_valid = 1;
    
    for (integer i = 0; i < 10; i = i + 1)
    begin
      #10 clk = 1;
      #10 clk = 0;
    end
    if (test_result != expect_result % 2**N) 
    begin
      $error("result = %0d", test_result);
      $error(
        "expect result = %0d = %0d mod %0d",
        expect_result, 
        expect_result % 2**N, 
        2**N
      );
    end
//    $stop;
  end

endmodule
