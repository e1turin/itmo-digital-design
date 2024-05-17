`timescale 1ns / 1ps

module counter
#(
  parameter BIT_DEPTH = 8,
  parameter TO_DOWN = 0
) (
  input   logic                 clk,
  input   logic                 arst,
  input   logic                 enable_i,
  input   logic                 set_i, 
  input   logic [BIT_DEPTH-1:0] count_i,
  output  logic [BIT_DEPTH-1:0] count_o
);

always_ff @(posedge clk or posedge arst)
begin
  if (arst) count_o <= 0;
  else 
    if (enable_i)
      if (set_i)      count_o <= count_i;
      else 
        if (TO_DOWN)  count_o <= count_o - 1;
        else          count_o <= count_o + 1;
end

endmodule
