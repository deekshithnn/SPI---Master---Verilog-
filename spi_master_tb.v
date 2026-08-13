`timescale 1ns/1ps

module spi_master_tb;

    // ==========================================
    // PARAMETERS
    // ==========================================

    parameter CLK_FREQ = 50_000_000;
    parameter SPI_FREQ = 1_000_000;


    // ==========================================
    // DUT SIGNALS
    // ==========================================

    reg        clk;
    reg        rst;

    reg        start;
    reg [7:0]  tx_data;

    wire [7:0] rx_data;
    wire       busy;
    wire       done;

    wire       sclk;
    wire       mosi;
    reg        miso;
    wire       cs;


    // ==========================================
    // SPI SLAVE
    // ==========================================

    reg [7:0] slave_data;
    integer bit_count;


    // ==========================================
    // SPI MASTER DUT
    // ==========================================

    spi_master #(
        .CLK_FREQ(CLK_FREQ),
        .SPI_FREQ(SPI_FREQ)
    ) DUT (

        .clk(clk),
        .rst(rst),

        .start(start),
        .tx_data(tx_data),

        .rx_data(rx_data),
        .busy(busy),
        .done(done),

        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs(cs)
    );


    // ==========================================
    // 50 MHz CLOCK
    // Period = 20 ns
    // ==========================================

    always #10 clk = ~clk;


    // ==========================================
    // SPI SLAVE
    // MODE 0
    //
    // CPOL = 0
    // CPHA = 0
    //
    // Master samples MISO on rising edge.
    // Slave changes MISO on falling edge.
    // ==========================================


    // CS LOW -> prepare first bit

    always @(negedge cs) begin

        bit_count = 0;

        // Send MSB first
        miso = slave_data[7];

        $display(
            "TIME = %0t | CS LOW | MISO = %b",
            $time,
            slave_data[7]
        );

    end


    // Falling edge -> prepare next bit

    always @(negedge sclk) begin

        if (!cs) begin

            bit_count = bit_count + 1;

            case (bit_count)

                1: miso = slave_data[6];
                2: miso = slave_data[5];
                3: miso = slave_data[4];
                4: miso = slave_data[3];
                5: miso = slave_data[2];
                6: miso = slave_data[1];
                7: miso = slave_data[0];

                default:
                    miso = 1'b0;

            endcase

            $display(
                "TIME = %0t | SCLK FALL | BIT = %0d | MISO = %b",
                $time,
                bit_count,
                miso
            );

        end

    end


    // ==========================================
    // TEST SEQUENCE
    // ==========================================

    initial begin

        // Initial values

        clk = 1'b0;
        rst = 1'b1;

        start   = 1'b0;
        tx_data = 8'h00;

        miso = 1'b0;

        slave_data = 8'h3C;

        bit_count = 0;


        // ======================================
        // RESET
        // ======================================

        #100;

        rst = 1'b0;

        #100;


        // ======================================
        // TEST
        // ======================================

        tx_data = 8'hA5;

        $display("");
        $display("======================================");
        $display("       SPI MASTER TEST START");
        $display("======================================");
        $display("TX DATA    = %h", tx_data);
        $display("SLAVE DATA = %h", slave_data);
        $display("======================================");
        $display("");


        // Start SPI transaction

        start = 1'b1;

        #20;

        start = 1'b0;


        // ======================================
        // WAIT FOR TRANSACTION TO COMPLETE
        // ======================================

        wait(done == 1'b1);

        #100;


        // ======================================
        // DISPLAY RESULT
        // ======================================

        $display("");
        $display("======================================");
        $display("          SPI TEST RESULT");
        $display("======================================");

        $display("TX DATA = %h", tx_data);
        $display("RX DATA = %h", rx_data);

        $display("======================================");


        // ======================================
        // CHECK
        // ======================================

        if (rx_data == slave_data) begin

            $display("");
            $display("**************************************");
            $display("       SPI TEST PASSED!");
            $display("       TX = %h", tx_data);
            $display("       RX = %h", rx_data);
            $display("**************************************");
            $display("");

        end

        else begin

            $display("");
            $display("**************************************");
            $display("       SPI TEST FAILED!");
            $display("       EXPECTED = %h", slave_data);
            $display("       ACTUAL   = %h", rx_data);
            $display("**************************************");
            $display("");

        end


        #100;

        $finish;

    end


    // ==========================================
    // DONE MONITOR
    // ==========================================

    always @(posedge done) begin

        $display(
            "TIME = %0t | DONE = %b | RX_DATA = %h",
            $time,
            done,
            rx_data
        );

    end

endmodule
