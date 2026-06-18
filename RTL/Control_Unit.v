module Control_Unit(
    input branch_taken,
    input [6:0] opcode,
    output reg [1:0] PC_Sel, writeback_ctrl,
    output reg ALU_op1_ctrl, ALU_op2_ctrl, mem_write, mem_read, reg_write
    );

    localparam load_ins = 7'b00_000_11, store_ins = 7'b01_000_11, branch_ins = 7'b11_000_11, jalr_ins = 7'b11_001_11, 
               jal_ins = 7'b11_011_11, opimm_ins = 7'b00_100_11, opR_ins = 7'b01_100_11, auipc_ins = 7'b00_101_11, 
               lui_ins = 7'b01_101_11;

   localparam WB_ALU = 0, WB_mem = 1, WB_def_PC = 2, WB_imm = 3;
   localparam PC_default = 0, PC_BR_JAL = 1, PC_JALR = 2;

    always @(*) begin
        mem_write = 0; mem_read = 0; reg_write = 0; //default: mem write, mem read, reg write off
        ALU_op1_ctrl = 0; ALU_op2_ctrl = 0; PC_Sel = PC_default; //default: use data from registers for ALU op1 and op2, PC = PC+4
        writeback_ctrl = WB_ALU; //default: reg write data from ALU
        case(opcode)
            load_ins: begin 
                mem_read = 1; //read from memory
                reg_write = 1; //write to register file
                ALU_op2_ctrl = 1; //use immediate for ALU op2 to calculate offset
                writeback_ctrl = WB_mem; //write to register from memory
            end
            store_ins: begin
                mem_write = 1; //write to memory
                ALU_op2_ctrl = 1; //use immediate for ALU op2 to calculate offset
            end    
            branch_ins: begin
                PC_Sel = (branch_taken) ? PC_BR_JAL : PC_default; //determine whether to jump based on branch bit
            end
            jalr_ins: begin
                reg_write = 1; //write to register file
                PC_Sel = PC_JALR; //use jalr for next PC
                writeback_ctrl = WB_def_PC; //write PC to register file
            end
            jal_ins: begin
                reg_write = 1; //write to register file
                PC_Sel = PC_BR_JAL; //use jal for next PC 
                writeback_ctrl = WB_def_PC; //write PC to register file
            end   
            opimm_ins: begin
                reg_write = 1; //write to register file
                ALU_op2_ctrl = 1; //use immediate for ALU op2
                writeback_ctrl = WB_ALU; //write ALU results to register file
            end    
            opR_ins: begin
                reg_write = 1; //write to register file
                writeback_ctrl = WB_ALU; //write ALU results to register file
            end  
            auipc_ins: begin
                reg_write = 1; //write to register file
                ALU_op1_ctrl = 1; //use PC for ALU op1
                ALU_op2_ctrl = 1; //use immediate for ALU op2
                writeback_ctrl = WB_ALU; //write ALU results to register file
            end    
            lui_ins: begin
                reg_write = 1; //write to register file
                writeback_ctrl = WB_imm; //write immediate value to register file
            end
            default: ;
        endcase
    end
endmodule
