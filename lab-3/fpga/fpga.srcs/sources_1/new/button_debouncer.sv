`timescale 1ns / 1ps

module button_debouncer # (
  parameter WAIT_TIME = 100_000
) (
  input   logic clk,
  input   logic btn_i,
  output  logic btn_o
);

  logic is_waiting = 0;
  
  logic [31:0] count = 0;
  
  logic btn_curr = 0;
  
  always_ff @(posedge clk)
  begin
    if (!is_waiting && btn_i != btn_curr)
    begin
       is_waiting <= 1;
       count <= 0;
       btn_curr <= btn_i;
    end
    else 
    begin
      if (count == WAIT_TIME)
      begin
        is_waiting <= 0; 
        if (btn_curr == btn_i) btn_o <= btn_curr;
      end
      else count <= count + 1;
    end
  end
endmodule
