`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2026 13:37:43
// Design Name: 
// Module Name: spi_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module spi_master #(
    parameter CLK_FREQ = 50_000_000,
    parameter SPI_FREQ = 1_000_000
)(
    input  wire       clk,
    input  wire       rst,

    input  wire       start,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg        busy,
    output reg        done,

    output reg        sclk,
    output reg        mosi,
    input  wire        miso,
    output reg        cs
);

    localparam integer CLK_DIV = CLK_FREQ / (2 * SPI_FREQ);

    reg [15:0] clk_count;
    reg [3:0]  bit_count;

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    always @(posedge clk) begin

        if (rst) begin

            clk_count <= 16'd0;
            bit_count <= 4'd0;

            tx_shift <= 8'd0;
            rx_shift <= 8'd0;
            rx_data  <= 8'd0;

            busy <= 1'b0;
            done <= 1'b0;

            sclk <= 1'b0;
            mosi <= 1'b0;
            cs   <= 1'b1;
        end

        else begin

            done <= 1'b0;

            // =================================
            // START TRANSACTION
            // =================================

            if (start && !busy) begin

                busy <= 1'b1;
                cs   <= 1'b0;

                clk_count <= 16'd0;
                bit_count <= 4'd0;

                tx_shift <= tx_data;
                rx_shift <= 8'd0;

                // MSB first
                mosi <= tx_data[7];

                sclk <= 1'b0;
            end

            // =================================
            // SPI TRANSACTION
            // =================================

            else if (busy) begin

                if (clk_count < CLK_DIV - 1) begin

                    clk_count <= clk_count + 1;

                end

                else begin

                    clk_count <= 16'd0;

                    // =================================
                    // RISING EDGE
                    // SPI MODE 0: SAMPLE MISO
                    // =================================

                    if (sclk == 1'b0) begin

                        sclk <= 1'b1;

                        rx_shift <= {
                            rx_shift[6:0],
                            miso
                        };

                    end

                    // =================================
                    // FALLING EDGE
                    // SPI MODE 0: CHANGE MOSI
                    // =================================

                    else begin

                        sclk <= 1'b0;

                        if (bit_count == 7) begin

                            // Transaction complete
                            busy <= 1'b0;
                            done <= 1'b1;

                            cs   <= 1'b1;
                            mosi <= 1'b0;

                            // rx_shift already contains
                            // the 8 sampled bits
                            rx_data <= rx_shift;

                        end

                        else begin

                            bit_count <= bit_count + 1;

                            tx_shift <= {
                                tx_shift[6:0],
                                1'b0
                            };

                            mosi <= tx_shift[6];

                        end
                    end
                end
            end

            // =================================
            // IDLE
            // =================================

            else begin

                sclk <= 1'b0;
                cs   <= 1'b1;
                mosi <= 1'b0;

            end

        end
    end

endmodule