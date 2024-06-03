`timescale 1ns / 1ps

module golden_fsm_1(
  input logic clk,
  input logic reset,
  input integer a,
  input integer b,
  output logic valid,
  output integer result
);

  initial
  begin
    if(reset)
    begin
      result = 0;
      valid = 0;
    end
    else
    begin
      repeat(9)
      begin
        @(posedge clk); 
      end
      result = (a/2+b)*8 + (a-b/2)*4;
      valid = 1;
    end
  end

endmodule

module fsm_1_tb;
  
  localparam N = 16;
  
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
    .clk_i    ( clk         ),
    .reset_i  ( reset       ),
    .a_i      ( test_a      ), 
    .b_i      ( test_b      ),
    .valid_i  ( test_valid  ),
    .result_o ( test_result )
  );
    
  always #20 clk = ~clk;

  initial 
  begin
    clk = 0;
    #10 reset = 1;
    #20 reset = 0;
    #10 test_valid = 1;
    
    repeat(10) 
      @(posedge clk);
    
    #10;
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
    #20 $stop;
  end

endmodule
