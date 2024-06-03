`timescale 1ns / 1ps


module arbiter # (
  parameter BIT_DEPTH = 8,
  parameter T_AMOUNT = 4
) (
  input   logic                 clk,
  input   logic                 arstn,
  input   logic [BIT_DEPTH-1:0] t_data_i  [T_AMOUNT-1:0],
  input   logic [T_AMOUNT-1:0]  t_valid_i,
  output  logic                 ready_o,
  output  logic [BIT_DEPTH-1:0] t_data_o,
  output  logic                 t_valid_o,
  output  logic [T_AMOUNT-1:0]  t_number_o
);
  
  typedef logic [T_AMOUNT-1:0] bus;
  
  logic [T_AMOUNT-1:0] req = 'd0;  

  logic  prepared_f;
  assign prepared_f = | req;
  
  logic [1:0] grant_ptr;

  always_comb
  begin
    casez (req)
      4'b???1: grant_ptr = 'd0;
      4'b??10: grant_ptr = 'd1;
      4'b?100: grant_ptr = 'd2;
      4'b1000: grant_ptr = 'd3;

      default: grant_ptr = 'd3;
    endcase
  end

  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn)           req <= 0;
    else if (!prepared_f) req <= t_valid_i;
    else                  req[grant_ptr] = 'd0;
  end

  always_comb
  begin
    if (prepared_f)
    begin
      t_valid_o = 'd1;
      t_data_o  = t_data_i[grant_ptr];
      ready_o   = 'd0;
      case (grant_ptr)
        2'd0: t_number_o = 'b0001;
        2'd1: t_number_o = 'b0010;
        2'd2: t_number_o = 'b0100;
        2'd3: t_number_o = 'b1000;
      endcase
    end
    else 
    begin
      t_valid_o   = 'd0;
      t_data_o    = 'd0;
      t_number_o  = 'd0;
      ready_o     = 'd1;
    end
  end

endmodule