module PC_Reg(
    input clk, rst_n, stallF,
    input [31:0] next_PC,
    output reg [31:0] PC,
    output [31:0] PCp4 //PC + 4
    );

    always @(posedge clk) begin
        if(!rst_n)
            PC <= 32'b0;
        else if(!stallF)
            PC <= next_PC;
    end

    assign PCp4 = PC + 4;

endmodule
