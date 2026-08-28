module IF_ID(
    input clk, rst_n, flush, stall,
    input [31:0] instrF, PCF, PCp4F,
    output reg [31:0] instrD, PCD, PCp4D
    );

    always @(posedge clk) begin
        if(flush || !rst_n)
            {instrD, PCD, PCp4D} <= 96'b0;
        else if(!stall)
            {instrD, PCD, PCp4D} <= {instrF, PCF, PCp4F};
    end

endmodule
