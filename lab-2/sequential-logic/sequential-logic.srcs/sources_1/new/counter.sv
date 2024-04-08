`timescale 1ns / 1ps

module counter
#(parameter N = 8)
(
  input   logic         clk,
  input   logic [N-1:0] cin,
  input   logic         set, en,
  input   logic         reset, // async
  output  logic [N-1:0] cout
);

always_ff @(posedge clk, posedge reset) begin
  if (set)
    cout <= cin;
  else if (reset)
    cout <= 0;
  else if (en)      
    cout <= cout + 1;
end
    
endmodule
