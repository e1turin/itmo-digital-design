`timescale 1ns / 1ps


module arbiter_tb;

  localparam N = 32; 
  
  logic [N-1:0] data_i;
  logic [N-1:0] data_o;
  logic clk;

  transaction_if # ( .BIT_DEPTH ( N ) )  t_i();
  transaction_if # ( .BIT_DEPTH ( N ) )  t_o();

  arbiter # (
    .BIT_DEPTH ( N )
  ) arb ( 
     .clk ( clk ),
     .t_1_i ( t_i ),
     .t_2_i ( t_i ),
     .t_3_i ( t_i ),
     .t_4_i ( t_i ),
     .t_o ( t_o )
  );
  integer data = $random();
  initial
  begin
    #10 t_i.data = data;
    #10 t_i.valid = 1;
    #10 $display("%0d = %0d and %0d", data, t_o.data, t_o.valid);
    $finish;
  end

endmodule
