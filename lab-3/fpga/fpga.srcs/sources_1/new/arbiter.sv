`timescale 1ns / 1ps

//interface transaction_if # (
//  parameter BIT_DEPTH = 8
//);
//  logic [BIT_DEPTH-1:0] data;
//  logic                 valid;

//  modport SND (input  data, input   valid);
//  modport RCV (output data, output  valid);

//endinterface


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
//  logic valid_1;
//  logic valid_2;
//  logic valid_3;
//  logic valid_4;
  
//  assign valid_1 = t_valid_i[0];
//  assign valid_2 = t_valid_i[1];
//  assign valid_3 = t_valid_i[2];
//  assign valid_4 = t_valid_i[3];

  logic  req_status;
  assign req_status = | req;
  
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
    if (!arstn || !req_status)
    begin
//      req <= {t_valid_i[3],
//              t_valid_i[2], 
//              t_valid_i[1],
//              t_valid_i[0]};
      req <= t_valid_i;
    end
    else
    begin
      req[grant_ptr] = 'd0;
    end
  end

  always_comb
  begin
    if (req_status)
    begin
      t_valid_o = 'd1;
      t_data_o  = t_data_i[grant_ptr];
//      case (grant_ptr)
//        2'd0: t_data_o = t_data_i[0];
//        2'd1: t_data_o = t_data_i[1];
//        2'd2: t_data_o = t_data_i[2];
//        2'd3: t_data_o = t_data_i[3];
//      endcase
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
