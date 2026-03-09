module Register_File(
    input clk, rst_n,
    input [4:0] rs1, rs2, //address for source reg1 and source reg2
    input [4:0] rd, //address for destination reg
    input reg_write, //bit for enabling writes to memory
    input [31:0] writeback_data, //data to write 
    output reg [31:0] op1, op2 //data from source reg1 and source reg2
    );
    
    reg [31:0] registers [31:0]; //32 x 32 bit registers, register x0 not really in use, but acts as a hardwire to 0
    
    always @(*) begin
        //x1-x31 returns value stored x0 always returns 0
        op1 = (rs1 == 0) ? 32'b0 : registers[rs1]; 
        op2 = (rs2 == 0) ? 32'b0 : registers[rs2]; 
    end
    
    always @(posedge clk) begin    
        if(!rst_n) begin
            integer i;
            for(i = 0; i < 32; i = i+1) 
                registers[i] <= 32'b0;
        end 
        else if(reg_write && (rd != 0)) 
            registers[rd] <= writeback_data; //write only is reg write is on, writes to x0 ignored
    end
    
endmodule
