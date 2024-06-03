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
  localparam FREQ_DIV_RATE = 100_000;
  localparam ARB_BIT_DEPTH = 3;
  localparam ARB_TRXS = 4;
  
  assign LED = SW;

  logic clk;
  assign clk = CLK100MHZ;
  
  logic arstn;
  assign arstn = CPU_RESETN;

  logic [7:0] digits;
  assign AN = digits;

  logic [7:0] segs;
  assign {CA, CB, CC, CD, CE, CF, CG, DP} = segs;

  logic btn_clk;

  logic btn_i;
  assign btn_i = BTNC;  
  
  logic [2:0] RGB_LED_1, RGB_LED_2;
  assign {LED16_R, LED16_G, LED16_B} = RGB_LED_1;
  assign {LED17_R, LED17_G, LED17_B} = RGB_LED_2;
  
  logic [2:0] t1_data,  t2_data,  t3_data,  t4_data;
  logic       t1_valid, t2_valid, t3_valid, t4_valid;
  
  assign {t1_data, t1_valid,
          t2_data, t2_valid,
          t3_data, t3_valid,
          t4_data, t4_valid} = SW;
  
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

  display7seg display (
    .clk        ( clk       ),
    .arstn      ( arstn     ),
    .data_i     ( t_data_o  ),
    .number_i   ( t_number  ),
    .DIGITS_o   ( digits    ),
    .SEGMENTS_o ( segs      )
  );
  
  button_debouncer # (
    .BIT_DEPTH ( 32      ),
    .WAIT_TIME ( 100_000 )
  ) btn_dbcr (
    .clk          ( clk     ),
    .arstn        ( arstn   ),
    .btn_i        ( btn_i   ),
    .btn_state_o  ( btn_clk ),
    .btn_up_o     (),
    .btn_down_o   ()
  );

  arbiter # (
    .BIT_DEPTH  ( ARB_BIT_DEPTH ),
    .T_AMOUNT   ( ARB_TRXS      )
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
