`timescale 1ns / 1ps


module count_free_func # (
  parameter BIT_DEPTH = 8
) (
  input   logic clk,
  input   logic arst,
  input   logic start_req_i,
  input   logic start_data_i,
  input   logic ready_i,
  output  logic result_rsp_o,
  output  logic busy_o
);

  typedef enum logic [2:0] {
      IDLE  // 1
    , READ  // 2
    , COUNT // 3
    , AWAIT // 4
    , WRITE // 5
  } state_e;

  state_e current_state = IDLE;
  state_e next_state = IDLE;
  
  logic                 reset_reader;
  logic                 enable_reader;
  logic                 next_bit;
  logic [BIT_DEPTH-1:0] reader_output;

  logic                 reset_timer;
  logic                 enable_count;
  logic                 set_count;
  logic [BIT_DEPTH-1:0] counter_input;
  logic [BIT_DEPTH-1:0] remaining_time;
    
  shiftreg # (
    .BIT_DEPTH ( BIT_DEPTH ),
    .TO_HIGHT  ( 1         )
  ) reader (
    .clk      ( clk           ),
    .arst     ( reset_reader  ), 
    .enable   ( enable_reader ),
    .load_i   (),
    .shift_i  ( next_bit      ),
    .data_i   (),
    .data_o   ( reader_output ),
    .shift_o  ()
  );
  
  counter # (
    .BIT_DEPTH ( BIT_DEPTH ),
    .TO_DOWN   ( 1         )
  ) timer (
    .clk      ( clk             ),
    .arst     ( reset_timer     ),
    .enable_i ( enable_count    ),
    .set_i    ( set_count       ), 
    .count_i  ( counter_input   ),
    .count_o  ( remaining_time  )
  );

  assign counter_input = reader_output;

  // determine next state
  always_comb 
  begin
    next_state = current_state;
    case (current_state)
      IDLE  : if (start_req_i)      next_state = READ;
      READ  : if (!start_req_i)     next_state = COUNT;
      COUNT : if (!remaining_time)  next_state = AWAIT;
      AWAIT : if (ready_i)          next_state = WRITE;
      WRITE :                       next_state = IDLE;

      default: next_state = IDLE;
    endcase
  end

  // perform actions during current state
  always_comb 
  begin
    case (current_state)
      IDLE: begin
        reset_reader = 'd1;
        reset_timer  = 'd1;
      end
      READ: begin
        reset_reader  = 'd0;
        enable_reader = 'd1;
        next_bit      = start_data_i;
        enable_count  = 'd1;
        set_count     = 'd1;
      end
      COUNT: begin
        enable_reader = 'd0;
        enable_count  = 'd1;
        set_count     = 'd0;
      end
 
      default: begin
        enable_count = 'd0;
        reset_reader = 'd1;
        reset_timer  = 'd1;
      end
    endcase
  end

  // change current state
  always_ff @(posedge clk or posedge arst)
  begin
    if (arst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // determine output according to current state
  always_comb
  begin
    case(current_state)
      IDLE: begin
        busy_o       = 'd0;
        result_rsp_o = 'd0;
      end
      READ: begin
        busy_o       = 'd1;
        result_rsp_o = 'd0;
      end
      COUNT: begin
        busy_o       = 'd1;
        result_rsp_o = 'd0;
        // exclude extra delay before response
        if (next_state == AWAIT) result_rsp_o = 'd1;
      end
      AWAIT: begin
        busy_o       = 'd1;
        result_rsp_o = 'd1;
      end
      WRITE: begin
        busy_o       = 'd1;
        result_rsp_o = 'd1;
      end
    endcase    
  end

endmodule
