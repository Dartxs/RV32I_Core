`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2026 03:10:45 PM
// Design Name: 
// Module Name: instruction_decoder
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


module Instruction_Decoder(
    input [31:0] instruction,
    output [6:0] opcode, 
    output [2:0] funct3,
    output [6:0] funct7,
    output [4:0] rs1, rs2, rd,
    output [31:0] imm 
    );
    
    Imm_Gen imm_gen(.instruction(instruction), .imm(imm));
    
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign opcode = instruction[6:0];
    
endmodule
