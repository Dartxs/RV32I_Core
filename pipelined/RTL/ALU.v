module ALU(
    input [3:0] ALU_op, //from ALU branch control
    input ALU_op1_ctrl, ALU_op2_ctrl, //operator1, operator2 selects from control unit
    input [31:0] op1, op2, PC, imm,
    output reg [31:0] ALU_out
    );

    wire [31:0] ALU_op1, ALU_op2;

    assign ALU_op1 = (ALU_op1_ctrl) ? PC : op1; //op1 ctrl selects if ALU op1 is PC or op1
    assign ALU_op2 = (ALU_op2_ctrl) ? imm : op2; //op2_ctrl selects if ALU op2 is immediate or op2

    localparam [3:0] add_op = 0, sub_op = 1, sll_op = 2, slt_op = 3, sltu_op = 4,
               xor_op = 5, srl_op = 6, sra_op = 7, or_op = 8, and_op = 9;

    always @(*) begin
        case(ALU_op)
            add_op: ALU_out = ALU_op1 + ALU_op2;
            sub_op: ALU_out = ALU_op1 - ALU_op2;
            sll_op: ALU_out = ALU_op1 << ALU_op2[4:0];
            slt_op: ALU_out = ($signed(ALU_op1) < $signed(ALU_op2)) ? {31'b0, 1'b1} : 32'b0;  
            sltu_op: ALU_out = (ALU_op1 < ALU_op2) ? {31'b0, 1'b1} : 32'b0;
            xor_op: ALU_out = ALU_op1 ^ ALU_op2;
            srl_op: ALU_out = ALU_op1 >> ALU_op2[4:0];
            sra_op: ALU_out = $signed(ALU_op1) >>> ALU_op2[4:0];
            or_op: ALU_out = ALU_op1 | ALU_op2;
            and_op: ALU_out = ALU_op1 & ALU_op2;
            default: ALU_out = 32'b0;
        endcase
    end

endmodule
