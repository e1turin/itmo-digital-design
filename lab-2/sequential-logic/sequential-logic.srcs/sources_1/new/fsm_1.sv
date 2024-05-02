`timescale 1ns / 1ps

module adder # (
  parameter N = 8
) (
//  input   logic         clk,
  input   logic [N-1:0] a,
  input   logic [N-1:0] b,
  output  logic [N-1:0] res
);
  
//  always_ff @(posedge clk)
//    res <= a + b;
  always_comb
    res = a + b;

endmodule

module multiplier # (
  parameter N = 2
) (
//  input   logic         clk,
  input   logic [N-1:0] a,
  output  logic [N-1:0] res
);

//  always_ff @(posedge clk)
//    res <= {a[N-2:0], 1'd0};

  always_comb
//    res = a << 1;
    res = {a[N-2:0], 1'd0};

    
endmodule

module divider # (
  parameter N = 8
) (
//  input   logic         clk,
  input   logic [N-1:0] a,
  output  logic [N-1:0] res
);
  
//  always_ff @(posedge clk)
//    res <= {1'd0, a[N-1:1]};
  always_comb
//    res = a >> 1;
    res = {1'd0, a[N-1:1]};

    
endmodule

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
// | |      |     |  |   | |--1+-|     |-1/-| |    | : S1   : S1
// | |--2/--|     |  |   |--------2~+---------|    | : S2   : S2
// |-----3+-------|  |   |------------3*-----------| : S3_0 : S3 // can repeat to use only 1 mul
// |                 |   | ^----------3*---------^ | : S3_1 : 
// |--------4*-------|   |----------4+0------------| : S4_0 : S4 // can repeat to use only 1 sum
// | ^------4*-----^            (move to sum)      | : S4_1 :
// | ^------4*-----^                               | : S4_2 :
// |-------------------5+--------------------------| : S5   : S5
//  put out result                                   : S6

  typedef enum logic [3:0] {
    S0, // waiting for input
    S1,   
    S2, 
    S3_0, S3_1,
    S4_0, S4_1, S4_2, 
    S5,
    S6
  } state_e;
  
  state_e curr_state = S0;
  state_e next_state = S0;
  
  logic [N-1:0] div_res;
  logic [N-1:0] sum_res;
  logic [N-1:0] mul_res;
  
  logic [N-1:0] adder_a, adder_b;
  logic [N-1:0] multiplier_2_a;
  logic [N-1:0] divider_2_a;
  
  adder # ( 
    .N ( N )
  ) adder_1 (
//    .clk ( clk     ),
    .a   ( adder_a ),
    .b   ( adder_b ),
    .res ( sum_res )
  );
  
  multiplier # ( 
    .N ( N )
  ) multiplier_4_1 (
//    .clk ( clk            ),
    .a   ( multiplier_2_a ),
    .res ( mul_res        )
  );
  
  divider # (
    .N ( N )
  ) divider_2_1 (
//    .clk ( clk         ),
    .a   ( divider_2_a ),
    .res ( div_res     )
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
          divider_2_a <= b;
          adder_a <= a;
          adder_b <= 1;
//          result <= 1;
        end
        S2 : begin
          divider_2_a <= a;
          adder_a <= sum_res;
          adder_b <= div_res;
//          result <= 2;
        end
        S3_0 : begin
          adder_a <= div_res;
          adder_b <= b;
          multiplier_2_a <= sum_res;
//          result <= 30;
        end
        S3_1 : begin
          multiplier_2_a <= mul_res;
//          result <= 31;
        end
        S4_0 : begin
          adder_a <= mul_res;
          adder_b <= 0;
          multiplier_2_a <= sum_res;
//          result <= 40;
        end
        S4_1 : begin
          multiplier_2_a <= mul_res;
//          result <= 41;
        end
        S4_2 : begin
          multiplier_2_a <= mul_res;
//          result <= 42;
        end
        S5 : begin
          adder_a <= sum_res;
          adder_b <= mul_res;
//          result <= 5;
        end
        S6 : begin
          result <= sum_res;
        end
        default : begin 
          result <= 8'd0;
        end
      endcase
  end
  
endmodule
