module IF_ID(
    input clk, rst_n, flushFD, stallFD,
    input [31:0] instrF, PCF, PCp4F,
    output reg [31:0] instrD, PCD, PCp4D
    );

    always @(posedge clk) begin
        if(!rst_n || flushFD)
            {instrD, PCD, PCp4D} <= 96'b0;
        else if(!stallFD)
            {instrD, PCD, PCp4D} <= {instrF, PCF, PCp4F};
    end

endmodule
