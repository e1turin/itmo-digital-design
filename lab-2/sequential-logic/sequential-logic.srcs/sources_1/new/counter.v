`timescale 1ns / 1ps

module counter_div5
(
  input   logic       clk,
  input   logic       rst, en,
  output  logic [2:0] cout
);

always @(posedge clk, posedge reset) 
begin
  if (rst | (cout == 5)) 
    cout <= 0;
  else if (en)      
    cout <= cout + 1;
end
    
endmodule
