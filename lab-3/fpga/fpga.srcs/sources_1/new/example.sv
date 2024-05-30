`timescale 1ns / 1ps

module example(
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

  assign LED = SW;

//  //assign LED = SW;
  localparam N = 'd8;
  localparam EN = 1'd0;
  localparam DES = 1'd1;
  
  logic clk;  

  logic arstn;
  
  button_debouncer # (
    .WAIT_TIME ( 100_000 )
  ) debounce_cpu_resetn (
    .clk    ( CLK100MHZ   ),
    .btn_i  ( CPU_RESETN  ),
    .btn_state_o  ( arstn       )
  );

  freqdiv # (
    .BIT_DEPTH ( 32 ),
    .MAX_COUNT ( 200_000 )
  ) fd (
    .clk_i  ( CLK100MHZ ),
    .clk_o  ( clk       )
  );
  
  logic [4:0] digit = 0;
  logic first_part = 0;
  assign {LED16_R, LED16_G, LED16_B} = {3{first_part}};
  assign {LED17_R, LED17_G, LED17_B} = {3{~first_part}};

  logic btn_clk;
  button_debouncer # (
    .WAIT_TIME ( 100_000 )
  ) debounce_center_button (
    .clk    ( CLK100MHZ ),
    .btn_i  ( BTNC      ),
    .btn_o  ( btn_clk   )
  );
  
  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn) first_part <= ~first_part;
    else 
      if (btn_clk) first_part <= ~first_part;
      else 
        if (first_part && digit >= 3)       digit <= 0;
        else if (!first_part && digit >= 7) digit <= 3;
        else                                digit <= digit + 1;
  end
 
  always_comb
  begin
    case(digit)
      0:  begin
        AN = {DES, DES, DES, DES, DES, DES, DES, EN};
        {CA, CB, CC} = {3{EN}}; 
        {CE, CD, CF, CG } = {4{DES}};
      end
      1:  begin
        AN = {DES, DES, DES, DES, DES, DES, EN, DES};
        {CA,  CC, CD, CF, CG} = {5{EN}}; 
        {CB, CE} = {2{DES}};
      end
      2:  begin
        AN = {DES, DES, DES, DES, DES, EN, DES, DES};
        {CA, CB, CC} = {3{EN}}; 
        {CE, CD, CF, CG } = {4{DES}};
      end
      3:  begin
        AN = {DES, DES, DES, DES, EN, DES, DES, DES};
        {CA,  CC, CD, CF, CG} = {5{EN}}; 
        {CB, CE} = {2{DES}};
      end
      4:  begin
        AN = {DES, DES, DES, EN, DES, DES, DES, DES};
        {CA, CB, CC} = {3{EN}}; 
        {CE, CD, CF, CG } = {4{DES}};
      end
      5:  begin
        AN = {DES, DES, EN, DES, DES, DES, DES, DES};
        {CA,  CC, CD, CF, CG} = {5{EN}}; 
        {CB, CE} = {2{DES}};
      end
      6:  begin
        AN = {DES, EN, DES, DES, DES, DES, DES, DES};
        {CA, CB, CC} = {3{EN}}; 
        {CE, CD, CF, CG } = {4{DES}};
      end
      7:  begin
        AN = {EN, DES, DES, DES, DES, DES, DES, DES};
        {CA,  CC, CD, CF, CG} = {5{EN}}; 
        {CB, CE} = {2{DES}};
      end
      default: begin
        {CA,  CC, CD, CF, CG, CB, CE} = {7{DES}}; 
        AN = {DES, DES, DES, DES, DES, DES, DES, DES};
      end
    endcase
  end

endmodule
