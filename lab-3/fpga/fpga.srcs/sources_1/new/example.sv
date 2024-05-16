`timescale 1ns / 1ps

module example(
  input  logic [15:0] SW,
  output logic [15:0] LED
);

assign LED = SW;

endmodule
