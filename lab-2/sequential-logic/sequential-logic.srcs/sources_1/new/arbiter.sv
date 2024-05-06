`timescale 1ns / 1ps

interface transaction_if # (
  parameter BIT_DEPTH = 8
);
  logic [BIT_DEPTH-1:0] data;
  logic                 valid;
endinterface


module arbiter # ( 
  parameter BIT_DEPTH = 8
) (
  input   logic   clk,
  input   logic   arst,
  output  logic   ready_o [3:0],
  transaction_if  t_1_i,
  transaction_if  t_2_i,
  transaction_if  t_3_i,
  transaction_if  t_4_i,
  transaction_if  t_o
);
 
  typedef enum logic [1:0] {
      IDLE
    , SCHEDULE
    , PASS
  } state_e;

  state_e current_state = IDLE;
  state_e next_state    = IDLE;
  
  logic [3:0] req;
  logic       req_status;
  
  assign req = {t_1_i.valid,
                t_2_i.valid, 
                t_3_i.valid,
                t_4_i.valid};
  assign req_status = | req;
  
  logic [3:0] grant;
  
  assign grant = {req[0], 
                  ~req[0] & req[1], 
                  ~req[0] & ~req[1] & req[2], 
                  ~req[0] & ~req[1] & ~req[2] & req[3]};

  // get next state
  always_comb
  begin
    next_state = current_state;
    case (current_state)
      IDLE      : if (req_status)   next_state = SCHEDULE;
      SCHEDULE  :                   next_state = PASS;
      PASS      : if (!req_status)  next_state = SCHEDULE;
      default: next_state = IDLE;
    endcase
  end
  
  // update state
  always_ff @(posedge clk or posedge arst)
  begin
    if (arst) current_state <= IDLE;
    else      current_state <= next_state;
  end
  
  // define output value
  always_comb
  begin
    case (current_state)
      IDLE: begin
        ready_o = {'d1, 'd1, 'd1, 'd1};
      end
      SCHEDULE: begin
        ready_o = {'d0};
        t_o.valid = 'd0;
        case (grant)
          4'b0001: t_o.data = t_1_i.data;
          4'b0010: t_o.data = t_2_i.data;
          4'b0100: t_o.data = t_3_i.data;
          4'b1000: t_o.data = t_4_i.data;
        endcase
      end
      PASS: begin
        t_o.valid = 'd1;
      end
      default: ;
    endcase
  end

endmodule
