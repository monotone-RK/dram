/****************************************************************************************/
/* Clock & Reset Generator                                                              */
/****************************************************************************************/
`default_nettype none
  
`include "define.v"


module CLKRSTGEN(input  wire CLK_IN,
                 input  wire RST_X_IN,
                 output wire USER_CLK,
                 output wire DRAM_CLK,
                 output wire RST_X);

  wire clk_t;
  wire locked;
  wire locked2;
  
  IBUFG     ibuf(.I(CLK_IN), .O(clk_t));
  clockgen  clkgen(clk_t, USER_CLK, locked);
  clockgen2 clkgen2(clk_t, DRAM_CLK, locked2);  
  resetgen  rstgen(USER_CLK, (RST_X_IN & locked & locked2), RST_X);

endmodule


/* Clock Generator                                                                      */
/****************************************************************************************/
module clockgen(input  wire CLK_IN, 
                output wire CLK_OUT, 
                output wire LOCKED);

  wire   CLK_OBUF, CLK_IBUF, CLK0, CLK0_OUT;

  BUFG   obuf (.I(CLK_OBUF), .O(CLK_OUT));
  BUFG   fbuf (.I(CLK0),     .O(CLK0_OUT));
  // IBUFG  ibuf (.I(CLK_IN),   .O(CLK_IBUF));
  assign CLK_IBUF = CLK_IN;
    
  DCM_SP dcm (.CLKIN(CLK_IBUF), .CLKFX(CLK_OBUF), .CLK0(CLK0), .CLKFB(CLK0_OUT),
              .LOCKED(LOCKED), .RST(1'b0), .DSSEN(1'b0), .PSCLK(1'b0),
              .PSEN(1'b0), .PSINCDEC(1'b0));
  defparam dcm.CLKFX_DIVIDE   = `DCM_CLKFX_DIVIDE;
  defparam dcm.CLKFX_MULTIPLY = `DCM_CLKFX_MULTIPLY;
  defparam dcm.CLKIN_PERIOD   = `DCM_CLKIN_PERIOD;
endmodule

module clockgen2(input  wire CLK_IN, 
                 output wire CLK_OUT, 
                 output wire LOCKED);

  wire   CLK_OBUF, CLK_IBUF, CLK0, CLK0_OUT;

  BUFG   obuf (.I(CLK_OBUF), .O(CLK_OUT));
  BUFG   fbuf (.I(CLK0),     .O(CLK0_OUT));
  // IBUFG  ibuf (.I(CLK_IN),   .O(CLK_IBUF));
  assign CLK_IBUF = CLK_IN;
    
  DCM_SP dcm (.CLKIN(CLK_IBUF), .CLKFX(CLK_OBUF), .CLK0(CLK0), .CLKFB(CLK0_OUT),
              .LOCKED(LOCKED), .RST(1'b0), .DSSEN(1'b0), .PSCLK(1'b0),
              .PSEN(1'b0), .PSINCDEC(1'b0));
  defparam dcm.CLKFX_DIVIDE   = `DCM_DRAMC_DIVIDE;
  defparam dcm.CLKFX_MULTIPLY = `DCM_DRAMC_MULTIPLY;
  defparam dcm.CLKIN_PERIOD   = `DCM_CLKIN_PERIOD;
endmodule

/* Reset Generator :  generate about 1000 cycle reset signal                            */
/****************************************************************************************/
module resetgen(input  wire CLK, 
                input  wire RST_X_I, 
                output wire RST_X_O);

  reg [11:0] cnt;
  assign RST_X_O = cnt[11];

  always @(posedge CLK) begin
    if      (!RST_X_I) cnt <= 0;
    else if (~RST_X_O) cnt <= cnt + 1;
  end
  
endmodule
`default_nettype wire
/****************************************************************************************/
