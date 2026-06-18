module Branch_Unit(
    input [31:0] op1, op2,
    input [2:0] branch_op, //input to determine which operation used to determine branch
    output reg branch_taken
    );

    localparam beq = 0, bne = 1, blt = 2, bge = 3, bltu = 4, bgeu = 5; //match ALU_Branch_control

    always @(*) begin
        case(branch_op)
            beq: branch_taken = (op1 == op2);
            bne: branch_taken = (op1 != op2);
            blt: branch_taken = ($signed(op1) < $signed(op2));
            bge: branch_taken = ($signed(op1) >= $signed(op2));
            bltu: branch_taken = (op1 < op2);
            bgeu: branch_taken = (op1 >= op2);
            default: branch_taken = beq;
        endcase
    end
     
endmodule
