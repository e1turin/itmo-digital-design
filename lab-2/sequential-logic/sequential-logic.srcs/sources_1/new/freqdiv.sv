`timescale 1ns / 1ps

module freqdiv
#(
  parameter BIT_DEPTH = 3,
  parameter MAX_COUNT = 5
) (
  input   logic clk_i,
  input   logic arst,
  output  logic clk_o
);

  logic [BIT_DEPTH-1:0] count = 0;

  always_ff @(posedge clk_i or posedge arst)
  begin
    if (arst) 
    begin
      count <= 'd0;
      clk_o <= 'd0;
    end
    else if (count == MAX_COUNT)
    begin
      count <= 'd0;
      clk_o <= ~clk_o;
    end
    else count <= count + 1;
  end

endmodule
