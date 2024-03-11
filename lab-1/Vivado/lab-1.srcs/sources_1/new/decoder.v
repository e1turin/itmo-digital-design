`timescale 1ns / 1ps

module decoder(
    input [2:0] s,
    input en,
    output [7:0] d
);
    wire [2:0] not_s;
    // split circuit in "vertival" layers
    // and not forget to use specific order of bits in 'd'
    wire [5:0] w_1; 
    wire [5:0] not_w_1;
    wire [7:0] w_2;
    wire [7:0] not_w_2;
    wire [7:0] w_3;
    
    nand(not_s[2], s[2], s[2]);
    nand(not_s[1], s[1], s[1]);
    nand(not_s[0], s[0], s[0]);
    
    nand(w_1[5], not_s[2], not_s[1]);
    nand(not_w_1[5], w_1[5], w_1[5]);
    
        nand(w_2[7], not_w_1[5], not_s[0]);
        nand(not_w_2[7], w_2[7], w_2[7]);
        nand(w_3[7], not_w_2[7], en);
        nand(d[0], w_3[7], w_3[7]);
        
        nand(w_2[6], not_w_1[5], s[0]);
        nand(not_w_2[6], w_2[6], w_2[6]);
        nand(w_3[6], not_w_2[6], en);
        nand(d[1], w_3[6], w_3[6]);
    
    nand(w_1[4], not_s[2], not_s[0]);
    nand(not_w_1[4], w_1[4], w_1[4]);
    nand(w_2[5], not_w_1[4], s[1]);
    nand(not_w_2[5], w_2[5], w_2[5]);
    nand(w_3[5], not_w_2[5], en);
    nand(d[2], w_3[5], w_3[5]);
    
    nand(w_1[3], s[1], s[0]);
    nand(not_w_1[3], w_1[3], w_1[3]);
    nand(w_2[4], not_w_1[3], not_s[2]); //
    nand(not_w_2[4], w_2[4], w_2[4]);
    nand(w_3[4], not_w_2[4], en);
    nand(d[3], w_3[4], w_3[4]);
    
    nand(w_1[2], not_s[1], not_s[0]);
    nand(not_w_1[2], w_1[2], w_1[2]);
    nand(w_2[3], not_w_1[2], s[2]);
    nand(not_w_2[3], w_2[3], w_2[3]);
    nand(w_3[3], not_w_2[3], en);
    nand(d[4], w_3[3], w_3[3]);
    
    nand(w_1[1], s[2], s[0]);
    nand(not_w_1[1], w_1[1], w_1[1]);
    nand(w_2[2], not_w_1[1], not_s[1]);
    nand(not_w_2[2], w_2[2], w_2[2]);
    nand(w_3[2], not_w_2[2], en);
    nand(d[5], w_3[2], w_3[2]);
    
    nand(w_1[0], s[2], s[1]);
    nand(not_w_1[0], w_1[0], w_1[0]);
        
        nand(w_2[1], not_w_1[0], not_s[0]);
        nand(not_w_2[1], w_2[1], w_2[1]);
        nand(w_3[1], not_w_2[1], en);
        nand(d[6], w_3[1], w_3[1]);
        
        nand(w_2[0], not_w_1[0], s[0]);
        nand(not_w_2[0], w_2[0], w_2[0]);
        nand(w_3[0], not_w_2[0], en);
        nand(d[7], w_3[0], w_3[0]);

endmodule
