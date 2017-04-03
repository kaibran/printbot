//-------------------------------------------------------------------
//-- leds_tb.v
//-- Testbench
//-------------------------------------------------------------------
//-- Juan Gonzalez (Obijuan)
//-- Jesus Arroyo Torrens
//-- GPL license
//-------------------------------------------------------------------
`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 10 ns / 10 ns

module leds_tb();

//-- Simulation time: 1us (10 * 100ns)
parameter DURATION = 100000;

//-- input declaration
reg reset_sim;
reg SW1_sim;
//wire SDA_IN_sim;
//-- output declaration
wire SCL_sim;
wire SDA_sim;
//-- Clock signal. It is not used in this simulation
reg clk_sim = 0;
always #2 clk_sim = ~clk_sim;

//-- Leds port
wire led0, led1, led2, led3, led4, led5, led6, led7;

//-- Instantiate the unit to test
leds UUT ( .reset(reset_sim),
            .CLK(clk_sim),
            .SW1(SW1_sim),
            //.SDA_IN(SDA_IN_sim),
            .SCL(SCL_sim),
            .SDA(SDA_sim),
           .LED0(led0),
           .LED1(led1),
           .LED2(led2),
           .LED3(led3),
           .LED4(led4),
           .LED5(led5),
           .LED6(led6),
           .LED7(led7)
         );


initial begin

  //-- File were to store the simulation results
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, leds_tb);
    #1  reset_sim = 0;
    #1  reset_sim = 1;
    #10  reset_sim = 0;
  //    #70 SDA_sim=0;
//    #90 SDA_sim=z;
    #1500 reset_sim = 1;
    #100    reset_sim = 0;
   #(DURATION) $display("End of simulation");
  $finish;
end

endmodule
