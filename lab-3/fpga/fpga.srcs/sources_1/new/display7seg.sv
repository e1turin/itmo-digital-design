`timescale 1ns / 1ps

module display7seg (
  input   logic       clk,
  input   logic       arstn,
  input   logic [2:0] data_i,
  input   logic [3:0] number_i,
  output  logic [7:0] DIGITS_o,
  output  logic [7:0] SEGMENTS_o
);
  localparam FREQ_DIV_BIT_DEPTH = 32;
  localparam FREQ_DIV_RATE = 100_000;
  localparam DATA_DEPTH = 3;
  localparam NUMBER_DEPTH = 4;
  localparam N_DIGITS = 8;

  typedef enum logic { ON = 0, OFF = 1 } enable_e;
  typedef enum logic [7:0]
  { //      {a,   b,    c,    d,    e,    f,    g,    p  }
    SPACE = {8{OFF}},
    X0    = {ON,  ON,   ON,   ON,   ON,   ON,   OFF,  OFF},
    X1    = {OFF, ON,   ON,   OFF,  OFF,  OFF,  OFF,  OFF},
    X2    = {ON,  ON,   OFF,  ON,   ON,   OFF,  ON,   OFF},
    X3    = {ON,  ON,   ON,   ON,   OFF,  OFF,  ON,   OFF},
    X4    = {OFF, ON,   ON,   OFF,  OFF,  ON,   ON,   OFF},
    X5    = {ON,  OFF,  ON,   ON,   OFF,  ON,   ON,   OFF},
    X6    = {ON,  OFF,  ON,   ON,   ON,   ON,   ON,   OFF},
    X7    = {ON,  ON,   ON,   OFF,  OFF,  OFF,  OFF,  OFF},
    X8    = {ON,  ON,   ON,   ON,   ON,   ON,   ON,   OFF},
    X9    = {ON,  ON,   ON,   ON,   OFF,  ON,   ON,   OFF},
    ERROR = {OFF, OFF,  OFF,  OFF,  OFF,  OFF,  ON,   ON}
  } 
  seven_seg_encoding_e;
  
  enable_e [N_DIGITS-1:0] digits;
  assign DIGITS_o = digits;
  
  seven_seg_encoding_e show_number;
  seven_seg_encoding_e show_data;
    
  logic left_part_f;
  // "if all the right side signals are not enabled"
  assign left_part_f = &(digits[3:0]^{4{ON}});
  
  assign SEGMENTS_o = left_part_f ? show_number : show_data;

  // decode data & transaction number
  always_comb
  begin
    if(!number_i)
    begin
      show_number = SPACE;
      show_data   = SPACE;
    end
    else
    begin
      case(data_i)
        'b000: show_data = X0;
        'b001: show_data = X1;
        'b010: show_data = X2;
        'b011: show_data = X3;
        'b100: show_data = X4;
        'b101: show_data = X5;
        'b110: show_data = X6;
        'b111: show_data = X7;

        default: show_data = ERROR;
      endcase

      case(number_i)
        'b0001: show_number = X1;
        'b0010: show_number = X2;
        'b0100: show_number = X3;
        'b1000: show_number = X4;

        default: show_number = ERROR;
      endcase
    end
  end
  
  logic div_clk;

  freqdiv # (
    .BIT_DEPTH ( FREQ_DIV_BIT_DEPTH ),
    .MAX_COUNT ( FREQ_DIV_RATE      )
  ) fd (
    .clk_i  ( clk     ),
    .arstn  ( arstn   ),
    .clk_o  ( div_clk )
  );

  // update illuminated digit position
  always_ff @(posedge div_clk or negedge arstn)
  begin
    if (!arstn) digits <= {{7{OFF}}, ON};
    else        digits <= {digits[N_DIGITS-2:0], digits[N_DIGITS-1]};
  end

endmodule
