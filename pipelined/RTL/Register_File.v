module Register_File(
    input clk, rst_n, reg_write,
    input [4:0] rs1, rs2, //address for source reg1 and source reg2
    input [4:0] rd, //address for destination reg
    input [4:0] dbug_addr,
    input [31:0] writeback_data, //data to write 
    output reg [31:0] op1, op2, //data from source reg1 and source reg2
    output [31:0] dbug_out
    );

    reg [31:0] registers [0:31]; //32 x 32 bit registers, register x0 not really in use, but acts as a hardwire to 0

    assign dbug_out = registers[dbug_addr];

    always @(*) begin
        //x1-x31 returns value stored, x0 always returns 0
        if(rs1 == 0)
            op1 = 32'b0;
        else if((rs1 == rd) && reg_write)
            op1 = writeback_data;
        else 
            op1 = registers[rs1];

        if(rs2 == 0)
            op2 = 32'b0;
        else if((rs2 == rd) && reg_write)
            op2 = writeback_data;
        else 
            op2 = registers[rs2];
        
    end

    integer i;
    always @(posedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < 32; i = i+1)
                registers[i] <= 32'b0;
        end
        else if(reg_write && (rd != 0))
            registers[rd] <= writeback_data; //write only when reg write is on, writes to x0 ignored
    end

endmodule
