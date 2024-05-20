`timescale 1ns / 1ps

module freqdiv_tb;

  logic clk = 0, arst = 0, clk_div;

  freqdiv # (
    .BIT_DEPTH ( 3 ),
    .MAX_COUNT ( 5 )
  ) dut (
    .clk_i  ( clk     ),
    .arst   ( arst    ),
    .clk_o  ( clk_div )
  );

  always #20 clk = ~clk;
  
  initial
  begin
    #25 arst = 1;
    #5  arst = 0;
    if (clk_div != 0) $error("DUT looses reset!");
    
    repeat(5)
    begin
      @(posedge clk);
      #5 if (clk_div != 0) $error("DUT changes output (0) too early!");
    end
    
    @(posedge clk);
    #5 if (clk_div != 1) $error("DUT doesn't change output after timeout!");
    
    repeat(5)
    begin
      @(posedge clk);
      #5 if (clk_div != 1) $error("DUT changes output (1) too early!");
    end
    
    @(posedge clk);
    #5 if (clk_div != 0) $error("DUT doesn't change output after timeout!");
    
    #20;
    
    $stop;
  end

endmodule
