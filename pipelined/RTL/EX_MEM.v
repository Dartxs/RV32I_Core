module EX_MEM(
    input clk, rst_n,
    input mem_writeE, reg_writeE,
    input [1:0] writeback_ctrlE,
    input [2:0] funct3E,
    input [4:0] rdE,
    input [31:0] ALU_outE, PCp4E, op2E,
    output reg mem_writeM, reg_writeM,
    output reg [1:0] writeback_ctrlM,
    output reg [2:0] funct3M,
    output reg [4:0] rdM,
    output reg [31:0] ALU_outM, PCp4M, op2M
    );

    always @(posedge clk) begin
        if(!rst_n) begin
            {mem_writeM, reg_writeM} <= 2'b0;
            writeback_ctrlM <= 2'b0;
            funct3M <= 3'b0;
            rdM <= 5'b0;
            {ALU_outM, PCp4M, op2M} <= 96'b0;
        end else begin
            {mem_writeM, reg_writeM} <= {mem_writeE, reg_writeE};
            writeback_ctrlM <= writeback_ctrlE;
            funct3M <= funct3E;
            rdM <= rdE;
            {ALU_outM, PCp4M, op2M} <= {ALU_outE, PCp4E, op2E};
        end
    end

endmodule
