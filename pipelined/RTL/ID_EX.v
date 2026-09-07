module ID_EX(
    input clk, rst_n, flushDE,
    input ALUSrcA_SelD, ALUSrcB_SelD, mem_writeD, reg_writeD, jalD, jalrD, check_branchD,
    input [1:0] writeback_ctrlD,
    input [2:0] branch_opD, funct3D,
    input [3:0] ALU_opD,
    input [4:0] rdD, rs1D, rs2D,
    input [31:0] PCD, PCp4D, immD, op1D, op2D,
    output reg ALUSrcA_SelE, ALUSrcB_SelE, mem_writeE, reg_writeE, jalE, jalrE, check_branchE,
    output reg [1:0] writeback_ctrlE,
    output reg [2:0] branch_opE, funct3E,
    output reg [3:0] ALU_opE,
    output reg [4:0] rdE, rs1E, rs2E,
    output reg [31:0] PCE, PCp4E, immE, op1E, op2E
);

    always @(posedge clk) begin
        if(!rst_n || flushDE) begin
            {ALUSrcA_SelE, ALUSrcB_SelE, mem_writeE, reg_writeE, jalE, jalrE, check_branchE} <= 7'b0;
            writeback_ctrlE <= 2'b0;
            {branch_opE, funct3E} <= 6'b0;
            ALU_opE <= 4'b0;
            {rdE, rs1E, rs2E} <= 15'b0;
            {PCE, PCp4E, immE, op1E, op2E} <= 160'b0;
        end else begin
            {ALUSrcA_SelE, ALUSrcB_SelE, mem_writeE} <= {ALUSrcA_SelD, ALUSrcB_SelD, mem_writeD};
            {reg_writeE, jalE, jalrE, check_branchE} <= {reg_writeD, jalD, jalrD, check_branchD};
            writeback_ctrlE <= writeback_ctrlD;
            {branch_opE, funct3E} <= {branch_opD, funct3D};
            ALU_opE <= ALU_opD;
            {rdE, rs1E, rs2E} <= {rdD, rs1D, rs2D};
            {PCE, PCp4E, immE, op1E, op2E} <= {PCD, PCp4D, immD, op1D, op2D};
        end
    end

endmodule
