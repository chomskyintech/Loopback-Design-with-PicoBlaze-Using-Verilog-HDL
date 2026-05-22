
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


  wire    [11:0] address;
  wire   [17:0] instruction;
  wire    [7:0] port_id;
  wire    [7:0] out_port;
  reg     [7:0] in_port;
  wire          write_strobe;
  wire          read_strobe;


// Following signals are for kcpsm6 only, interrupt and sleep are not used.
  wire		k_write_strobe;
  wire		bram_enable;  
  reg		kcpsm6_reset;

  assign kcpsm6_reset = rst; 

  kcpsm6 #(
	   .interrupt_vector	(12'h3FF),
	   .scratch_pad_memory_size(64),
	   .hwbuild		(8'h00))
    my_kcpsm6 (
	   .address 		(address),
	   .instruction 	(instruction),
	   .bram_enable 	(bram_enable),
	   .port_id 		(port_id),
	   .write_strobe 	(write_strobe),
	   .k_write_strobe 	(k_write_strobe),
	   .out_port 		(out_port),
	   .read_strobe 	(read_strobe),
	   .in_port 		(in_port),
	   .interrupt 		(1'b0),
	   .interrupt_ack 	(),
	   .reset 		(kcpsm6_reset),
	   .sleep		(1'b0),
	   .clk 		(clk));

  program #(    
	.C_FAMILY		("7S"),   	  //Family '7S', 'S6' or 'V6'
	.C_RAM_SIZE_KWORDS	(2),  	          //Program size '1', '2' or '4'
	.C_JTAG_LOADER_ENABLE	(0))  	          //Include JTAG Loader when set to '1' 
  my_program (    				  // Rename if using more than 1 ROM
 	.rdl 			(),               // Try leaving it unconnected
 	//.rdl 			(kcpsm6_reset),   // Leaving this connected throws an error in synthesis
	.enable 		(1'b1),
	.address 		(address),
	.instruction 	        (instruction),
	.clk 			(clk));
    
  

  // Implement the 16x bit rate counter
  // for the uart transmit and receive.
  // The system clock is 100 MHz, and the
  // desired baud rate is 9600.  You should use
  // the formula in the lab tutorial to
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

  uart_tx6 transmit (
    .data_in(out_port), 
    .buffer_write(write_to_uart),
    .buffer_reset(rst),
    .en_16_x_baud(en_16_x_baud),
    .serial_out(rs232_tx),
    .buffer_data_present(),
    .buffer_half_full(),
    .buffer_full(buffer_full),
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

  uart_rx6 receive (
    .serial_in(rs232_rx),
    .en_16_x_baud(en_16_x_baud),
    .data_out(rx_data),
    .buffer_read(read_from_uart),
    .buffer_data_present(data_present),
    .buffer_half_full(),
    .buffer_full(),
    .buffer_reset(rst),
    .clk(clk)
    );  

endmodule