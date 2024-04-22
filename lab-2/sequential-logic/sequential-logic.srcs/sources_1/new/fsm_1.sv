`timescale 1ns / 1ps


module fsm_1 # (
  parameter N = 8
) (
  input   logic         clk,
  input   logic         reset, // async
  input   logic [N-1:0] a, b,
  input   logic         valid,
  output  logic [N-1:0] result
);

// (A/2+B)*8 + (A-B/2)*4 = ((A>>1) + B)<<3 + (A + ~(B>>1) + 1)<<2
//
// ( ( A>>1 ) + B )<<3 + ( (A + 1) + ~ (B>>1) ) )<<2
// | |      |     |  |   | |--1+-|     |-1/-| |    | : S1 : S1
// | |--2/--|     |  |   |--------2~+---------|    | : S2 : S2
// |-----3+-------|  |   |------------3*-----------| : S3 : S3 // can repeat to use only 1 mul
// |                 |   | ^----------3*---------^ | : S4 :
// |--------4*-------|   |----------4+0------------| : S5 : S4 // can repeat to use only 1 sum
// | ^------4*-----^            (move to sum)      | : S6 :
// | ^------4*-----^                               | : S7 :
// |-------------------5+--------------------------| : S8 : S5

typedef enum logic [2:0] {
  S0, // waiting for input
  S1, S2, S3, S4, S5
} state_e;

state_e curr_state = S0;
state_e next_state = S0;

logic [N-1:0] div_res;
logic [N-1:0] sum_res;
logic [N-1:0] mul_res;

always_comb
begin
  next_state = curr_state;
  case (curr_state)
    S0 : next_state = S1;
    S1 : next_state = S2;
    S2 : next_state = S3;
    S3 : next_state = S4;
    S4 : next_state = S5;
    S5 : next_state = S0;
    default: next_state = S0;
  endcase
end

always_ff @(posedge clk or posedge reset) 
begin
  if (reset) curr_state <= S0;
  else       curr_state <= next_state;
end

always_ff @(posedge clk)
begin
  if (valid)
    case (curr_state)
      S1 : begin
        div_res <= ~(b >> 1);
        sum_res <= a + 1;
      end
      S2 : begin
        div_res <= a >> 1;
        sum_res <= sum_res + div_res;
      end
      S3 : begin
        sum_res <= div_res + b;
        mul_res <= sum_res << 2;
      end
      S4 : begin
        mul_res <= sum_res << 3;
        sum_res <= mul_res;
      end
      S5 : begin
        result <= sum_res + mul_res;
      end
    endcase
end


endmodule
