`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2026 02:57:25 PM
// Design Name: 
// Module Name: program_counter
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


module Program_Counter(
    input clk, reset,
    input [1:0] PC_Sel, //for selecting next PC
    input [31:0] op1, //for jalr
    input signed [31:0] imm, //for jalr and branch/jal
    output reg [31:0] PC, //
    output [31:0] default_PC //For return address after a jump
    );
    
    localparam PC_default = 0, PC_BR_JAL = 1, PC_JALR = 2;
    
    reg [31:0] new_PC;
    wire [31:0] jalr_PC, br_jal_PC; 
    
    assign default_PC = PC + 4;
    assign br_jal_PC = PC + imm;
    assign jalr_PC = op1 + imm;
    
    always @(*) begin
        case(PC_Sel)
            PC_default: new_PC = default_PC;
            PC_BR_JAL: new_PC = br_jal_PC;
            PC_JALR: new_PC = {jalr_PC[31:1], 1'b0}; //alignment
            default: new_PC = default_PC;
        endcase
    end
   
    always @(posedge clk) begin
        if(reset)
            PC <= 32'b0; //reset PC to 0 if, reset on
        else
            PC <= new_PC; 
    end
    
endmodule
