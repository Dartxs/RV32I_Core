module Hexdisp_Mux(
    input clk,
    input rst_n,
    input [3:0] led7, led6, led5, led4, led3, led2, led1, led0,
    output reg [7:0] sseg,
    output reg [7:0] an
    );

    localparam A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7;
    reg [16:0] clkdiv;
    reg [3:0] hex_out;
    reg [3:0] led_state, next;


    always @(*) begin
        case(led_state)
            A: begin
                hex_out = led0;
                next = B;
                an = 8'b11111110;
            end
            B: begin
                hex_out = led1;
                next = C;
                an = 8'b11111101;
            end
            C: begin
                hex_out = led2;
                next = D;
                an = 8'b11111011;
            end
            D: begin
                hex_out = led3;
                next = E;
                an = 8'b11110111;
            end
            E: begin
                hex_out = led4;
                next = F;
                an = 8'b11101111;
            end
            F: begin
                hex_out = led5;
                next = G;
                an = 8'b11011111;
            end
            G: begin
                hex_out = led6;
                next = H;
                an = 8'b10111111;
            end
            H: begin
                hex_out = led7;
                next = A;
                an = 8'b01111111;
            end
        endcase
        case (hex_out)
            4'h0: sseg = 8'b11000000;
            4'h1: sseg = 8'b11111001;
            4'h2: sseg = 8'b10100100;
            4'h3: sseg = 8'b10110000;
            4'h4: sseg = 8'b10011001;
            4'h5: sseg = 8'b10010010;
            4'h6: sseg = 8'b10000010;
            4'h7: sseg = 8'b11111000;
            4'h8: sseg = 8'b10000000;
            4'h9: sseg = 8'b10011000;
            4'ha: sseg = 8'b10100000;
            4'hb: sseg = 8'b10000111;
            4'hc: sseg = 8'b10100111;
            4'hd: sseg = 8'b10100001;
            4'he: sseg = 8'b10000110;
            4'hf: sseg = 8'b10001110;
        endcase
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            led_state <= H;
            clkdiv <= 0;
        end else begin
            if(clkdiv == 27'd99999) begin
                led_state <= next;
                clkdiv <= 0;
            end else
                clkdiv <= clkdiv + 1;
        end
    end

endmodule
