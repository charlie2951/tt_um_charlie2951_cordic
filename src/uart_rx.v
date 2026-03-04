module uart_rx #(
    parameter CLK_FREQ = 25000000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output reg  [7:0] data,
    output reg  valid
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD;

reg [15:0] clk_cnt;
reg [3:0]  bit_idx;
reg [9:0]  shift;
reg busy;

always @(posedge clk ) begin
    if (!rst_n) begin
        busy <= 0;
        clk_cnt <= 0;
        bit_idx <= 0;
        valid <= 0;
    end else begin
        valid <= 0;

        if (!busy) begin
            if (!rx) begin
                busy <= 1;
                clk_cnt <= CLKS_PER_BIT/2;
                bit_idx <= 0;
            end
        end else begin
            if (clk_cnt == CLKS_PER_BIT-1) begin
                clk_cnt <= 0;
                shift[bit_idx] <= rx;
                bit_idx <= bit_idx + 1;

                if (bit_idx == 9) begin
                    busy <= 0;
                    data <= shift[8:1];
                    valid <= 1;
                end
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end
end
endmodule
