module EX_MEM(
    input clk, rst_n, flush, stall,
    input mem_writeE, mem_readE, reg_writeE,
    input [1:0] writeback_ctrlE,
    input [4:0] rdE,
    input [31:0] ALU_outE, PCp4E, op2E,
    output mem_writeM, mem_readM, reg_writeM,
    output [1:0] writeback_ctrlM,
    output [4:0] rdM,
    output [31:0] ALU_outM, PCp4M, op2M
    );

    always @(posedge clk) begin
        if(!rst_n || flush) begin
            {mem_writeM, mem_readM, reg_writeM} <= 3'b0;
            writeback_ctrlM <= 2'b0;
            rdM <= 5'b0;
            {ALU_outM, PCp4M, op2M} <= 96'b0;
        end else if(!stall) begin
            {mem_writeM, mem_readM, reg_writeM} <= {mem_writeE, mem_readE, reg_writeE};
            writeback_ctrlM <= writeback_ctrlE;
            rdM <= rdE;
            {ALU_outM, PCp4M, op2M} <= {ALU_outE, PCp4E, op2E};
        end
    end

endmodule
