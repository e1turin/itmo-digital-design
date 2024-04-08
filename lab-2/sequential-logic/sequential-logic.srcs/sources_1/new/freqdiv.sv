`timescale 1ns / 1ps

module freqdiv
(
  input   logic   clk,
  output  logic   outclk
);

logic [2:0] count = 0;

always_comb begin
  count = count + 1;
  if (count == 5) begin
    count = 0;
    outclk = ~outclk;
  end
end

endmodule
