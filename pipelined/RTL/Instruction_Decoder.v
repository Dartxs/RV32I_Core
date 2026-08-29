module Instruction_Decoder(
    input [31:0] instr,
    output [2:0] funct3,
    output [4:0] rs1, rs2, rd,
    output [6:0] funct7,
    output [6:0] opcode,
    output [31:0] imm
    );

    Imm_Gen imm_gen(.instr(instr), .imm(imm));

    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign opcode = instr[6:0];

endmodule
