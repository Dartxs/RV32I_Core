`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2026 04:19:01 PM
// Design Name: 
// Module Name: mem_aligner
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mem_Aligner(
    input [2:0] funct3,
    input [1:0] address,
    output reg aligned, sign,
    output reg [3:0] byte_ena
    );
    
    wire [1:0] even_address = {address[1], 1'b0}; //Use even address for halfword stores/loads
    
    always @(*) begin
        aligned = 0; sign = 1;
        byte_ena = 4'b0000;
        case(funct3) 
            3'b000: begin
                aligned = 1; //no need to check for alignment for single byte 
                byte_ena[address] = 1'b1; 
            end
            3'b001: begin
                aligned = (address == 2'b00 || address == 2'b10); //ensure read/write address is aligned for halfword
                if(aligned)
                    byte_ena[even_address +: 2] = 2'b11; //enable byte read/write to start at 1st or 3rd byte of address
            end 
            3'b010: begin
                aligned = (address == 2'b00); //check read/write address is at byte 0
                if(aligned)
                    byte_ena = 4'b1111; //enable all bytes for read/write
            end
            3'b100: begin
                aligned = 1; //single byte
                sign = 0; //unsigned
                byte_ena[address] = 1'b1;
            end
            3'b101: begin
                aligned = (address == 2'b00 || address == 2'b10); 
                sign = 0; //unsigned
                if(aligned)
                    byte_ena[even_address +: 2] = 2'b11; 
            end
            default: begin //ensure no reads/writes are allowed for invalid funct3 input 
                aligned = 0; 
                byte_ena = 4'b0; 
            end      
        endcase   
    end 
endmodule
