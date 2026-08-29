module Imm_Gen( //everything here follows RV32i ISA
    input [31:0] instr,
    output reg [31:0] imm
    );

    localparam [6:0] load_ins = 7'b00_000_11, store_ins = 7'b01_000_11, branch_ins = 7'b11_000_11, jalr_ins = 7'b11_001_11, 
               jal_ins = 7'b11_011_11, opimm_ins = 7'b00_100_11, /*opR_ins = 7'b01_100_11,*/ auipc_ins = 7'b00_101_11, 
               lui_ins = 7'b01_101_11;

    wire [6:0] opcode = instr[6:0];
    wire [31:0] i_imm, s_imm, b_imm, u_imm, j_imm; //For each instruction type I,S,B,J,U (R-type doesn't use an immediate)

    assign i_imm = { {20{instr[31]}}, instr[31:20] };
    assign s_imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };
    assign b_imm = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    assign u_imm = { instr[31:12], {12{1'b0}} };
    assign j_imm = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };

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
