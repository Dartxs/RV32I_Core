module Control_Unit(
    input [6:0] opcode,
    output reg [1:0] writeback_ctrl,
    output reg ALUSrcA_Sel, ALUSrcB_Sel, mem_write, mem_read, reg_write, jal, jalr, check_branch
    );

    localparam [6:0] load_ins = 7'b00_000_11, store_ins = 7'b01_000_11, branch_ins = 7'b11_000_11, jalr_ins = 7'b11_001_11, 
               jal_ins = 7'b11_011_11, opimm_ins = 7'b00_100_11, opR_ins = 7'b01_100_11, auipc_ins = 7'b00_101_11, 
               lui_ins = 7'b01_101_11;

   localparam [1:0] WB_ALU = 0, WB_mem = 1, WB_def_PC = 2;

    always @(*) begin
        mem_write = 0; mem_read = 0; reg_write = 0; //default: mem write, mem read, reg write off
        ALUSrcA_Sel = 0; ALUSrcB_Sel = 0; //default: use data from registers for ALU inputs
        jal = 0; jalr = 0; //default: no jumps
        writeback_ctrl = WB_ALU; //default: reg write data from ALU
        check_branch = 1'b0;
        case(opcode)
            load_ins: begin
                mem_read = 1; //read from memory
                reg_write = 1; //write to register file
                ALUSrcB_Sel = 1; //use immediate for ALU op2 to calculate offset
                writeback_ctrl = WB_mem; //write to register from memory
            end
            store_ins: begin
                mem_write = 1; //write to memory
                ALUSrcB_Sel = 1; //use immediate for ALU op2 to calculate offset
            end
            branch_ins: begin
                check_branch = 1'b1; 
            end
            jalr_ins: begin
                reg_write = 1; //write to register file
                jalr = 1;
                writeback_ctrl = WB_def_PC; //write PC to register file
            end
            jal_ins: begin
                reg_write = 1; //write to register file
                jal = 1;
                writeback_ctrl = WB_def_PC; //write PC to register file
            end
            opimm_ins: begin
                reg_write = 1; //write to register file
                ALUSrcB_Sel = 1; //use immediate for ALU op2
                writeback_ctrl = WB_ALU; //write ALU results to register file
            end
            opR_ins: begin
                reg_write = 1; //write to register file
                writeback_ctrl = WB_ALU; //write ALU results to register file
            end
            auipc_ins: begin
                reg_write = 1; //write to register file
                ALUSrcA_Sel = 1; //use PC for ALU op1
                ALUSrcB_Sel = 1; //use immediate for ALU op2
                writeback_ctrl = WB_ALU; //write ALU results to register file
            end
            lui_ins: begin
                reg_write = 1; //write to register file
                writeback_ctrl = WB_ALU; 
            end
            default: ;
        endcase
    end
endmodule
