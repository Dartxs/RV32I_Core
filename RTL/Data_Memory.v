module Data_Memory(
    input clk, rst_n, mem_write, mem_read,
    input [2:0] funct3,
    input [31:0] address, write_data,
    output reg [31:0] read_data
    );

    wire [3:0] byte_ena;
    wire aligned, sign;

    Mem_Aligner mem_aligner(.funct3(funct3), .address(address[1:0]), .aligned(aligned), .sign(sign), .byte_ena(byte_ena));

    wire write_ena = (mem_write && aligned);
    wire read_ena = (mem_read && aligned);

    reg [31:0] memory [0:2047]; //2048 words (8192 bytes)

    wire [10:0] word_address = address[12:2]; //address word aligned
    wire [31:0] write_mask = { {8{byte_ena[3]}}, {8{byte_ena[2]}}, {8{byte_ena[1]}}, {8{byte_ena[0]}} }; //word with bytes high based on byte_ena

    wire [4:0] shift = {address[1:0], 3'b000}; //shift based on address for writing
    wire [31:0] write_data_shifted = write_data << shift; /*Shift data to align with target byte 
                                                           (if write data is 0...101 and write address is at the third byte of a word,
                                                           write_data_shift would be byte 0 of write data but shifted left 2 bytes) 
                                                           (this shifting is purely based on write address, valid writes are determined by aligner)
                                                           */

    wire [31:0] word = memory[word_address]; //setting word to target address, target bytes dealt with later                                                  

    always @(posedge clk) begin
        if(write_ena && rst_n)
                memory[word_address] <= (memory[word_address] & ~write_mask) | (write_data_shifted & write_mask); /*Bytes that need to be written are cleared by the first AND.
                                                                                                                    Second AND ensures only bytes that need to be written
                                                                                                                    are set. OR combines the two which keeps original bytes 
                                                                                                                    and modifying only bytes meant to be written
                                                                                                                    */
    end

    always @(*) begin
        read_data = 32'b0;

        if(read_ena) begin
            case(byte_ena)
                4'b1111: read_data = word; //load word
                4'b1100: begin
                    if(sign)
                        read_data = { {16{word[31]}}, word[31:16] }; //load upper halfword, sign extended
                    else
                        read_data = { 16'b0, word[31:16] }; //load upper halfworld, zero extended
                end
                4'b0011: begin
                    if(sign)
                        read_data = { {16{word[15]}}, word[15:0] }; //load lower halfword, sign extended
                    else
                        read_data = { 16'b0, word[15:0] } ; //load lower halfword, zero extended
                end
                4'b0001: begin
                    if(sign)
                        read_data = { {24{word[7]}}, word[7:0] }; //load byte0, sign extended
                    else
                        read_data = { 24'b0, word[7:0] }; //load byte0, zero extended
                end
                4'b0010: begin
                    if(sign)
                        read_data = { {24{word[15]}}, word[15:8] }; //load byte1, sign extended
                    else
                        read_data = { 24'b0, word[15:8] }; //load byte1, zero extended
                end
                4'b0100: begin
                    if(sign)
                        read_data = { {24{word[23]}}, word[23:16] }; //load byte2, sign extended
                    else
                        read_data = { 24'b0, word[23:16] }; //load byte2, zero extended
                end
                4'b1000: begin
                    if(sign)
                        read_data = { {24{word[31]}}, word[31:24] }; //load byte3, sign extended
                    else
                        read_data = { 24'b0, word[31:24] }; //load byte3, zero extended
                end
                default: read_data = 32'b0;
            endcase
        end
    end
endmodule
