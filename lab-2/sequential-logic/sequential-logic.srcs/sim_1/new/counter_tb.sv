`timescale 1ns / 1ps

module counter_tb;

  localparam N = 8;
  localparam INIT_VALUE = 2**N - 5;

  logic clk = 0, arst = 0, enable = 0, set = 1;
  logic [N-1:0] count_i, count_o;

  integer it = 0;

  counter #(
    .BIT_DEPTH  ( N ),
    .TO_DOWN    ( 0 )
  ) dut (
    .clk      (clk      ),
    .arst     (arst     ),
    .enable_i (enable   ),
    .set_i    (set      ), 
    .count_i  (count_i  ),
    .count_o  (count_o  )
  );

  always #20 clk = ~clk;

  initial 
  begin
    #25 arst = 1;
    #5  arst = 0;
    
    #5  if (count_o != 0) $error("DUT has not reseted async!");
    #10 if (count_o != 0) $error("DUT has not reseted after clk!");
    
    enable = 1;
    #5 count_i = INIT_VALUE;
    set = 1;

    @(posedge clk);
    #5 set = 0;
    #5 enable = 0;
    if (count_o != INIT_VALUE) $error("DUT looses load!");

    
    @(negedge clk);
    #5 enable = 1;
    
    repeat (4)
    begin
      @(posedge clk);
      #5  if (count_o != INIT_VALUE + it + 1) $error("DUT looses update!");
      
      #5  enable = 0;
      @(posedge clk);      
      #5  if (count_o != INIT_VALUE + it + 1) $error("DUT looses enable signal!");
      it += 1;
      enable = 1;
    end
    
    @(posedge clk)
    it += 1;
    #5  if (count_o != 0) $error("DUT looses overflow!");
  
  end

endmodule
