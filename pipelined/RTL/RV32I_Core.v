module RV32I_Core(
    input clk, rst_n,
    input [4:0] dbug_addr,
    output [31:0] dbug_out
    );

    wire [31:0] PC, PCp4, next_PC;

    wire flushFD, flushDE;
    wire stallFD, stallDE;

    wire [31:0] instrD, PCD, PCp4D;

    wire [2:0] funct3;
    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode, funct7;
    wire [31:0] imm;

    wire [1:0] writeback_ctrl;
    wire ALUSrcA_Sel, ALUSrcB_Sel, mem_write, mem_read, reg_write, jal, jalr;

    wire [31:0] op1, op2;

    wire [2:0] branch_op;
    wire [3:0] ALU_op;

    wire ALUSrcA_SelE, ALUSrcB_SelE, mem_writeE, mem_readE, reg_writeE, jalE, jalrE;
    wire [1:0] writeback_ctrlE;
    wire [2:0] branch_opE, funct3E;
    wire [3:0] ALU_opE;
    wire [4:0] rdE;
    wire [31:0] PCE, PCp4E, immE, op1E, op2E;

    wire [31:0] ALU_out;

    wire branch_taken;

    wire mem_writeM, mem_readM, reg_writeM;
    wire [1:0] writeback_ctrlM;
    wire [2:0] funct3M;
    wire [4:0] rdM;
    wire [31:0] ALU_outM, PCp4M, op2Mv;

    wire [31:0] read_data;

    wire [1:0] writeback_ctrlW;
    wire [4:0] rdW;
    wire [31:0] ALU_outw, PCp4W, read_dataW;

    wire [31:0] writeback_data;

    PC_MUX pc_mux( //ADJUST INPUTS TO USE PIPELINE REGISTER OUTPUTS 
        .jal(jalE),
        .jalr(jalrE),
        .branch_taken(branch_taken), //branch unit output (execute stage)
        .op1(op1E),
        .imm(immE),
        .PC(PCE),
        .PCp4(PCp4),
        .next_PC(next_PC)   //output
    );

    PC_Reg pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .next_PC(next_PC), 
        .PC(PC),    //output 
        .PCp4(PCp4),    //output
    );

    Instruction_Memory instruction_memory(
        .PC(PC),
        .instr(instr)   //output
    );

    IF_ID if_id(
        .clk(clk),
        .rst_n(rst_n),
        .flush(flushFD),
        .stall(stallFD),
        .instrF(instr),
        .PCF(PC),
        .PCp4F(PCp4),
        .instrD(instrD),    //output
        .PCD(PCD),  //output
        .PCp4D(PCp4D)   //output
    );

    Instruction_Decoder instruction_decoder(
        .instr(instrD),
        .opcode(opcode),    //output
        .funct3(funct3),    //output
        .funct7(funct7),    //output
        .rs1(rs1),  //output
        .rs2(rs2),  //output
        .rd(rd),    //output
        .imm(imm)   //output
    );

    Control_Unit control_unit(
        .opcode(opcode),
        .writeback_ctrl(writeback_ctrl),    //output
        .ALUSrcA_Sel(ALUSrcA_Sel),  //output
        .ALUSrcB_Sel(ALUSrcB_Sel),  //output
        .mem_write(mem_write),  //output
        .mem_read(mem_read),    //output
        .reg_write(reg_write),  //output
        .jal(jal),  //output
        .jalr(jalr) //output
    );comes from 

    Register_File register_file( //ADJUST INPUTS TO USE FROM WB STAGE
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(reg_writeW)
        .rs1(rs1),comes from 
        .rs2(rs2),
        .rd(rdW),
        .dbug_addr(dbug_addr),
        .writeback_data(writeback_data),
        .op1(op1),  //output
        .op2(op2),  //output
        .dbug_out(dbug_out) //output
    );

    ALU_Branch_Control alu_branch_control(
        .func3(funct3), 
        .opcode(opcode),
        .funct7(funct7),
        .branch_op(branch_op), //output 
        .ALU_op(ALU_op) //output
    );

    ID_EX id_ex(
        .clk(clk),
        .rst_n(rst_n),
        .flush(flushDE),
        .stall(stallDE),
        .ALUSrcA_SelD(ALUSrcA_Sel),
        .ALUSrcB_SelD(ALUSrcB_Sel),
        .mem_writeD(mem_write),
        .mem_readD(mem_read),
        .reg_writeD(reg_write),
        .jalD(jal),
        .jalrD(jalr),
        .writeback_ctrlD(writeback_ctrl),
        .branch_opD(branch_op),
        .ALU_opD(ALU_op),
        .rdD(rd),
        .PCD(PCD),
        .PCp4D(PCp4D),
        .immD(imm), 
        .op1D(op1),
        .op2D(op2),
        .ALUSrcA_SelE(ALUSrcA_SelE),    //output
        .ALUSrcB_SelE(ALUSrcB_SelE),    //output
        .mem_writeE(mem_writeE),    //output
        .mem_readE(mem_readE),  //output
        .reg_writeE(reg_writeE),    //output
        .jalE(jalE),    //output
        .jalrE(jalrE),  //output
        .writeback_ctrlE(writeback_ctrlE),  //output
        .branch_opE(branch_opE),    //output
        .ALU_opE(ALU_opE),  //output
        .rdE(rdE),  //output
        .PCE(PCE),  //output
        .PCp4E(PCp4E),  //output
        .immE(immE),    //output
        .op1E(op1E),    //output
        .op2E(op2E) //output
    );
    
    ALU alu(
        .ALUSrcA_Sel(ALUSrcA_SelE),
        .ALUSrcB_Sel(ALUSrcB_SelE),
        .ALU_op(ALU_opE),
        .op1(op1E),
        .op2(op2E),
        .PC(PCE),
        .imm(immE),
        .ALU_out(ALU_out) //output
    );

    Branch_Unit branch_unit(
        .branch_op(branch_opE),
        .op1(op1E),
        .op2(op2E),
        .branch_taken(branch_taken) //output
    );

    EX_MEM ex_mem(
        .clk(clk),
        .rst_n(rst_n),
        .mem_writeE(mem_writeE),
        .mem_readE(mem_readE),
        .reg_writeE(reg_writeE),
        .writeback_ctrlE(writeback_ctrlE),
        .rdE(rdE),
        .ALU_outE(ALU_out),
        .PCp4E(PCp4E),
        .op2E(op2E),
        .mem_writeM(mem_writeM),    //output
        .mem_readM(mem_readM),  //output
        .reg_writeM(reg_writeM),    //output
        .writeback_ctrlM(writeback_ctrlM),  //output
        .funct3M(funct3M),  //output
        .rdM(rdM),  //output
        .ALU_outM(ALU_outM),    //output
        .PCp4M(PCp4M),  //output
        .op2M(op2M) //output
    );

    Data_Memory data_memory(
        .clk(clk),  
        .rst_n(rst_n),
        .mem_write(mem_writeM),
        .mem_read(mem_readM),
        .funct3(funct3M),
        .address(ALU_outM),
        .write_data(op2M),
        .mem_out(mem_out)   //output
    );

    MEM_WB mem_wb(
        .clk(clk),
        .rst_n(rst_n),
        .reg_writeM(reg_writeM),
        .writeback_ctrlM(writeback_ctrlM),
        .rdM(rdM),
        .ALU_outM(ALU_outM),
        .PCp4M(PCp4M),
        .mem_outM(mem_outM),
        .reg_writeW(reg_writeW),    //output
        .writeback_ctrlW(writeback_ctrlW),  //output
        .rdW(rdW),  //output
        .ALUoutW(ALUoutW),  //output
        .PCp4W(PCp4W),  //output
        .mem_outW(mem_outW) //output
    );

    Writeback_MUX writeback_mux(
        .writeback_ctrl(writeback_ctrlW),
        .ALU_out(ALU_outW),
        .mem_out(mem_outW),
        .PCp4(PCp4W),
        .writeback_data(writeback_data) //output
    );

endmodule