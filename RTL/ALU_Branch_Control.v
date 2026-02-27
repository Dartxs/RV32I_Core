module ALU_Branch_Control(
    input [6:0] opcode, funct7,
    input [2:0] funct3,
    output reg [3:0] ALU_op,
    output reg [2:0] branch_op
    );
    
    localparam load_ins = 7'b00_000_11, store_ins = 7'b01_000_11, branch_ins = 7'b11_000_11, jalr_ins = 7'b11_001_11, 
               jal_ins = 7'b11_011_11, opimm_ins = 7'b00_100_11, opR_ins = 7'b01_100_11, auipc_ins = 7'b00_101_11, 
               lui_ins = 7'b01_101_11;
    
    localparam add_op = 0, sub_op = 1, sll_op = 2, slt_op = 3, sltu_op = 4, 
               xor_op = 5, srl_op = 6, sra_op = 7, or_op = 8, and_op = 9; 
                                      
    localparam beq = 0, bne = 1,  blt = 2, bge = 3, bltu = 4, bgeu = 5;
    
    always @(*) begin
        ALU_op = add_op;
        branch_op = beq;
        
        if(opcode == opR_ins || opcode == opimm_ins) begin
            case(funct3)
                3'b000: ALU_op = (opcode == opR_ins && funct7[5]) ? sub_op : add_op;
                3'b001: ALU_op = sll_op;
                3'b010: ALU_op = slt_op;
                3'b011: ALU_op = sltu_op;
                3'b100: ALU_op = xor_op;
                3'b101: ALU_op = (funct7[5]) ? sra_op : srl_op;
                3'b110: ALU_op = or_op;
                3'b111: ALU_op = and_op;
            endcase
        end
        
        if(opcode == branch_ins) begin
            case(funct3)
                3'b000: branch_op = beq;
                3'b001: branch_op = bne;
                3'b100: branch_op = blt;
                3'b101: branch_op = bge;
                3'b110: branch_op = bltu;
                3'b111: branch_op = bgeu;
            endcase
        end   
    end         
endmodule
