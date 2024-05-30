`timescale 1ns / 1ps


module button_debouncer_tb;

  logic clk = 0;
  logic arstn = 1;
  logic btn_i = 0;
  logic btn_state_o;
  logic btn_up_o;
  logic btn_down_o;

  button_debouncer # (
    .BIT_DEPTH ( 32 ),
    .WAIT_TIME ( 10 )
  ) dut (
    .clk          ( clk         ),
    .arstn        ( arstn       ),
    .btn_i        ( btn_i       ),
    .btn_state_o  ( btn_state_o ),
    .btn_up_o     ( btn_up_o    ),
    .btn_down_o   ( btn_down_o  )
  );

  always #20 clk = ~clk;
  
  initial
  begin
    #12 arstn = 0;
    #3  arstn = 1;   

    /// first part

    #10;
    repeat(15) // even times of inversions
    begin
      btn_i = ~btn_i;
      #12;
    end
    
    repeat(10) @(posedge clk);
    
    #5 if (btn_state_o != 1) $error("DUT should say 1");
    
    repeat(15) // even times of inversion
    begin
      btn_i = ~btn_i;
      #12;
    end
    
    repeat(10) @(posedge clk);
    
    #5 if (btn_state_o != 0) $error("DUT should say 0");
  
    /// second part
  
    #10;
    repeat(10) // odd times of inversion
    begin
      btn_i = ~btn_i;
      #12;
    end
    
    repeat(10) @(posedge clk);
    
    #5 if (btn_state_o != 0) $error("DUT should say 0");
    
    #5 btn_i = ~btn_i;
    repeat(12) @(posedge clk);
    
    #10;
    repeat(10) // odd times of inversion
    begin
      btn_i = ~btn_i;
      #12;
    end
    
    repeat(10) @(posedge clk);
    
    #5 if (btn_state_o != 1) $error("DUT should say 1");
  
    #20 $stop;

  end

  

endmodule
