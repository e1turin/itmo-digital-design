`timescale 1ns / 1ps

module decoder_tb;

    reg [2:0] s;
    wire[7:0] d_golden, d_test;
    reg en;
    integer i;
    
    decoder_golden decoder_goldn(
        .s(s),
        .en(en),
        .d(d_golden)
    );
    
    decoder decoder_test(
        .s(s),
        .en(en),
        .d(d_test)
    );
    
    
    initial begin
        for(i = 0; i < 8; i = i+1) begin
            s = i;
            en = 1;
            
            #10

            if (d_test == d_golden) begin
                $display("OK: s=%b, d=%b, en=%b, i=%0d", s, d_test, en, i);
            end 
            else 
            begin
                $display("Fail: s=%b, d=%b, en=%b, i=%0d", s, d_test, en, i);
                $display("Expect: s=%b, d=%b, en=%b, i=%0d", s, d_golden, en, i);
            end

            en = 0;
             
            #10

            if (d_test == d_golden) begin
                $display("OK: s=%b, d=%b, en=%b, i=%0d", s, d_test, en, i);
            end 
            else 
            begin
                $display("Fail: s=%b, d=%b, en=%b, i=%0d", s, d_test, en, i);
                $display("Expect: s=%b, d=%b, en=%b, i=%0d", s, d_golden, en, i);
            end
         end
         #10 $stop;
    end
endmodule

