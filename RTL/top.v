module top(
    input clk, rstn_btn, next_btn, prev_btn,
    output [7:0] sseg,
    output [7:0] an,
    output [4:0] dbug_addr
);

    wire next_tick, prev_tick, rst_n;
    wire [31:0] dbug_out;

    reg [3:0] por = 4'b0; //power-on reset

    always @(posedge clk) begin
        por <= {por[2:0], 1'b1};
    end

    Debouncer #(.CLK_FREQ(50000000)) rstn_debouncer(
        .clk(clk),
        .rst_n(por[3]),
        .btn(rstn_btn),
        .tick(),
        .level(rst_n)
    );

    Debouncer #(.CLK_FREQ(50000000)) next_debouncer(
        .clk(clk),
        .rst_n(rst_n),
        .btn(next_btn),
        .tick(next_tick),
        .level()
    );

    Debouncer #(.CLK_FREQ(50000000)) prev_debouncer(
        .clk(clk),
        .rst_n(rst_n),
        .btn(prev_btn),
        .tick(prev_tick),
        .level()
    );

    Reg_Counter reg_counter(
        .clk(clk),
        .rst_n(rst_n),
        .next_tick(next_tick),
        .prev_tick(prev_tick),
        .dbug_addr(dbug_addr)
    );

    Hexdisp_Mux hexdisp_mux(
        .clk(clk),
        .rst_n(rst_n),
        .led7(dbug_out[31:28]),
        .led6(dbug_out[27:24]),
        .led5(dbug_out[23:20]),
        .led4(dbug_out[19:16]),
        .led3(dbug_out[15:12]),
        .led2(dbug_out[11:8]),
        .led1(dbug_out[7:4]),
        .led0(dbug_out[3:0]),
        .sseg(sseg),
        .an(an)
    );

    RV32I_Core rv32i_core(
        .clk(clk),
        .rst_n(rst_n),
        .dbug_addr(dbug_addr),
        .dbug_out(dbug_out)
    );

endmodule
