`timescale 1ns / 1ps

module counter
#(
  parameter BIT_DEPTH = 8
) (
  input   logic                 clk_i,
  input   logic [BIT_DEPTH-1:0] count_i,
  input   logic                 set_i, enable_i,
  input   logic                 reset_i, // async
  output  logic [BIT_DEPTH-1:0] count_o
);

always_ff @(posedge clk_i, posedge reset_i) begin
  if (reset_i)  count_o <= 0;
  else 
    if (enable_i)
      if (set_i)  count_o <= count_i;
      else        count_o <= count_o + 1;
end

endmodule
