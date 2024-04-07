`timescale 1ns / 1ps

module counter_div5
(
  input   logic       clk,
  input   logic       reset,
  output  logic [2:0] count
);

always @(posedge clk, posedge reset) 
begin
  if (reset | count == 5) 
    count <= 0;
  else       
    cout <= cout + 1;
end
  
    
endmodule
