module Forwarding_MUX(
    input [1:0] forwardSel,
    input [31:0] reg_out, ALU_outM, writeback_data,
    output reg [31:0] op
);

    localparam [1:0] no_forward = 2'b0, forward_MEM = 2'b01, forward_WB = 2'b10;

    always @(*) begin

        case(forwardSel) 
            no_forward: op = reg_out;
            forward_MEM: op = ALU_outM;
            forward_WB: op = writeback_data;
            default: op = reg_out;
        endcase
    end

endmodule

