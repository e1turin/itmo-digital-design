`timescale 1ns / 1ps

module shiftreg
#(
  parameter DEPTH = 8
) (
  input   logic         clk,
  input   logic             reset, load,
  input   logic             sin,
  input   logic [DEPTH-1:0] d,
  output  logic [DEPTH-1:0] q,
  output  logic         sout
);

assign sout = q[DEPTH-1];

always_ff @(posedge clk, posedge reset) begin
  if (reset) 
    q <= 0;
  else if (load) 
    q <= d;
  else 
    q <= {q[DEPTH-2:0], sin};
end

endmodule
