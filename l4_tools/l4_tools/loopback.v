
// 
// This is the top level design.  It needs a
// bit of work; search for <FILL_IN> and
// find out what you should replace it
// with to make the design work right...

// The `timescale directive specifies what
// the simulation time units are (1 ns here)
// and what the simulator timestep should be
// (1 ps here).

`timescale 1 ns / 1 ps

module loopback(clk, rst, leds, switches, rs232_tx, rs232_rx);

  input         clk, rst;
  output  [7:0] leds;
  input   [7:0] switches;
  input         rs232_rx;
  output        rs232_tx;

  // Instantiate PicoBlaze and the instruction
  // ROM.  This is simply cut and paste from the
  // example designs that come with PicoBlaze.
  // Interrupts are not used for this design.

  wire [11:0] address;
  wire [17:0] instruction;
  wire bram_enable;
  wire [7:0] port_id;
  wire [7:0] out_port;
  reg [7:0] in_port;
  wire write_strobe;
  wire k_write_strobe;
  wire read_strobe;
  wire interrupt_ack;

   kcpsm6 kcpsm6_inst (
    .address(address),
    .instruction(instruction),
    .bram_enable(bram_enable),
    .port_id(port_id),
    .write_strobe(write_strobe),
    .k_write_strobe(k_write_strobe),
    .out_port(out_port),
    .read_strobe(read_strobe),
    .in_port(in_port),
    .interrupt(1'b0),
    .interrupt_ack(interrupt_ack),
    .reset(1'b0),
    .sleep(1'b0),
    .clk(clk)
  ); 


  program my_program (
    .address(address),
    .instruction(instruction),
    .bram_enable(bram_enable),
    .clk(clk)
    );

  // Implement the 16x bit rate counter
  // for the uart transmit and receive.
  // The system clock is 50 MHz, and the
  // desired baud rate is 9600.  I used
  // the formula in the documentation to
  // calculate the terminal count value.

  reg     [8:0] baud_count;
  reg           en_16_x_baud;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      baud_count <= 0;
      en_16_x_baud <= 0;
    end
    else
    begin
      if (baud_count == <FILL_IN>)
      begin
        baud_count <= 0;
        en_16_x_baud <= 1;
      end
      else
      begin
        baud_count <= baud_count + 1;
        en_16_x_baud <= 0;
      end
    end
  end

  // Implement the output port logic:
  // leds_out, port 01
  // uart_data_tx, port 03

  wire          write_to_uart;
  wire          write_to_leds;
  wire          buffer_full;
  reg     [7:0] leds;

  assign write_to_uart = write_strobe & (port_id == 8'h<FILL_IN>);
  assign write_to_leds = write_strobe & (port_id == 8'h<FILL_IN>);

  always @(posedge clk or posedge rst)
  begin
    if (rst) leds <= 0;
    else if (write_to_leds) leds <= out_port;
  end

  uart_tx transmit (
    .data_in(out_port), 
    .write_buffer(write_to_uart),
    .reset_buffer(rst),
    .en_16_x_baud(en_16_x_baud),
    .serial_out(rs232_tx),
    .buffer_full(buffer_full),
    .buffer_half_full(),
    .clk(clk)
    );

  // Implement the input port logic:
  // switch_in, port 00
  // uart_data_rx, port 02
  // data_present, port 04
  // buffer_full, port 05

  reg           read_from_uart;
  wire    [7:0] rx_data;
  wire          data_present;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      in_port <= 0;
      read_from_uart <= 0;
    end
    else
    begin
      case (port_id)
        8'h<FILL_IN>: in_port <= <FILL_IN>;
        8'h<FILL_IN>: in_port <= rx_data;
        8'h<FILL_IN>: in_port <= {7'b0000000, data_present};
        8'h<FILL_IN>: in_port <= {7'b0000000, buffer_full};
        default: in_port <= 8'h00;
      endcase
      read_from_uart <= read_strobe & (port_id == 8'h<FILL_IN>);
    end
  end

  uart_rx receive (
    .serial_in(rs232_rx),
    .data_out(rx_data),
    .read_buffer(read_from_uart),
    .reset_buffer(rst),
    .en_16_x_baud(en_16_x_baud),
    .buffer_data_present(data_present),
    .buffer_full(),
    .buffer_half_full(),
    .clk(clk)
    );  

endmodule