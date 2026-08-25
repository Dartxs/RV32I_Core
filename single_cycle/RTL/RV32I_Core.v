module RV32I_Core(
    input clk, rst_n,
    input [4:0] dbug_addr,
    output [31:0] dbug_out
    );

    wire [31:0] PC; //current count
    wire [31:0] default_PC; //default next count (count+4)
    wire [31:0] instruction, imm;
    wire [6:0] opcode, funct7;
    wire [2:0] funct3;
    wire [4:0] rs1, rs2; //source registers
    wire [4:0] rd; //destination register
    wire branch_taken; //enable branch
    wire [1:0] PC_Sel; //select PC
    wire [1:0] writeback_ctrl; //control writeback MUX
    wire ALU_op1_ctrl, ALU_op2_ctrl, mem_write, mem_read, reg_write; //ALU operand MUX control, mem read/write enables, reg write enable
    wire [3:0] ALU_op; //controls which operation the ALU should perform
    wire [2:0] branch_op; //controls which operation the branch unit should perform
    wire [31:0] op1, op2; //values in register datapath
    wire [31:0] writeback_data; //data to write to register file
    wire [31:0] ALU_out; //output of ALU
    wire [31:0] mem_out; //output from memory

    Program_Counter program_counter(
        .clk(clk),
        .rst_n(rst_n),
        .PC_Sel(PC_Sel),
        .op1(op1),
        .imm(imm),
        .PC(PC),
        .default_PC(default_PC)
    );

    Instruction_Memory instruction_memory(
        .PC(PC),
        .instruction(instruction)
    );

   Instruction_Decoder instruction_decoder(
        .instruction(instruction),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm)
    );

    Writeback_MUX writeback_mux(
        .writeback_ctrl(writeback_ctrl),
        .ALU_out(ALU_out),
        .mem_out(mem_out),
        .default_PC(default_PC),
        .imm(imm),
        .writeback_data(writeback_data)
    );

    Register_File register_file(
        .clk(clk),
        .rst_n(rst_n),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .dbug_addr(dbug_addr),
        .reg_write(reg_write),
        .writeback_data(writeback_data),
        .op1(op1),
        .op2(op2),
        .dbug_out(dbug_out)
    );

    Control_Unit control_unit(
        .branch_taken(branch_taken),
        .opcode(opcode),
        .PC_Sel(PC_Sel),
        .writeback_ctrl(writeback_ctrl),
        .ALU_op1_ctrl(ALU_op1_ctrl),
        .ALU_op2_ctrl(ALU_op2_ctrl),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .reg_write(reg_write)
    );

    ALU_Branch_Control alu_branch_control(
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .ALU_op(ALU_op),
        .branch_op(branch_op)
    );

    ALU alu(
        .ALU_op(ALU_op),
        .ALU_op1_ctrl(ALU_op1_ctrl),
        .ALU_op2_ctrl(ALU_op2_ctrl),
        .op1(op1),
        .op2(op2),
        .PC(PC),
        .imm(imm),
        .ALU_out(ALU_out)
    );

    Branch_Unit branch_unit(
        .op1(op1),
        .op2(op2),
        .branch_op(branch_op),
        .branch_taken(branch_taken)
    );

    Data_Memory data_memory(
        .clk(clk),
        .rst_n(rst_n),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .funct3(funct3),
        .address(ALU_out), //ALU_out = address to read from memory
        .write_data(op2), //Data to write comes from data stored in rs2
        .read_data(mem_out) //read data sent to writeback MUX
    );

endmodule
