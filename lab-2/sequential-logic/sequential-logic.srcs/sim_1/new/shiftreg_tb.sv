`timescale 1ns / 1ps

module shiftreg_tb;

  localparam N = 8;

  logic clk = 0;
  logic rst = 0;

  logic         test_enable;
  logic         test_load = 0;
  logic         test_shift_input;
  logic [N-1:0] test_data_input;
  logic [N-1:0] test_data_output;
  logic         test_shift_output;

  shiftreg # (
    .BIT_DEPTH ( N )
  ) sr (
    .clk      ( clk ),
    .arst     ( rst ),  
    .enable   ( test_enable ),
    .load_i   ( test_load ),
    .shift_i  ( test_shift_input ),
    .data_i   ( test_data_input ),
    .data_o   ( test_data_output ),
    .shift_o  ( test_shift_output )
  );
  
  always #10 clk = ~clk;
  
  logic [N-1:0] data = 'd6;
  logic [N-1:0] init_data = data;

  
  initial
  begin
    #15 rst = 1;
    #5;
    if (test_data_output) $error("Data output not cleared");

    #10 rst = 0;
    
    #5 test_enable = 'd1;
    
    repeat(N)
    begin
      @(posedge clk);
      test_shift_input = data[N-1];
      #5 data <<= 1;
    end
    
    #5 test_enable = 'd0;
    
    #15;
    
    if (test_data_output != init_data) $error("Incorrect reading");
    
    #20;
    
    $stop;
  end
  

endmodule
