`timescale 1ns / 1ps


module count_free_func_tb;

  localparam N = 8;
  
  logic clk = 0;
  logic rst = 0;
  
  logic test_start_req = 0;
  logic test_start_data = 0;
  logic test_ready = 0;
  logic test_result_rsp;
  logic test_busy;
  
  count_free_func # (
    .BIT_DEPTH ( N )
  ) dut (
    .clk          ( clk             ),
    .rst          ( rst             ),
    .start_req_i  ( test_start_req  ),
    .start_data_i ( test_start_data ),
    .ready_i      ( test_ready           ),
    .result_rsp_o ( test_result_rsp      ),
    .busy_o       ( test_busy            )
  );
  
  always #10 clk = ~clk;

  logic [N-1:0] data = 'd5;
  logic [N-1:0] init_data = data;

  int busy_iter = 0;
  
  initial
  begin
    #15 rst = 1;
    #10 rst = 0;

    #25 test_start_req = 1;
    
    repeat(N)
    begin
      @(posedge clk);
      test_start_data = data[N-1];
      data <<= 1;
    end
    @(posedge clk);
    
    #5 test_start_req = 0;
    @(posedge clk);

    repeat(init_data + 1) // ????? wait +1 cycle because of state change  
    begin
      @(posedge clk);
      if (!test_busy) $error("DUT is not busy on iteration = %0d", busy_iter);
      busy_iter += 1;
    end

    @(posedge clk);
//    if (test_busy) $error("DUT is busy after waiting");
    if (!test_result_rsp) $error("DUT have no result");
    
    #35;
    if (!test_result_rsp) $error("DUT dropped result before ready");
    test_ready = 1;
    
    @(posedge clk);
    if (!test_result_rsp) $error("DUT dropped result too early");
    @(posedge clk);
    if (test_result_rsp) $error("DUT have not dropped result");
    
    #20 $finish;
  end

endmodule
