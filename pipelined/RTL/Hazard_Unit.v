/*
RAW hazards, forward from ALU output either in EX stage or MEM stage (EX stage has priority)

*/

module Hazard_Unit(
    input reg_writeM, reg_writeW,
    input [4:0] rs1E, rs2E, rdM, rdW,
    output reg [1:0] forwardA, forwardB
);

    localparam [1:0] no_forward = 2'b0, forward_MEM = 2'b01, forward_WB = 2'b10;

    always @(*) begin
        forwardA = no_forward; forwardB = no_forward;

        if((rdM != 5'b0) && (rs1E == rdM) && reg_writeM)
            forwardA = forward_MEM;
        else if((rdW != 5'b0) && (rs1E == rdW) && reg_writeW)
            forwardA = forward_WB;

        if((rdM != 5'b0) && (rs2E == rdM) && reg_writeM)
            forwardB = forward_MEM;
        else if((rdW != 5'b0) && (rs2E == rdW) && reg_writeW)
            forwardB = forward_WB;
    end


endmodule

