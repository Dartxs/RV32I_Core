module Instruction_Memory(
    input [31:0] PC, //uses  PC to determine address location to fetch memory
    output reg [31:0] instruction
    );

    reg [7:0] rom [0:1023]; //byte addressed read-only memory (RV32i standard), 1024/4 = 256 instructions storable 

    initial begin
        $readmemh("program.mem", rom); //use .mem file as instruction memory
    end

    always @(*) begin
        instruction = {rom[PC+3], //stored in little endian
                       rom[PC+2],
                       rom[PC+1],
                       rom[PC]};
    end

endmodule
