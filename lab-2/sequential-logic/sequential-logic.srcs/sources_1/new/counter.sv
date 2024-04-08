`timescale 1ns / 1ps

module counter
#(parameter N)
(
  input   logic         clk,
  input   logic [N-1:0] cin,
  input   logic         set, en,
  input   logic         rst, // async
  output  logic [N-1:0] cout
);

always @(posedge clk, posedge rst) 
begin
  if (set)
    cout <= cin;
  else if (rst) // should it be '>=5' ?
    cout <= 0;
  else if (en)      
    cout <= cout + 1;
end
    
endmodule
