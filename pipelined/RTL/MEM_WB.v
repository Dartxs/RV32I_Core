module MEM_WB(
    input clk, rst_n, flush, stall,
    input reg_writeM,
    input [1:0] writeback_ctrlM,
    input [4:0] rdM,
    input [31:0] ALU_outM, PCp4M, read_dataM,
    output reg_writeW,
    output [1:0] writeback_ctrlW,
    output [4:0] rdW,
    output [31:0] ALU_outw, PCp4W, read_dataW
    );

    always @(posedge clk) begin
        if(!rst_n || flush) begin
            reg_writeW <= 1'b0;
            writeback_ctrlW <= 2'b0;
            rdW <= 5'b0;
            {ALU_outw, PCp4W, read_dataW} <= 96'b0;
        end else if(!stall) begin
            reg_writeW <= reg_writeM;
            writeback_ctrlW <= writeback_ctrlM;
            rdW <= rdM;
            {ALU_outw, PCp4W, read_dataW} <= {ALU_outM, PCp4M, read_dataM};
        end
    end
    
endmodule