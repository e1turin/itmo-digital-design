`timescale 1ns / 1ps


module arbiter_tb;

  localparam N = 8; 
  
  logic clk = 0;
  logic arst = 1;
  logic ready;
  
  logic [N-1:0] t_data_i [3:0], t_data_o;
  logic [N-1:0] t_valid_i;
  logic         t_valid_o;

  logic [N-1:0] test_data_out;
  assign test_data_out = t_data_o;

  logic test_valid_out;
  assign test_valid_out = t_valid_o;

  arbiter # ( 
    .BIT_DEPTH ( N )
  ) dut ( 
     .clk       ( clk       ),
     .arstn     ( arst      ),
     .ready_o   ( ready     ),
     .t_data_i  ( t_data_i  ),
     .t_valid_i ( t_valid_i ),
     .t_data_o  ( t_data_o  ),
     .t_valid_o ( t_valid_o )
  );

  logic [N-1:0] test_data_1 = 10;
  logic [N-1:0] test_data_2 = 11;
  logic [N-1:0] test_data_3 = 12;
  logic [N-1:0] test_data_4 = 13;
  
  always #10 clk = ~clk;

  initial
  begin
    t_valid_i = 'd0;

    #15 arst = 'd0;
    #10 arst = 'd1;
    #5;
    if (!ready) $error("Arbiter not ready after reset");

    #10;
    t_data_i = {test_data_1, 
                test_data_2,
                test_data_3,
                test_data_4};
    
    #5;
    t_valid_i = 4'b0011;

    repeat(2)
    begin
      @(posedge clk);
      #5 $display("data out = %0d and valid = %0d", test_data_out, test_valid_out);
      if (ready) $error("Arbiter ready when transaction exists");
    end
    
    t_valid_i = 4'b0000;
    
    @(posedge clk);
    #5;
    t_valid_i = 4'b0111;
    
    repeat(3)
    begin
      @(posedge clk);
      #5 $display("data out = %0d and valid = %0d", test_data_out, test_valid_out);
      if (ready) $error("Arbiter ready when transaction exists");
    end
    
    #20 $finish;
  end

endmodule
