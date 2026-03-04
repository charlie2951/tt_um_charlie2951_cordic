module tt_cordic_uart #(
    parameter CLK_FREQ = 25000000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rst_n,
    input  wire uart_rx,

    output wire [15:0] data_out,
    output wire ready,
    output wire done
);

//////////////////////////////////////////////////////////
// UART RX
//////////////////////////////////////////////////////////

wire [7:0] rx_data;
wire rx_valid;

uart_rx #(CLK_FREQ,BAUD) u_rx (
    .clk(clk),
    .rst_n(rst_n),
    .rx(uart_rx),
    .data(rx_data),
    .valid(rx_valid)
);

//////////////////////////////////////////////////////////
// Controller
//////////////////////////////////////////////////////////

wire cordic_start;
wire [15:0] angle;
wire [15:0] sin_out, cos_out;
wire cordic_done;
wire [15:0] result_32;

controller_no_tx u_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .cordic_start(cordic_start),
    .angle(angle),
    .sin_out(sin_out),
    .cos_out(cos_out),
    .cordic_done(cordic_done),
    .result(result_32),
    .ready(ready),
    .done(done)
);

//////////////////////////////////////////////////////////
// CORDIC CORE (Rotation only)
//////////////////////////////////////////////////////////

cordic_core u_cordic (
    .clk(clk),
    .rst_n(rst_n),
    .start(cordic_start),
    .angle_in(angle),
    .cos_out(cos_out),
    .sin_out(sin_out),
    .done(cordic_done)
);

//////////////////////////////////////////////////////////
// 32-bit Q3.28 → 16-bit Q1.14 conversion
//////////////////////////////////////////////////////////

assign data_out = result_32;

endmodule
