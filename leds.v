//------------------------------------------------------------------
//-- Hello world example for the iCEstick board
//-- Turn on all the leds
//------------------------------------------------------------------

module leds(input wire reset,
            input wire CLK,
            input wire SW1,
            input wire SDA_IN,
            output wire SCL,
            inout SDA,//output wire SDA,
            output wire LED0,
            output wire LED1,
            output wire LED2,
            output wire LED3,
            output wire LED4,
            output wire LED5,
            output wire LED6,
            output wire LED7,
            output wire motor_left);


localparam  STATE_IDLE = 0;
localparam  STATE_CONFIG = 1;
localparam  STATE_START_WAIT = 2;
localparam  STATE_START_ONE = 3;
localparam  STATE_START_TWO = 4;
localparam  STATE_SAVE_MSB = 5;
localparam  STATE_SAVE_WAIT = 6;
localparam  STATE_SAVE_LSB = 7;
localparam  STATE_WAIT =8;
localparam  STATE_START_READ = 9;


reg [8:0] state_gen;
reg [6:0] adc_addr;
reg [7:0] adc_data;
wire reg [7:0] adc_data_out;
reg [15:0] adc_register;
wire adc_ready;
reg adc_rw;
reg [4:0]adc_packets;
wire adc_data_req;
reg adc_start;
reg adc_reset;
wire adc_data_ready;
wire clk_i2c;
reg clk_reset;

wire reg adc_scl;
reg [9:0] delay_count=0;

wire reg adc_sda;

reg [7:0]pwm_pos = 255; //0-255 7bit

parameter newwidth = 7;
parameter newN = 30;



clk_divn clk_di(.clk_fpga (CLK), .reset (clk_reset), .clk_out (clk_i2c));

i2c_master i2c(.clk(clk_i2c), /*.i2c_sda*/.SDAA(SDA), .i2c_scl(adc_scl), /*.i2c_sda_in(SDA_IN),*/ .addr(adc_addr), .data(adc_data), .reset(adc_reset), .packets(adc_packets), .rw(adc_rw), .start(adc_start), .ready(adc_ready), .data_req(adc_data_req), .data_ready(adc_data_ready), .data_out(adc_data_out));

//ServoUnit pwm(.clk(CLK), .pos(adc_register[15:8]), .servo(motor_left));

assign  SCL = adc_scl;

assign {LED0, LED1, LED2, LED3, LED4, LED5} = adc_register[15:10];
assign LED7 = clk_i2c;
assign LED6 = CLK;

initial begin
  state_gen<=STATE_IDLE;
  delay_count = 0;
end

always @ ( posedge clk_i2c/*CLK*/, posedge reset) begin

      if(reset == 1) begin
        state_gen<= STATE_IDLE;
        adc_addr<=7'b1001000; //address from the adc
        adc_packets=2; //number of data packets
        adc_rw<=0;  //write data
        adc_reset<=1;
        adc_start<=0;
        adc_data<=8'b00000000;  // Adress pointer "0x00" it is the config register of the adc

      end
      else begin
            case (state_gen)
                  STATE_IDLE: begin
                        adc_reset<=0;
                        state_gen<=STATE_CONFIG;
                  end
                  STATE_CONFIG: begin
                        clk_reset =0;
                        adc_start <= 1;
                        if(adc_ready == 0) begin
                        state_gen<=STATE_START_WAIT;
                        end
                  end
                  STATE_START_WAIT: begin
                        if(adc_data_req == 1) state_gen <= STATE_START_ONE;
                  end
                  STATE_START_ONE:  begin
                        adc_data<=8'b11000001;  //Manual single mode (written in the config register)
                        if(adc_ready == 0 && adc_data_req == 1) state_gen<=STATE_START_READ;
                  end
                  STATE_START_READ: begin
                        adc_start = 0;
                        adc_packets <= 1;
                        if(adc_ready) begin
                          adc_data <= 8'b00000100;    //MSB register of the adc1 input
                          adc_start <= 1;
                          state_gen<= STATE_START_TWO;
                        end
                  end

                  STATE_START_TWO:  begin
                        adc_start = 0;
                        adc_rw <= 1;
                        adc_packets <= 1;//2;
                        if(adc_ready) begin
                        adc_start = 1;
                        state_gen<=STATE_SAVE_MSB;
                        end
                  end
                  STATE_SAVE_MSB: begin
                        adc_start = 1;
                        if(adc_data_ready) begin
                            state_gen<=STATE_SAVE_WAIT;
                            //if(adc_data_out ^ 8'hff )
                            adc_register[15:8] <= adc_data_out;   //Store data in an register
                        end
                  end
                  STATE_SAVE_WAIT: begin
                        if(adc_data_ready==0) state_gen<=STATE_WAIT;
                  end
                  STATE_SAVE_LSB: begin                 //Not used until now
                        adc_register[7:0] <= adc_data_out;
                        adc_start = 0;
                        if(adc_ready) state_gen<=STATE_WAIT;
                  end
                  STATE_WAIT: begin                 //Wait a bit befor the next read begin
                    delay_count = delay_count + 1;
                        adc_start = 0;
                    if(delay_count > 500)begin
                        state_gen <= STATE_START_TWO; //goes directly to the read command.
                        delay_count = 0;
                        end
                    end
            endcase
      end
end




endmodule
