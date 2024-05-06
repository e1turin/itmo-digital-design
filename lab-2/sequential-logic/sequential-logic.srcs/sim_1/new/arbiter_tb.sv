`timescale 1ns / 1ps


module arbiter_tb;

  localparam N = 8; 
  
  logic clk = 0;
  logic arst = 'd0;
  logic ready;

  transaction_if # ( .BIT_DEPTH ( N ) )  t_1();
  transaction_if # ( .BIT_DEPTH ( N ) )  t_2();
  transaction_if # ( .BIT_DEPTH ( N ) )  t_3();
  transaction_if # ( .BIT_DEPTH ( N ) )  t_4();

  transaction_if # ( .BIT_DEPTH ( N ) )  t_o();

  logic [N-1:0] test_data_out;
  assign test_data_out = t_o.data;

  logic test_valid_out;
  assign test_valid_out = t_o.valid;

  arbiter # ( 
    .BIT_DEPTH ( N )
  ) dut ( 
     .clk     ( clk   ),
     .arst    ( arst  ),
     .ready_o ( ready ),
     .t_1_i   ( t_1.RCV ),
     .t_2_i   ( t_2.RCV ),
     .t_3_i   ( t_3.RCV ),
     .t_4_i   ( t_4.RCV ),
     .t_o     ( t_o.SND )
  );

  logic [N-1:0] test_data_1 = 10;
  logic [N-1:0] test_data_2 = 11;
  logic [N-1:0] test_data_3 = 12;
  logic [N-1:0] test_data_4 = 13;
  
  always #10 clk = ~clk;

  initial
  begin
    t_1.valid = 'd0;
    t_2.valid = 'd0;
    t_3.valid = 'd0;
    t_4.valid = 'd0;
    #15 arst = 'd1;
    #10  arst = 'd0;
    #5;
    if (!ready) $error("Arbiter not ready after reset");

    #10;
    t_1.data = test_data_1;
    t_2.data = test_data_2;
    t_3.data = test_data_3;
    t_4.data = test_data_4;
    
    #5;
    t_1.valid = 'd1;
    t_2.valid = 'd1;

    #5;
    if (ready) $error("Arbiter ready when transaction exists");
    
    repeat(2)
    begin
      @(posedge clk);
      $display("data out = %0d and valid = %0d", test_data_out, test_valid_out);
    end
    
    #5;
    t_1.valid = 'd0;
    t_2.valid = 'd1;
    t_3.valid = 'd1;
    t_4.valid = 'd1;
    
    repeat(3)
    begin
      @(posedge clk);
      $display("data out = %0d and valid = %0d", test_data_out, test_valid_out);
    end
    
    #20;
//    #10 $display("%0d = %0d and %0d", test_data, test_data_out, test_valid_out);
    $finish;
  end

endmodule
