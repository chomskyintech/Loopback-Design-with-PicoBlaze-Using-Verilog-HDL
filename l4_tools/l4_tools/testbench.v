// 
// This is a top level testbench for the
// loopback design

// The `timescale directive specifies what
// the simulation time units are (1 ns here)
// and what the simulator timestep should be
// (1 ps here).

`timescale 1 ns / 1 ps

module loopback_testbench_v_tf();

  // Declare wires to be driven by the outputs
  // of the design, and regs to drive the inputs.
  // The testbench will be in control of inputs
  // to the design, and will check the outputs.
  // One exception here is the serial port loop.
  // Then, instantiate the design to be tested.

  wire rs232;
  wire [7:0] leds;
  reg [7:0] switches;
  reg clk, rst;

  loopback my_loopback (
        .clk(clk), 
        .rst(rst), 
        .leds(leds), 
        .switches(switches), 
        .rs232_tx(rs232), 
        .rs232_rx(rs232)
        );

  // Describe two processes that generate clock
  // and reset signals.  The clock is 50 MHz, and
  // let's assume the reset button is pressed at
  // time zero for a short period of time, then
  // released.

  always
  begin
    clk = 1'b1;
    #10;
    clk = 1'b0;
    #10;
  end

  initial
  begin
    rst = 1'b1;
    #110;
    rst = 1'b0;
  end

  // Task for waiting an arbitrary
  // number of system clock cycles.

  task CYCLE_WAIT;
    input [31:0] cycles;
    integer cyc_cnt;
  begin
    cyc_cnt = cycles;
    while (cyc_cnt)
    begin
      cyc_cnt = cyc_cnt - 1;
      @(posedge clk);
    end
  end
  endtask

  // Assign values to the input signals and
  // check the output results.  This template
  // is meant to get you started, you can modify
  // it as you see fit.  If you simply run it as
  // provided, you will need to visually inspect
  // the output waveforms to see if they make
  // sense...

  initial
  begin
    $display("If simulation ends prematurely, restart");
    $display("using 'run -all' on the command line.");
    switches <= 8'b00000000;
    // Wait until reset is deasserted.
    @(negedge rst);
    $display("Reset is deasserted...");
    // Wait for a while, this is time to let the cold
    // reset code execute on picoblaze before the main
    // loop begins to execute.
    CYCLE_WAIT(1000);
    // Apply a pattern to the switches and then check
    // that it appears on the LEDs after a short time.
    switches <= 8'b10101010;
    CYCLE_WAIT(20);
    if (leds == switches) $display("PASS: LEDs equal switches.");
    else $display("FAIL: LEDs do not match switches.");
    // Apply a pattern to the switches and then check
    // that it appears on the LEDs after a short time.
    switches <= 8'b01010101;
    CYCLE_WAIT(20);
    if (leds == switches) $display("PASS: LEDs equal switches.");
    else $display("FAIL: LEDs do not match switches.");
    // Wait for a while, this is time to let the rs232
    // interface shuffle some bits around.  There should
    // be activity on the rs232 signal.
    CYCLE_WAIT(1000);
    // End the simulation.
    $display("Simulation is over, check the waveforms.");
    $stop;
  end

endmodule