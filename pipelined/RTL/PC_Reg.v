module PC_Reg(
    input clk, rst_n,
    input [31:0] next_PC,
    output reg [31:0] PC, PCPlus4
    );

    always @(posedge clk) begin
        if(!rst_n)
            PC <= 32'b0;
        else
            PC <= new_PC;
    end

    assign PCPlus4 = PC + 4;

endmodule
