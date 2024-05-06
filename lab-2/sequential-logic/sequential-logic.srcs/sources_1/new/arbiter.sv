`timescale 1ns / 1ps

interface transaction_if # (
  parameter BIT_DEPTH = 8
);
  logic [BIT_DEPTH-1:0] data;
  logic                 valid;
endinterface


module arbiter # ( 
  parameter BIT_DEPTH = 8
) (
  input   logic   clk,
  transaction_if  t_1_i, 
  transaction_if  t_2_i,
  transaction_if  t_3_i,
  transaction_if  t_4_i,
  transaction_if  t_o
);

  assign t_o.data = t_1_i.data;
  assign t_o.valid = t_1_i.valid;

endmodule
