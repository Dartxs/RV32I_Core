module Writeback_MUX(
    input [1:0] writeback_ctrl,
    input [31:0] ALU_out, mem_out, PCp4, imm, //note PC should be current PC+4
    output reg [31:0] writeback_data //data used to write to register file
    );

    localparam [1:0] WB_ALU = 0, WB_mem = 1, WB_def_PC = 2, WB_imm = 3;

    always @(*) begin
        case(writeback_ctrl)
            WB_ALU: writeback_data = ALU_out;
            WB_mem: writeback_data = mem_out;
            WB_def_PC: writeback_data = default_PC;
            WB_imm: writeback_data = imm;
            default: writeback_data = 32'b0;
        endcase
   end
endmodule
