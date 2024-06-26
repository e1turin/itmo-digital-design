`timescale 1ns / 1ps

module explicit_adder # (
  parameter BIT_DEPTH = 8
) (
  input   logic [BIT_DEPTH-1:0] a_i,
  input   logic [BIT_DEPTH-1:0] b_i,
  output  logic [BIT_DEPTH-1:0] sum_o
);

  always_comb begin
    sum_o = a_i + b_i;
  end

endmodule

module explicit_multiplier # (
  parameter BIT_DEPTH = 8
) (
  input   logic [BIT_DEPTH-1:0] a_i,
  output  logic [BIT_DEPTH-1:0] product_o
);

  always_comb begin
    product_o = a_i << 1;
  end
    
endmodule

module explicit_divider # (
  parameter BIT_DEPTH = 8
) (
  input   logic [BIT_DEPTH-1:0] a_i,
  output  logic [BIT_DEPTH-1:0] quotient_o
);
  
  always_comb begin
    quotient_o = a_i >> 1;
  end
    
endmodule

module fsm_1 # (
  parameter BIT_DEPTH = 8
) (
  input   logic                 clk_i,
  input   logic                 reset_i, // async
  input   logic [BIT_DEPTH-1:0] a_i, b_i,
  input   logic                 valid_i,
  output  logic [BIT_DEPTH-1:0] result_o
);

// (A/2+B)*8 + (A-B/2)*4 = ((A>>1) + B)<<3 + (A + ~(B>>1) + 1)<<2
//
// ( ( A>>1 ) + B )<<3 + ( (A + 1) + ~ (B>>1) ) )<<2
// | |      |     |  |   | |--1+-|     |-1/-| |    | : S1   : S1
// | |--2/--|     |  |   |--------2~+---------|    | : S2   : S2
// |-----3+-------|  |   |------------3*-----------| : S3_0 : S3 // can repeat to use only 1 mul
// |                 |   | ^----------3*---------^ | : S3_1 : 
// |--------4*-------|   |----------4+0------------| : S4_0 : S4 // can repeat to use only 1 sum
// | ^------4*-----^            (move to sum)      | : S4_1 :
// | ^------4*-----^                               | : S4_2 :
// |-------------------5+--------------------------| : S5   : S5
//  put out result                                   : S6

  typedef enum logic [3:0] { // 10 states at all
    S0, // waiting for input
    S1,   
    S2, 
    S3_0, S3_1,
    S4_0, S4_1, S4_2, 
    S5,
    S6 // return the result
  } state_e;
  
  state_e curr_state = S0;
  state_e next_state = S0;
  
  logic [BIT_DEPTH-1:0] adder_a, adder_b;
  logic [BIT_DEPTH-1:0] sum_res;

  logic [BIT_DEPTH-1:0] divider_2_a;
  logic [BIT_DEPTH-1:0] div_res;
  
  logic [BIT_DEPTH-1:0] multiplier_2_a;
  logic [BIT_DEPTH-1:0] mul_res;
  
  
  explicit_adder # ( 
    .BIT_DEPTH ( BIT_DEPTH )
  ) adder_1 (
    .a_i   ( adder_a ),
    .b_i   ( adder_b ),
    .sum_o ( sum_res )
  );
  
  explicit_multiplier # ( 
    .BIT_DEPTH ( BIT_DEPTH )
  ) multiplier_4_1 (
    .a_i       ( multiplier_2_a ),
    .product_o ( mul_res        )
  );
  
  explicit_divider # (
    .BIT_DEPTH ( BIT_DEPTH )
  ) divider_2_1 (
    .a_i        ( divider_2_a ),
    .quotient_o ( div_res     )
  );
  
  always_comb
  begin
    case (curr_state)
      S0    : next_state = S1;
      S1    : next_state = S2;
      S2    : next_state = S3_0;
      S3_0  : next_state = S3_1;
      S3_1  : next_state = S4_0;
      S4_0  : next_state = S4_1;
      S4_1  : next_state = S4_2;
      S4_2  : next_state = S5;
      S5    : next_state = S6;
      S6    : next_state = S0;
      default: next_state = S0;
    endcase
  end
  
  always_ff @(posedge clk_i or posedge reset_i) 
  begin
    if (reset_i)  curr_state <= S0;
    else          curr_state <= next_state;
  end
  
  always_ff @(posedge clk_i)
  begin
    if (valid_i)
      case (curr_state)
        S1 : begin
          divider_2_a <= b_i;
          adder_a <= a_i;
          adder_b <= 1;
        end
        S2 : begin
          divider_2_a <= a_i;
          adder_a <= sum_res;
          adder_b <= ~div_res;
        end
        S3_0 : begin
          adder_a <= div_res;
          adder_b <= b_i;
          multiplier_2_a <= sum_res;
        end
        S3_1 : begin
          multiplier_2_a <= mul_res;
        end
        S4_0 : begin
          adder_a <= mul_res;
          adder_b <= 0;
          multiplier_2_a <= sum_res;
        end
        S4_1 : begin
          multiplier_2_a <= mul_res;
        end
        S4_2 : begin
          multiplier_2_a <= mul_res;
        end
        S5 : begin
          adder_a <= sum_res;
          adder_b <= mul_res;
        end
        S6 : begin
          result_o <= sum_res;
        end
      endcase
  end
  
endmodule
