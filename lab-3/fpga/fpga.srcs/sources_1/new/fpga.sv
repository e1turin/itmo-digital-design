`timescale 1ns / 1ps

module fpga(
  input   logic         CLK100MHZ,
  input   logic         CPU_RESETN,
  input   logic [15:0]  SW,
  input   logic         BTNC,
  output  logic [15:0]  LED,
  output  logic         LED16_R, LED16_G, LED16_B,
  output  logic         LED17_R, LED17_G, LED17_B,
  output  logic         CA, CB, CC, CD, CE, CF, CG, DP,
  output  logic [7:0]   AN
);
  localparam FREQ_DIV = 200_000;

  logic div_clk;

  logic arstn;
  assign arstn = CPU_RESETN;

  logic [7:0] digits;
  assign digits = AN;

  logic [7:0] segs;
  assign segs = {CA, CB, CC, CD, CE, CF, CG, DP};
   
  logic btn_clk;
  assign btn_clk = BTNC;
  
  logic [2:0] RGB_LED_1, RGB_LED_2;
  assign {LED16_R, LED16_G, LED16_B} = RGB_LED_1;
  assign {LED17_R, LED17_G, LED17_B} = RGB_LED_2;
  
  logic [2:0] t1_data,  t2_data,  t3_data,  t4_data;
  logic       t1_valid, t2_valid, t3_valid, t4_valid;
  
  assign {t1_data, t1_valid,
          t2_data, t2_valid,
          t3_data, t3_valid,
          t4_data, t4_valid} = SW;
//  assign t1_data = SW[0:2];
//  assign t1_valid = SW[3];
//  assign t2_data = SW[4:6];
//  assign t1_valid = SW[7];
//  assign t3_data = SW[8:10];
//  assign t1_valid = SW[11];
//  assign t4_data = SW[12:14];
//  assign t1_valid = SW[15];
  
  logic [2:0] t_data_i [3:0];
  assign t_data_i = {t1_data,  t2_data,  t3_data,  t4_data};

  logic [3:0] t_valid_i;
  assign t_valid_i = {t1_valid, t2_valid, t3_valid, t4_valid};
  
  logic [2:0] t_data_o;
  logic       t_valid_o;
  assign RGB_LED_1 = {3{t_valid_o}};
  
  logic arb_ready;
  assign RGB_LED_2 = {3{arb_ready}};
  
  logic [3:0] t_number;
    
  freqdiv # (
    .BIT_DEPTH ( 32       ),
    .MAX_COUNT ( FREQ_DIV )
  ) fd (
    .clk_i  ( CLK100MHZ ),
    .clk_o  ( div_clk   )
  );
  
  display7seg display (
    .clk      ( div_clk   ),
    .arstn    ( arstn     ),
    .data     ( t_data_o  ),
    .number   ( t_number  ),
    .DIGITS   ( digits    ),
    .SEGMENTS ( segs      )
  );

  arbiter # (
    .BIT_DEPTH  ( 3 ),
    .T_AMOUNT   ( 4 )
  ) arb(
    .clk        ( btn_clk     ),
    .arstn      ( arstn       ),
    .t_data_i   ( t_data_i    ),
    .t_valid_i  ( t_valid_i   ),
    .ready_o    ( arb_ready   ),
    .t_data_o   ( t_data_o    ),
    .t_valid_o  ( t_valid_o   ),
    .t_number_o ( t_number    )
  );

endmodule
