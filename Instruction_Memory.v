`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2026 09:46:31 PM
// Design Name: 
// Module Name: Instruction_Memory
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


module Instruction_Memory(
    input [31:0] PC, //uses  PC to determine address location to fetch memory
    output reg [31:0] instruction
    );
    
    reg [7:0] rom [1023:0]; //byte addressed read-only memory (RV32i standard), 1024/4 = 256 instructions storable 
    
    initial begin
        $readmemh("program.mem", rom); //use .mem file as instruction memory
    end
    
    always @(*) begin
        instruction = {rom[PC+3], //stored in little endian
                       rom[PC+2],
                       rom[PC+1],
                       rom[PC]};
    end

endmodule
