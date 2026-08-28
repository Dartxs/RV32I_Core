module ID_EX(
    input clk, rst_n, flush, stall,
    input ALUSrcA_SelD, ALUSrcB_SelD, mem_writeD, mem_readD, reg_writeD, jalD, jalrD,
    input [1:0] writeback_ctrlD,
    input [2:0] branch_opD,
    input [3:0] ALU_opD,
    input [4:0] rdD,
    input [31:0] PCD, PCp4D, immD, op1D, op2D,
    output ALUSrcA_SelE, ALUSrB_SelE, mem_writeE, mem_readE, reg_writeE, jalE, jalrE,
    output [1:0] writeback_ctrlE,
    output [2:0] branch_opE,
    output [3:0] ALU_opE,
    output [4:0] rdE,
    output [31:0] PCE, PCp4E, immE, op1E, op2E
);

    always @(posedge clk) begin
        if(!rst_n || flush) begin
            {ALUSrcA_SelE, ALUSrB_SelE, mem_writeE, mem_readE, reg_writeE, jalE, jalrE} <= 7'b0;
            writeback_ctrlE <= 2'b0;
            branch_opE <= 3'b0;
            ALU_opE <= 4'b0;
            rdE <= 5'b0;
            {PCE, PCp4E, immE, op1E, op2E} <= 160'b0;
        end else if(!stall) begin
            {ALUSrcA_SelE, ALUSrB_SelE, mem_writeE} <= {ALUSrcA_SelD, ALUSrcB_SelD, mem_writeD};
            {mem_readE, reg_writeE, jalE, jalrE} <= {mem_readD, reg_writeD, jalD, jalrD};
            writeback_ctrlE <= writeback_ctrlD;
            branch_opE <= branch_opD;
            Alu_opE <= Alu_opD;
            rdE <= rdD;
            {PCE, PCp4E, immE, op1E, op2E} <= {PCE, PCp4E, immE, op1E, op2E};
        end
    end

endmodule
