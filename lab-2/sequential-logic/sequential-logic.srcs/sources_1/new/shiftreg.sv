`timescale 1ns / 1ps

module shiftreg
#(
  parameter BIT_DEPTH = 8
) (
  input   logic                 clk_i,
  input   logic                 reset_i, load_i,
  input   logic                 shift_i,
  input   logic [BIT_DEPTH-1:0] data_i,
  output  logic [BIT_DEPTH-1:0] data_o,
  output  logic                 shift_o
);

assign shift_i = data_o[BIT_DEPTH-1];

always_ff @(posedge clk_i, posedge reset_i) begin
  if (reset_i) data_o <= 0;
  else 
    if (load_i) data_o <= data_i;
    else        data_o <= {data_o[BIT_DEPTH-2:0], shift_i};
end

endmodule
