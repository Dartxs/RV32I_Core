/*
RAW hazards, forward from ALU output either in EX stage or MEM stage (EX stage has priority)

*/

module Hazard_Unit(
    input reg_writeM, reg_writeW, flush,
    input [1:0] writeback_ctrlE,
    input [4:0] rs1D, rs2D, rs1E, rs2E, rdE, rdM, rdW,
    output reg stallF, stallFD, flushFD, flushDE,
    output reg [1:0] forwardA, forwardB
);

    localparam [1:0] WB_MEM = 1;

    localparam [1:0] no_forward = 2'b0, forward_MEM = 2'b01, forward_WB = 2'b10;

    wire load_dep = (writeback_ctrlE == WB_MEM) && ((rdE == rs1D) || (rdE == rs2D));

    always @(*) begin
        forwardA = no_forward; forwardB = no_forward;
        {stallF, stallFD, flushFD, flushDE} = 4'b0; 

        if(flush)
            {flushFD, flushDE} = 2'b11;
        else if((rdE != 5'b0) && load_dep) 
            {stallF, stallFD, flushDE} = 3'b111;

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

