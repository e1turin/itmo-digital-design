`timescale 1ns / 1ps

module freqdiv
#(
  parameter BIT_SIZE = 3,
  parameter MAX_COUNT = 5
) (
  input   logic   clk,
  output  logic   outclk
);

logic [BIT_SIZE-1:0] count = 0;

always_ff @(posedge clk) begin
  count <= count + 1;
  if (count == MAX_COUNT) begin
    count <= 0;
    outclk <= ~outclk;
  end
end

endmodule
