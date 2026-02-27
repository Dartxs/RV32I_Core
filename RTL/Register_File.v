module Register_File(
    input clk, reset,
    input [4:0] rs1, rs2, //address for source reg1 and source reg2
    input [4:0] rd, //address for destination reg
    input reg_write, //bit for enabling writes to memory
    input [31:0] writeback_data, //data to write 
    output reg [31:0] op1, op2 //data from source reg1 and source reg2
    );
    
    reg [31:0] registers [31:0]; //32 x 32 bit registers, register x0 not really in use, but acts as a hardwire to 0
    
    always @(*) begin
        op1 = (rs1 == 0) ? 32'b0 : registers[rs1]; //return data from register rs1 if rs1 isn't 0 
        op2 = (rs2 == 0) ? 32'b0 : registers[rs2]; //return data from register rs2 if rs2 isn't 0
    end
    
    always @(posedge clk) begin     
        if(reg_write && (rd != 0) && !reset) 
            registers[rd] <= writeback_data; //write only is reg write is on, writes to x0 ignored
    end
    
endmodule
