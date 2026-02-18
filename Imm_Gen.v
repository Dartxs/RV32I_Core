`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2026 03:12:30 PM
// Design Name: 
// Module Name: imm_gen
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


module Imm_Gen( //everything here follows RV32i ISA
    input [31:0] instruction,
    output reg [31:0] imm
    );
    
    localparam load_ins = 7'b00_000_11, store_ins = 7'b01_000_11, branch_ins = 7'b11_000_11, jalr_ins = 7'b11_001_11, 
               jal_ins = 7'b11_011_11, opimm_ins = 7'b00_100_11, /*opR_ins = 7'b01_100_11,*/ auipc_ins = 7'b00_101_11, 
               lui_ins = 7'b01_101_11;
    
    wire [6:0] opcode = instruction[6:0];
    wire [31:0] i_imm, s_imm, b_imm, u_imm, j_imm; //For each instruction type I,S,B,J,U (R-type doesn't use an immediate)
    
    assign i_imm = { {20{instruction[31]}}, instruction[31:20] }; 
    assign s_imm = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
    assign b_imm = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
    assign u_imm = { instruction[31:12], {12{1'b0}} };
    assign j_imm = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
    
    always @(*) begin
            case(opcode)
                load_ins: imm = i_imm;
                store_ins: imm = s_imm;
                branch_ins: imm = b_imm;
                jalr_ins: imm = i_imm;
                jal_ins: imm = j_imm;
                opimm_ins: imm = i_imm;
                auipc_ins: imm = u_imm;
                lui_ins: imm = u_imm;
                default: imm = 32'b0;
            endcase
       end
    
endmodule
