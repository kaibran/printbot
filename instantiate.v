module inst (
 inout pin,
 input oe,
 input din,
 output dout
);
   SB_IO #(
       .PIN_TYPE(6'b1010_01),
       .PULLUP(1'b0)
   ) triState (
       .PACKAGE_PIN(pin),
       .OUTPUT_ENABLE(!oe),
       .D_OUT_0(din),
       .D_IN_0(dout)
   );
endmodule
