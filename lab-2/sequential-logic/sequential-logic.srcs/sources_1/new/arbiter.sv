`timescale 1ns / 1ps

interface transaction_if # (
  parameter BIT_DEPTH = 8
);
  logic [BIT_DEPTH-1:0] data;
  logic                 valid;

  modport SND (input  data, input   valid);
  modport RCV (output data, output  valid);

endinterface


module arbiter # ( 
  parameter BIT_DEPTH = 8
) (
  input   logic   clk,
  input   logic   arst,
  output  logic   ready_o,
  transaction_if  t_1_i,
  transaction_if  t_2_i,
  transaction_if  t_3_i,
  transaction_if  t_4_i,
  transaction_if  t_o
);

  logic [3:0] req = 'd0;  
  logic valid_1;
  logic valid_2;
  logic valid_3;
  logic valid_4;
  
  assign valid_1 = t_1_i.valid;
  assign valid_2 = t_2_i.valid;
  assign valid_3 = t_3_i.valid;
  assign valid_4 = t_4_i.valid;

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
    endcase
  end

  always_ff @(posedge clk or posedge arst)
  begin
    if (arst || !req_status)
    begin
      req <= {valid_4,
              valid_3, 
              valid_2,
              valid_1};
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
      t_o.valid = 'd1;
      case (grant_ptr)
        2'd0: t_o.data = t_1_i.data;
        2'd1: t_o.data = t_2_i.data;
        2'd2: t_o.data = t_3_i.data;
        2'd3: t_o.data = t_4_i.data;
      endcase
      ready_o = 'd0;
    end
    else begin
      t_o.valid = 'd0;
      t_o.data  = 'd0;
      ready_o   = 'd1;
    end
  end

endmodule
