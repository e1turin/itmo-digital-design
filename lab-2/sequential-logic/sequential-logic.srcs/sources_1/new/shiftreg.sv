`timescale 1ns / 1ps

module shiftreg
#(
  parameter BIT_DEPTH = 8,
  parameter TO_HIGHT = 1
) (
  input   logic                 clk,
  input   logic                 arst, 
  input   logic                 enable,
  input   logic                 load_i,
  input   logic                 shift_i,
  input   logic [BIT_DEPTH-1:0] data_i,
  output  logic [BIT_DEPTH-1:0] data_o,
  output  logic                 shift_o
);

  assign shift_o = data_o[BIT_DEPTH-1];

  always_ff @(posedge clk or posedge arst) 
  begin
    if (arst) data_o <= 0;
    else 
      if (enable)
        if (load_i) data_o <= data_i;
        else 
          if (TO_HIGHT) data_o <= {data_o[BIT_DEPTH-2:0], shift_i};
          else          data_o <= {shift_i, data_o[BIT_DEPTH-1:1]};
  end

endmodule
