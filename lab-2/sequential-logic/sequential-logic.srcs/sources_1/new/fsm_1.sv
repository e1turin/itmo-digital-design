`timescale 1ns / 1ps

module fsm_1
#(
  parameter N = 8
) (
  input   logic         clk,
  input   logic         reset, // async
  input   logic [N-1:0] a, b,
  output  logic [N-1:0] result
);

// (A    /   2 + B) * 8 + (A - B    /   2) * 4 = RESULT
// ^--DIV_1--^                 ^--DIV_2--^     : S_DIV
// ^-----SUM_1----^       ^-----SUB_1----^     : S_SUM
// ^------MUL_1-------^   ^-------MUL_2------^ : S_MUL
// ^------------------SUM_2------------------^ : S_RES

typedef enum logic [1:0] {
  S_IDLE, // waiting for input
  S_DIV, S_SUM, S_MUL, S_RES
} statetype;
statetype state = S_DIV;

logic [N-1:0] div_res[0:1];
logic [N-1:0] sum_res[0:1];
logic [N-1:0] mul_res[0:1];

always @(posedge clk, posedge reset) begin
  if (reset) state = S_DIV;
  else
    case (state)
      //S_IDLE: state = S_DIV;
      S_DIV:  state = S_SUM;
      S_SUM:  state = S_MUL;
      S_MUL:  state = S_RES;
      S_RES:  state = S_DIV;
    endcase
end

always @(posedge clk) begin
  case (state)
    //S_IDLE: 
    S_DIV:  div_res <= {a >> 1, b >> 1};
    S_SUM:  sum_res <= {div_res[1] + b, div_res[2] + ~a + 1};
    S_MUL:  mul_res <= {sum_res[1] << 3, sum_res[2] << 2};
    S_RES:  result  <= mul_res[1] + mul_res[2];
  endcase
end

endmodule
