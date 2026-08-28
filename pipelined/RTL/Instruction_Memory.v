module Instruction_Memory(
    input [31:0] PC, //uses  PC to determine address location to fetch memory
    output reg [31:0] instruction
    );

    reg [7:0] rom [0:4095]; //byte addressed read-only memory (RV32i standard), 4096/4 = 1024 instr

    initial begin
        $readmemh("program.mem", rom);
    end

    always @(*) begin
        instruction = {rom[{PC[11:2], 2'b11}], //stored in little endian
                       rom[{PC[11:2], 2'b10}],
                       rom[{PC[11:2], 2'b01}],
                       rom[{PC[11:2], 2'b00}]};
    end

endmodule
