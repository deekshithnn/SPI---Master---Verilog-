SPI Master Verilog

An 8-bit SPI Master Controller designed using Verilog HDL and verified through functional simulation using Xilinx Vivado XSim.

🚀 Features
8-bit SPI data transfer
MSB-first transmission
MOSI and MISO support
SCLK generation
Chip Select (CS) control
Configurable system clock frequency
Configurable SPI clock frequency
Busy and Done status signals
Verilog testbench for functional verification
🛠️ Tools Used
Verilog HDL
Xilinx Vivado 2025.2
XSim Simulator
RTL Design
Functional Simulation
📌 Module Interface
Signal	Direction	Description
clk	Input	System clock
rst	Input	Reset
start	Input	Starts SPI transfer
tx_data[7:0]	Input	Transmit data
rx_data[7:0]	Output	Received data
busy	Output	Transfer in progress
done	Output	Transfer completed
sclk	Output	SPI clock
mosi	Output	Master Out Slave In
miso	Input	Master In Slave Out
cs	Output	Chip Select
⚙️ Parameters
CLK_FREQ = 50_000_000
SPI_FREQ = 1_000_000
🔄 SPI Data Transfer

The SPI Master performs the following sequence:

START
  ↓
CS = LOW
  ↓
Send TX DATA through MOSI
  ↓
Generate SCLK
  ↓
Sample MISO
  ↓
Receive RX DATA
  ↓
CS = HIGH
  ↓
DONE
🧪 Verification

The design was verified using a Verilog testbench in Xilinx Vivado XSim.

Test Data
TX DATA    = A5
SLAVE DATA = 3C
RX DATA    = 3C

The following signals were verified in the simulation waveform:

clk
start
tx_data
rx_data
busy
done
sclk
mosi
miso
cs
📂 Project Structure
SPI-Master-Verilog/
│
├── spi_master.v
├── spi_master_tb.v
├── README.md
│
└── screenshots/
    └── spi_master_waveform.png
📸 Simulation Result

Add your successful Vivado waveform screenshot to the screenshots folder.

🎯 Learning Outcomes

This project demonstrates:

RTL design using Verilog
SPI communication protocol
Clock divider design
Shift-register based data transfer
FSM/control logic
Serial data transmission and reception
Functional simulation and verification
👨‍💻 Author

Deekshith N N

Electronics and Communication Engineering

Interests: VLSI | Verilog | RTL Design | Embedded Systems

8-bit SPI Master Controller designed and verified using Verilog HDL and Xilinx Vivado.
