`timescale 1ns / 1ps

module freqdiv
#(
  parameter BIT_DEPTH = 3,
  parameter MAX_COUNT = 5
) (
  input   logic clk_i,
  output  logic clk_o
);

logic [BIT_DEPTH-1:0] count = 0;

always_ff @(posedge clk_i) begin
  count <= count + 1;
  if (count == MAX_COUNT) begin
    count <= 0;
    clk_o <= ~clk_o;
  end
end

endmodule
