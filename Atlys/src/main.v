/******************************************************************************/
/* Test Module for DRAM on Atlys Board                 monotone-RK 2014.11.01 */
/******************************************************************************/
`default_nettype none
  
module main(input  wire        CLK_IN, 
            input  wire        RST_X_IN, 
            output wire [7:0]  ULED, 
            output wire        DDR2CLK0, 
            output wire        DDR2CLK1, 
            output wire        DDR2CKE, 
            output wire        DDR2RASN, 
            output wire        DDR2CASN, 
            output wire        DDR2WEN, 
            output wire        DDR2RZQ, 
            output wire [2:0]  DDR2BA, 
            output wire [12:0] DDR2A, 
            inout  wire [15:0] DDR2DQ, 
            inout  wire        DDR2UDQS, 
            inout  wire        DDR2UDQSN, 
            inout  wire        DDR2LDQS, 
            inout  wire        DDR2LDQSN, 
            output wire        DDR2LDM, 
            output wire        DDR2UDM, 
            output wire        DDR2ODT, 
            output wire        DDR2ZIO);
  
/* Generate Clock and Reset                                                   */  
/******************************************************************************/
  wire CLK;       // for User Logic
  wire DRAM_CLK;  // for DRAM
  wire RST_X;     // Reset Signal(Low Active)
  
  CLKRSTGEN clkrstgen(CLK_IN, RST_X_IN, CLK, DRAM_CLK, RST_X);

/* DRAM Controller Instantiation                                              */  
/******************************************************************************/
  wire         calib_done;
  reg  [31:0]  mem_adr;    
  reg          mem_we; 
  reg          mem_re;     
  reg  [127:0] mem_wr_dat; 
  wire [127:0] mem_rd_dat; 
  wire         mem_busy;   
  wire         rdvalid;
  
  DRAMCON dramcon(.CLK             (CLK), 
                  .DRAM_CLK        (DRAM_CLK), 
                  .RST_X           (RST_X),
                  // User Logic Interface Ports
                  .calib_done      (calib_done), 
                  .D_ADR           (mem_adr), 
                  .D_DIN           (mem_wr_dat), 
                  .D_WE            (mem_we), 
                  .D_RE            (mem_re), 
                  .D_DOUT          (mem_rd_dat), 
                  .D_BUSY          (mem_busy),
                  .D_DOUTVALID     (rdvalid),
                  // DRAM Interface Ports
                  .DDR2CLK0        (DDR2CLK0),
                  .DDR2CLK1        (DDR2CLK1),
                  .DDR2CKE         (DDR2CKE),
                  .DDR2RASN        (DDR2RASN),
                  .DDR2CASN        (DDR2CASN),
                  .DDR2WEN         (DDR2WEN),
                  .DDR2RZQ         (DDR2RZQ),   
                  .DDR2ZIO         (DDR2ZIO),
                  .DDR2BA          (DDR2BA),   
                  .DDR2A           (DDR2A),
                  .DDR2DQ          (DDR2DQ),
                  .DDR2UDQS        (DDR2UDQS),    
                  .DDR2UDQSN       (DDR2UDQSN),  
                  .DDR2LDQS        (DDR2LDQS),
                  .DDR2LDQSN       (DDR2LDQSN),     
                  .DDR2LDM         (DDR2LDM),  
                  .DDR2UDM         (DDR2UDM),   
                  .DDR2ODT         (DDR2ODT));

/* User Logic(DRAM Test Circuit)                                              */  
/******************************************************************************/
  
`define MEM_TEST_END_ADDR  (({22{1'b1}}) << 4)
/* 2^(i+4)Byte Write and Read                                                 */
/* e.g. when (({22{1'b1}}) << 4), i is 22, then 2^(26) = 64M. Hence 64MB      */
  
  reg [31:0] a;  // 128MB (2^27 byte address) read, write byte address
  reg        err;
  reg [1:0]  state;
  
  parameter D_WRITE      = 0; // D_WRITE must be 0
  parameter D_READ       = 1;
  parameter D_READ_CHECK = 2;
  
  always @(posedge CLK) begin
    if (!RST_X) begin 
      a          <= 0;
      state      <= 0;
      err        <= 0;
      mem_wr_dat <= 0;
      mem_adr    <= 0;
      mem_we     <= 0;
      mem_re     <= 0;
    end else if (mem_busy) begin
      mem_re     <= 0;
      mem_we     <= 0;
    end else begin
	 case (state)
	   D_WRITE: begin  // write phase
		mem_adr            <= a;
		mem_wr_dat[31:0]   <= a; 
		mem_wr_dat[63:32]  <= a+4; 
		mem_wr_dat[95:64]  <= a+8; 
		mem_wr_dat[127:96] <= a+12; 
		mem_we             <= 1;                
		if (a == `MEM_TEST_END_ADDR) begin  // if (a is 0xfffff...) 
            state <= D_READ; 
            a     <= 0;
		end else begin
		  a <= a + 16;
		end
	   end
	   D_READ: begin  // read command
		mem_re  <= 1;
		mem_adr <= a;
		state   <= D_READ_CHECK;
	   end
	   D_READ_CHECK: begin  // read data is available
		if (rdvalid) begin  
		  state <= D_READ;
		  a     <= (a==`MEM_TEST_END_ADDR) ? 0 : a + 16;
		  if ((mem_rd_dat[31:0]  != a)   || (mem_rd_dat[63:32]  != a+4) || 
                (mem_rd_dat[95:64] != a+8) || (mem_rd_dat[127:96] != a+12)) begin 
		    err <= 1;
		  end
		end 
	   end
	 endcase
    end 
  end

  assign ULED = (state == D_WRITE) ? {a[20:17], 4'b1010} : // writing to DRAM
                                     {mem_rd_dat[24:18], err};

endmodule
`default_nettype wire
/******************************************************************************/
