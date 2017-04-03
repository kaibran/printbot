module clk_divn #(
parameter WIDTH = 7,
parameter N = 60)

(clk_fpga,reset, clk_out);

input clk_fpga;
input reset;
output clk_out;

reg [WIDTH-1:0] pos_count = 0, neg_count = 0;
wire [WIDTH-1:0] r_nxt;

 always @(posedge clk_fpga)
 if (reset)
 pos_count <=0;
 else if (pos_count >= N-1) pos_count <= 0;
 else pos_count<= pos_count +1;

 always @(negedge clk_fpga)
 if (reset)
 neg_count <=0;
 else  if (neg_count >= N-1) neg_count <= 0;
 else neg_count<= neg_count +1;

assign clk_out = ((pos_count > (N>>1)) | (neg_count > (N>>1)));
endmodule
