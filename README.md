# PicoBlaze UART Loopback Design on FPGA

## Overview
This project implements a UART loopback system using the PicoBlaze microprocessor on a Xilinx FPGA using Verilog HDL.

The design integrates the PicoBlaze soft-core processor with UART communication modules to transmit and receive serial data through RS232.

---

## Features
- PicoBlaze microprocessor integration
- UART-based serial communication
- RS232 loopback functionality
- Verilog HDL implementation
- 16x UART oversampling
- Baud-rate tick generation
- LED and switch interfacing
- Assembly program integration

---

## System Architecture

The design consists of:
- `loopback` top module
- PicoBlaze (`kcpsm6`) processor
- UART transmitter and receiver
- Program ROM
- Baud-rate generator

The PicoBlaze processor communicates with UART modules through mapped port IDs and handles data transmission and reception.

---

## Design Description

### UART Timing
The system uses:
- Baud Rate: `9600`
- Oversampling Rate: `16x`
- Calculated Baud Tick Count: `650`

A baud-rate counter was implemented to generate the correct UART timing for reliable serial communication.

---

## Main Functionalities
- Receives serial data through UART RX
- Sends serial data through UART TX
- Displays output using LEDs
- Reads FPGA switch inputs
- Supports assembly-level message transmission
- Implements loopback communication

---

## Assembly Integration
The project also involved modifying PicoBlaze assembly code to display custom messages such as:

```text
Hello World
```

The assembly program was compiled and connected to the FPGA design using the provided `kcpsm6` tools.

---

## Technologies Used

| Component | Description |
|----------|-------------|
| FPGA | Xilinx FPGA |
| HDL | Verilog |
| Processor | PicoBlaze (kcpsm6) |
| Communication | UART / RS232 |
| Language | PicoBlaze Assembly |

---

## Learning Outcomes
This project helped develop understanding of:
- FPGA embedded systems
- UART communication protocols
- PicoBlaze microprocessor architecture
- Verilog HDL integration
- Assembly language programming
- Baud-rate generation and oversampling

---

## Author

Taha
