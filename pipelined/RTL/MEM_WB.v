module MEM_WB(
    input clk, rst_n,
    input reg_writeM,
    input [1:0] writeback_ctrlM,
    input [4:0] rdM,
    input [31:0] ALU_outM, PCp4M, mem_outM, 
    output reg reg_writeW,
    output reg [1:0] writeback_ctrlW,
    output reg [4:0] rdW,
    output reg [31:0] ALU_outW, PCp4W, mem_outW
    );

    always @(posedge clk) begin
        if(!rst_n) begin
            reg_writeW <= 1'b0;
            writeback_ctrlW <= 2'b0;
            rdW <= 5'b0;
            {ALU_outW, PCp4W, mem_outW} <= 96'b0;
        end else begin
            reg_writeW <= reg_writeM;
            writeback_ctrlW <= writeback_ctrlM;
            rdW <= rdM;
            {ALU_outW, PCp4W, mem_outW} <= {ALU_outM, PCp4M, mem_outM};
        end
    end
    
endmodule