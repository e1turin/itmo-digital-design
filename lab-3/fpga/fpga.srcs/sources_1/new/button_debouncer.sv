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

  logic [BIT_DEPTH-1:0] count;
  
  logic timeout_f;
  assign timeout_f = (count == 0);

  // move to different clock domain
  always_ff @(posedge clk, negedge arstn)
  begin
    if (!arstn || count == WAIT_TIME) 
      count <= 0;
    else
      count <= count + 1;
  end

  logic change_f;
  assign change_f = (btn_state_o != btn_i);

  // update button state
  always_ff @(posedge clk, negedge arstn)
  begin
    if (!arstn)                     btn_state_o <= btn_i;
    else if (timeout_f && change_f) btn_state_o <= ~btn_state_o;
  end

  // update button events
  always_ff @(posedge clk, negedge arstn)
  begin
    if (!arstn) 
    begin
      btn_up_o   <= 0;
      btn_down_o <= 0;
    end
    else
    begin
      btn_up_o   <= change_f & timeout_f & ~btn_state_o;
      btn_down_o <= change_f & timeout_f & btn_state_o;
    end
  end

endmodule
