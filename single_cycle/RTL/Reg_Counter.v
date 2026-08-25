module Reg_Counter(
    input clk, rst_n, next_tick, prev_tick,
    output reg [4:0] dbug_addr
);

    wire ena = next_tick ^ prev_tick; //ensure nothing changes if both signals asserted

    always @(posedge clk) begin
        if(!rst_n)
            dbug_addr <= 5'b0;
        else if(ena) begin
            if(next_tick)
                dbug_addr <= dbug_addr + 1;
            else if(prev_tick)
                dbug_addr <= dbug_addr - 1;
        end
    end

endmodule
