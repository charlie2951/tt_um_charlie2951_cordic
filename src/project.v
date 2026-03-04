/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_cordic (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
 // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
 // assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in[0],uio_in[1],uio_in[2],uio_in[3],uio_in[4],uio_in[5],uio_in[6],uio_in[7], 1'b0};
//Instantiate top module
    module tt_cordic_uart #(
    parameter CLK_FREQ = 25000000,
    parameter BAUD     = 115200
    ) math_soc(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(ui_in[0]),
        .data_out({uio_out,uo_out}),
        .ready(),
        .done()
);
endmodule
