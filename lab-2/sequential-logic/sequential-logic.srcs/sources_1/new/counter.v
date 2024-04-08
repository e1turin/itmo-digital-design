`timescale 1ns / 1ps

module counter
(
  input   logic       clk,
  input   logic [2:0] cin,
  input   logic       set, en,
  input   logic       rst, // async
  output  logic [2:0] cout
);

always @(posedge clk, posedge rst) 
begin
  if (set & cin <= 5)
    cout <= cin;
  else if (rst | (cout == 5)) // should it be '>=5' ?
    cout <= 0;
  else if (en)      
    cout <= cout + 1;
end
    
endmodule
