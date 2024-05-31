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
  logic btn_i_old;
  logic btn_i_new;
  logic timeout_f;
  assign timeout_f = (count == WAIT_TIME);
  logic change_f;
  assign change_f = (btn_i_old != btn_i_new);
  logic wait_f;
//  assign wait_f = (!timeout_f && change_f);

  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn) wait_f <= 0;
    else        wait_f <= !wait_f 
                          ? change_f
                          : (wait_f && !timeout_f);
  end
    
  always_ff @(posedge clk or negedge arstn) 
  begin
    if (!arstn) begin
      btn_i_old <= btn_i;
      btn_i_new <= btn_i;
    end 
    else
    begin
      btn_i_old <= wait_f ? btn_i_old : btn_i_new;
      btn_i_new <= btn_i;
    end
  end
  
  
  always_ff @(posedge clk)
  begin
    count <= wait_f ? count + 1 : 0;
  end
  
  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn) btn_state_o <= btn_i;
    else 
      if (timeout_f) btn_state_o <= change_f ? btn_i_old : btn_i_new;
  end
  
  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn || !timeout_f || change_f)
    begin
      btn_down_o <= 0;
      btn_up_o   <= 0;
    end
    else
    begin
      btn_down_o <= btn_i_old;
      btn_up_o   <= !btn_i_old;
    end
  end

endmodule
