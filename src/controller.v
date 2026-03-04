module controller_no_tx (
    input  wire clk,
    input  wire rst_n,

    input  wire [7:0] rx_data,
    input  wire rx_valid,

    output reg  cordic_start,
    output reg  [15:0] angle,

    input  wire [15:0] sin_out,
    input  wire [15:0] cos_out,
    input  wire cordic_done,

    output reg  [15:0] result,
    output wire ready,
    output reg  done
);

localparam IDLE=0,
           RX_A0=1,RX_A1=2,
            //RX_A2=3,RX_A3=4,
           START=5,WAIT=6;

reg [2:0] state;
reg [7:0] opcode;

assign ready = (state == IDLE);

always @(posedge clk ) begin
    if (!rst_n) begin
        state <= IDLE;
        cordic_start <= 0;
        done <= 0;
    end else begin

        cordic_start <= 0;
        done <= 0;

        case(state)

        IDLE:
            if (rx_valid) begin
                opcode <= rx_data;
                state <= RX_A0;
            end

        RX_A0: if (rx_valid) begin angle[7:0]   <= rx_data; state <= RX_A1; end
        RX_A1: if (rx_valid) begin angle[15:8]  <= rx_data; state <= START; end
        //RX_A2: if (rx_valid) begin angle[23:16] <= rx_data; state <= RX_A3; end
        //RX_A3: if (rx_valid) begin angle[31:24] <= rx_data; state <= START; end

        START: begin
            cordic_start <= 1;
            state <= WAIT;
        end

        WAIT:
            if (cordic_done) begin
                result <= (opcode == 8'h01) ? sin_out :
                          (opcode == 8'h02) ? cos_out :
                          16'd0;
                done <= 1;
                state <= IDLE;
            end

        endcase
    end
end

endmodule
