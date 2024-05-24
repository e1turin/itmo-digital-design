`timescale 1ns / 1ps

module display7seg (
  input   logic       clk,
  input   logic       arstn,
  input   logic [2:0] data,
  input   logic [3:0] number,
  output  logic [7:0] DIGITS,
  output  logic [7:0] SEGMENTS
);

  localparam DATA_DEPTH = 3;
  localparam NUMBER_DEPTH = 4;
  localparam N_DIGITS = 8;

  typedef enum bit { ON = 0, OFF = 1 } enable_segment_e;
  typedef enum bit [7:0]
  { 
////              abcdefgp
//    SPACE = !8'b00000000,
//    X0    = !8'b11111100,
//    X1    = !8'b01100000,
//    X2    = !8'b11011010,
//    X3    = !8'b11110010,
//    X4    = !8'b01100110,
//    X5    = !8'b10110110,
//    X6    = !8'b10111110,
//    X7    = !8'b11100000,
//    X8    = !8'b11111110,
//    X9    = !8'b11110110,
//    ERROR = !8'b00000011  

//          {a,   b,    c,    d,   e,    f,    g,    p   }
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
  
  logic [N_DIGITS-1:0] digit;
  
  seven_seg_encoding_e show_number;
  seven_seg_encoding_e show_data;

  // decode data & transaction number
  always_comb
  begin
    if(!number)
    begin
      show_number = SPACE;
      show_data   = SPACE;
    end
    else
    begin
      case(data)
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

      case(number)
        'b0001: show_number = X1;
        'b0010: show_number = X2;
        'b0100: show_number = X3;
        'b1000: show_number = X4;

        default: show_number = ERROR;
      endcase
    end
  end

  // update illuminated digit position
  always_ff @(posedge clk or negedge arstn)
  begin
    if (!arstn) digit <= 'b1;
    else        digit <= {digit[N_DIGITS-2:0], digit[N_DIGITS-1]};
  end
  
  // split display in 2 equal parts: number & data
  always_comb
  begin
    DIGITS = digit;
    
    if (digit > 8'b0000_1111) SEGMENTS = show_number;
    else                      SEGMENTS = show_data;
  end

endmodule
