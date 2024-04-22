`timescale 1ns / 1ps

module counter
#(
  parameter DEPTH = 8
) (
  input   logic             clk,
  input   logic [DEPTH-1:0] cin,
  input   logic             set, enable,
  input   logic             reset, // async
  output  logic [DEPTH-1:0] cout
);

always_ff @(posedge clk, posedge reset) begin
  if (reset)
    cout <= 0;
  else if (enable)
    if (set)
      cout <= cin;
    else 
      cout <= cout + 1;
end

endmodule
