# SPI Slave Interface with Single-Port RAM

## Project Overview

This project implements an SPI (Serial Peripheral Interface) slave system integrated with a synchronous single-port RAM. The system is designed using Verilog HDL and follows a complete FPGA design flow including simulation, synthesis, and implementation.

The SPI slave receives serial data from a master device through the MOSI line, converts it into parallel data, and performs memory operations such as read and write based on control commands. The RAM stores or retrieves data accordingly, and results are transmitted back through the MISO line.

---

## System Architecture

The system consists of three main modules:

* SPI Slave Module
  Handles serial communication, command decoding, and data shifting.

* Synchronous RAM Module
  Stores and retrieves data based on received commands.

* SPI Wrapper Module
  Connects the SPI slave and RAM modules together.

---

## Ports Description

### Top-Level Ports

| Signal | Direction | Width | Description               |
| ------ | --------- | ----- | ------------------------- |
| clk    | Input     | 1-bit | System clock              |
| rst    | Input     | 1-bit | Reset signal              |
| ss_n   | Input     | 1-bit | Slave select (active low) |
| MOSI   | Input     | 1-bit | Master Out Slave In       |
| MISO   | Output    | 1-bit | Master In Slave Out       |

---

## Internal RAM Interface

| Signal   | Direction | Width  | Description                   |
| -------- | --------- | ------ | ----------------------------- |
| Din      | Input     | 10-bit | Input data from SPI           |
| rx_valid | Input     | 1-bit  | Indicates valid received data |
| Dout     | Output    | 8-bit  | Data read from memory         |
| tx_valid | Output    | 1-bit  | Indicates valid output data   |

---

## RAM Specifications

* Memory Width: 8 bits
* Memory Depth: 256 locations
* Address Size: 8 bits

The RAM is synchronous and operates on the rising edge of the clock.

---

## Command Format

The command is encoded in the two most significant bits of the 10-bit input word:

| Din[9:8] | Operation Description |
| -------- | --------------------- |
| 00       | Hold write address    |
| 01       | Write data to memory  |
| 10       | Hold read address     |
| 11       | Read data from memory |

### Operation Details

* Write Address (00):
  Stores the address internally for the next write operation.

* Write Data (01):
  Writes data to the previously stored write address.

* Read Address (10):
  Stores the address internally for the next read operation.

* Read Data (11):
  Outputs data from the stored read address and asserts tx_valid.

---

## SPI Slave Design

### FSM States

* IDLE
* CHK_CMD
* WRITE
* READ_ADD
* READ_DATA

### State Description

* IDLE
  Waits for slave select activation.

* CHK_CMD
  Determines the operation type based on MOSI input.

* WRITE
  Receives 10-bit data serially from MOSI.

* READ_ADD
  Receives read address serially.

* READ_DATA
  Sends data serially through MISO when tx_valid is asserted.

---

## Data Flow

1. The master sends serial data through MOSI
2. The SPI slave collects bits serially
3. After receiving 10 bits, rx_valid is asserted
4. The RAM decodes the command and executes the operation
5. For read operations, RAM outputs data and asserts tx_valid
6. The SPI slave transmits the data through MISO

---

## Testbench

A self-checking testbench is implemented to verify functionality.

### Features

* Clock generation
* Reset testing
* Read and write operation verification
* Memory initialization using $readmemh

---

## Simulation

* Tool: QuestaSim
* Verifies:

  * FSM behavior
  * Data shifting
  * Read/write correctness

---

## Synthesis and Implementation

### Target Board

* Basys3 FPGA

### Encoding Techniques

* One-hot encoding
* Sequential encoding
* Gray encoding

Each method is analyzed for timing and resource utilization.

---

## Constraints

The design uses an XDC file to map signals to FPGA pins including:

* Clock
* Reset
* MOSI
* MISO

---

## Project Structure

```
SPI-Slave-System/
│
├── RTL/
│   ├── spi_slave.v
│   ├── sync_ram.v
│   └── spi_wrapper.v
│
├── TB/
│   └── spi_tb.v
│
├── SIM/
│   ├── spi.do
│   └── waveform.png
│
├── SYNTH/
│   ├── one_hot/
│   ├── sequential/
│   └── gray/
│
├── CONSTRAINTS/
│   └── basys3.xdc
│
├── REPORT/
│   └── SPI_Report.pdf
│
└── README.md
```

---

## Tools Used

* Verilog HDL
* QuestaSim
* Xilinx Vivado

---

## Conclusion

This project demonstrates a complete digital design flow from RTL design to FPGA implementation. It highlights SPI communication, FSM design, and memory interfacing. The system successfully performs reliable read and write operations using an SPI protocol with a synchronous RAM module.
