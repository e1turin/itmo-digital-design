`timescale 1ns / 1ps

module example(
  input   logic CLK100MHZ,
  input   logic [15:0] SW,
  output  logic [15:0] LED,
  output  logic        CA, CB, CC, CD, CE, CF, CG, DP,
  output  logic [7:0]  AN
);

  assign LED = SW;

//  //assign LED = SW;
  localparam N = 'd8;
  localparam EN = 1'd0;
  localparam DES = 1'd1;
  
  logic clk;  

  freqdiv # (
    .BIT_DEPTH ( 32 ),
    .MAX_COUNT ( 1000_000 )
  ) fd (
    .clk_i(CLK100MHZ),
    .clk_o(clk)
  );
  
  logic [4:0]   digit = 0;
  
  always_ff @(posedge clk)
  begin
    if(digit < 7) digit <= digit + 1;
    else          digit = 0;
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
        {CB, CE } = {2{DES}};
      end
      default: begin
        {CA,  CC, CD, CF, CG, CB, CE} = {7{DES}}; 
        AN = {DES, DES, DES, DES, DES, DES, DES, DES};
      end
    endcase
  end

endmodule
