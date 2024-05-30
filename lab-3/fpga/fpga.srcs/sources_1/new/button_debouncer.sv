`timescale 1ns / 1ps

module button_debouncer # (
  parameter BIT_DEPTH = 32,
  parameter WAIT_TIME = 100_000
) (
  input   logic clk,
  input   logic arstn,
  input   logic btn_i,
  
  output  logic btn_state_o,
  output  logic btn_up_o,
  output  logic btn_down_o
);

  enum logic [1:0] {
    UP_IDLE, UP_WAIT,
    DOWN_IDLE, DOWN_WAIT
  } curr_state, next_state;

  
  logic [BIT_DEPTH-1:0] count;
  
  logic timeout_f;
  assign timeout_f = (count == WAIT_TIME);
  
  logic initial_btn_i;
  
  logic change_f;
  assign change_f = (btn_i != initial_btn_i);
  
  logic wait_f;
  assign wait_f = (curr_state == UP_WAIT || curr_state == DOWN_WAIT);
  
  always_comb
  begin
    next_state = curr_state;
    case (curr_state)
      UP_IDLE: if (change_f)  next_state = UP_WAIT;
      UP_WAIT: if (timeout_f) next_state = DOWN_IDLE;
      DOWN_IDLE: if (change_f)  next_state = DOWN_WAIT;
      DOWN_WAIT: if (timeout_f) next_state = UP_IDLE;
    endcase
  end
  
  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn) curr_state <= UP_IDLE;
    else        curr_state <= next_state;
  end
  
  always_ff @(posedge clk)
  begin
    if (wait_f) count <= count + 1;
    else       
    begin
      count <= 0;
      initial_btn_i <= btn_i;
    end
  end
  
  always_comb
  begin
    case (curr_state)
      UP_IDLE:
      begin
        btn_state_o = 0;
        btn_up_o = 0;
        btn_down_o = 0;
      end
      UP_WAIT: 
      begin
        btn_up_o = 1;
      end
      DOWN_IDLE:
      begin
        btn_state_o = 1;
        btn_up_o = 0;
        btn_down_o = 0;
      end
      DOWN_WAIT:
      begin
        btn_down_o = 1;
      end
    endcase
  end

endmodule
