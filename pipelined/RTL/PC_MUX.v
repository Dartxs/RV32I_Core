module PC_MUX(
    input jal, jalr, branch_taken,
    input [31:0] op1, imm, PC, PCp4, //op1, imm, PC should be passed from execute stage for jump or branch
    output flush,
    output reg [31:0] next_PC
    );

    wire [31:0] PC_BR_JAL, PC_JALR;

    assign PC_BR_JAL = PC + imm;
    assign PC_JALR = op1 + imm;

    assign flush = jal || jalr || branch_taken;

    always @(*) begin
        if(jal || branch_taken)
            next_PC = PC_BR_JAL;
        else if(jalr)
            next_PC = {PC_JALR[31:1], 1'b0};
        else
            next_PC = PCp4;
    end

endmodule