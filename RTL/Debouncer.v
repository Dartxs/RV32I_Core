module Debouncer#(
    parameter CLK_FREQ = 100000000
    )(
    input clk, rst_n, btn,
    output level,
    output reg tick
);

    localparam sample_freq = 1000;
    localparam sample_per = CLK_FREQ/sample_freq;
    localparam count_width = (sample_per == 1) ? 1 : $clog2(sample_per);

    wire sync_btn;

    synchronizer btn_synchronizer(
        .clk(clk),
        .btn(btn),
        .sync_btn(sync_btn)
    );

    localparam zero = 0, wait1 = 1, one = 2, wait0 = 3;

    reg [1:0] PS, NS;
    reg [count_width-1:0] clk_count;

    always @(*) begin
        NS = PS;
        case(PS)
            zero: NS = (sync_btn) ? wait1 : zero;
            wait1: NS = (sync_btn) ? one : zero;
            one: NS = (sync_btn) ? one : wait0;
            wait0: NS = (sync_btn) ? one : zero;
            default: NS = zero;
        endcase
    end

    always @(posedge clk) begin
        tick <= 1'b0;
        if(!rst_n) begin
            PS <= zero;
            clk_count <= 0;
            tick <= 1'b0;
        end else if(clk_count == (sample_per-1)) begin
            if((NS == one) && (PS != one))
                tick <= 1'b1;

            PS <= NS;
            clk_count <= '0;
        end else
            clk_count <= clk_count + 1;
    end

    assign level = (PS == one);

endmodule

module synchronizer(
    input clk, btn,
    output sync_btn
);

    reg sync0, sync1;

    always @(posedge clk) begin
        sync0 <= btn;
        sync1 <= sync0;
    end

    assign sync_btn = sync1;

endmodule
