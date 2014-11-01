`default_nettype none

`define DRAM_CMD_WRITE    3'b000
`define DRAM_CMD_WRITE_AP 3'b010
`define DRAM_CMD_READ     3'b001
`define DRAM_CMD_READ_AP  3'b011
  
module DRAMCON(input  wire         CLK, 
               input  wire         DRAM_CLK, 
               input  wire         RST_X, 
               output wire         calib_done, 
               input  wire [31:0]  D_ADR, 
               input  wire [127:0] D_DIN, 
               output reg  [127:0] D_DOUT,
               output reg          D_DOUTVALID,
               input  wire         D_WE, 
               input  wire         D_RE, 
               output wire         D_BUSY,
               output wire         DDR2CLK0, 
               output wire         DDR2CLK1, 
               output wire         DDR2CKE, 
               output wire         DDR2RASN, 
               output wire         DDR2CASN, 
               output wire         DDR2WEN, 
               output wire         DDR2RZQ, 
               output wire         DDR2ZIO, 
               output wire [2:0]   DDR2BA, 
               output wire [12:0]  DDR2A, 
               inout  wire [15:0]  DDR2DQ, 
               inout  wire         DDR2UDQS, 
               inout  wire         DDR2UDQSN, 
               inout  wire         DDR2LDQS, 
               inout  wire         DDR2LDQSN, 
               output wire         DDR2LDM, 
               output wire         DDR2UDM, 
               output wire         DDR2ODT, 
               output wire         DDR2RZM);
    
  // port 0 ///////////////////////////////////////////////
  wire         c3_p0_cmd_empty, c3_p0_cmd_full;
  reg  [31:0]  c3_p0_cmd_byte_addr;
  reg          c3_p0_cmd_en;     // command enqueue
  reg  [2:0]   c3_p0_cmd_instr;  // command
  wire         c3_p0_wr_full, c3_p0_wr_empty;
  wire [6:0]   c3_p0_wr_count;
  wire         c3_p0_wr_underrun, c3_p0_wr_error;  // not enough data in write FIFO, or FIFO sync miss
  reg          c3_p0_wr_en;
  reg  [127:0] c3_p0_wr_data;
  wire [127:0] c3_p0_rd_data;  // head of read fifo
  wire         c3_p0_rd_empty;
  wire         c3_p0_rd_full;
  wire         c3_p0_rd_overflow, c3_p0_rd_error;
  wire [6:0]   c3_p0_rd_count;  // read fifo entry

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

 dram # (
    .C3_P0_MASK_SIZE(16),
    .C3_P0_DATA_PORT_SIZE(128),
    .DEBUG_EN(0),
    .C3_MEMCLK_PERIOD(3000),
    .C3_CALIB_SOFT_IP("TRUE"),
    .C3_SIMULATION("FALSE"),
    .C3_RST_ACT_LOW(0),
    .C3_INPUT_CLK_TYPE("SINGLE_ENDED"),
    .C3_MEM_ADDR_ORDER("ROW_BANK_COLUMN"),
    .C3_NUM_DQ_PINS(16),
    .C3_MEM_ADDR_WIDTH(13),
    .C3_MEM_BANKADDR_WIDTH(3)
)
u_dram (
    .c3_sys_clk             (DRAM_CLK),
    .c3_sys_rst_i           (0),                        

    .mcb3_dram_dq           (DDR2DQ),  
    .mcb3_dram_a            (DDR2A),  
    .mcb3_dram_ba           (DDR2BA),
    .mcb3_dram_ras_n        (DDR2RASN),                        
    .mcb3_dram_cas_n        (DDR2CASN),                        
    .mcb3_dram_we_n         (DDR2WEN),                          
    .mcb3_dram_odt          (DDR2ODT),
    .mcb3_dram_cke          (DDR2CKE),                          
    .mcb3_dram_ck           (DDR2CLK0),                          
    .mcb3_dram_ck_n         (DDR2CLK1),       
    .mcb3_dram_dqs          (DDR2LDQS),                          
    .mcb3_dram_dqs_n        (DDR2LDQSN),
    .mcb3_dram_udqs         (DDR2UDQS),   // for X16 parts                        
    .mcb3_dram_udqs_n       (DDR2UDQSN),  // for X16 parts
    .mcb3_dram_udm          (DDR2UDM),    // for X16 parts
    .mcb3_dram_dm           (DDR2LDM),
    .c3_clk0		        (),
    .c3_rst0		        (),
    .c3_calib_done          (calib_done),
    .mcb3_rzq               (DDR2RZQ),
    .mcb3_zio               (DDR2ZIO),
               
    .c3_p0_cmd_clk          (CLK),
    .c3_p0_cmd_en           (c3_p0_cmd_en),
    .c3_p0_cmd_instr        (c3_p0_cmd_instr),
    .c3_p0_cmd_bl           (0),
    .c3_p0_cmd_byte_addr    (c3_p0_cmd_byte_addr),
    .c3_p0_cmd_empty        (c3_p0_cmd_empty),
    .c3_p0_cmd_full         (c3_p0_cmd_full),

    .c3_p0_wr_clk           (CLK),
    .c3_p0_wr_en            (c3_p0_wr_en),
    .c3_p0_wr_mask          ({16{1'b0}}),
    .c3_p0_wr_data          (c3_p0_wr_data),
    .c3_p0_wr_full          (c3_p0_wr_full),
    .c3_p0_wr_empty         (c3_p0_wr_empty),
    .c3_p0_wr_count         (c3_p0_wr_count),
    .c3_p0_wr_underrun      (c3_p0_wr_underrun),
    .c3_p0_wr_error         (c3_p0_wr_error),

    .c3_p0_rd_clk           (CLK),
    .c3_p0_rd_en            (1),
    .c3_p0_rd_data          (c3_p0_rd_data),
    .c3_p0_rd_full          (c3_p0_rd_full),
    .c3_p0_rd_empty         (c3_p0_rd_empty),
    .c3_p0_rd_count         (c3_p0_rd_count),
    .c3_p0_rd_overflow      (c3_p0_rd_overflow),
    .c3_p0_rd_error         (c3_p0_rd_error)
);

// INST_TAG_END ------ End INSTANTIATION Template ---------

/******************************************************************************/
  parameter INIT       = 0; // INIT must be 0
  parameter WAIT_REQ   = 1;
  parameter WRITE_FIFO = 2;
  parameter WRITE_CMD  = 3;
  parameter READ_CMD   = 4;
  parameter READ_FIFO  = 5;
   
  ///// READ & WRITE PORT CONTROL //////////////////////////////////////
  ///// negedge sensitive
  assign D_BUSY = (state != WAIT_REQ);
    
  reg [2:0] state;
  always @(negedge CLK) begin
    if (!RST_X) begin
      state               <= 0;
      c3_p0_cmd_instr     <= 0;
      c3_p0_cmd_en        <= 0;
      c3_p0_cmd_byte_addr <= 0;
      c3_p0_wr_en         <= 0;
      c3_p0_wr_data       <= 0;
      D_DOUTVALID         <= 0;
    end else begin
	 case (state)
	   INIT: begin  // Initialize
		if (calib_done) state <= WAIT_REQ;
	   end
	   WAIT_REQ: begin  // Wait Request
		c3_p0_cmd_en         <= 0;
		c3_p0_cmd_byte_addr  <= D_ADR;
		c3_p0_wr_data        <= D_DIN;
		D_DOUTVALID          <= 0;
		if (D_WE)      state <= WRITE_FIFO;
		else if (D_RE) state <= READ_CMD;
	   end
	   WRITE_FIFO: begin
		if (c3_p0_wr_empty) begin
            c3_p0_wr_en <= 1;
            state       <= WRITE_CMD;
		end
	   end
	   WRITE_CMD: begin
		c3_p0_wr_en <= 0;
		if (c3_p0_cmd_empty) begin
            c3_p0_cmd_instr <= `DRAM_CMD_WRITE_AP;
            c3_p0_cmd_en    <= 1;
            state           <= WAIT_REQ;
		end
	   end
	   READ_CMD: begin
		if (c3_p0_cmd_empty && c3_p0_rd_empty) begin
            c3_p0_cmd_instr <= `DRAM_CMD_READ_AP;
            c3_p0_cmd_en    <= 1;
            state           <= READ_FIFO;
		end
	   end
	   READ_FIFO: begin
		c3_p0_cmd_en <= 0;
		if (!c3_p0_rd_empty && c3_p0_cmd_empty) begin
            D_DOUT      <= c3_p0_rd_data;
            D_DOUTVALID <= 1;
            state       <= WAIT_REQ;
		end
	   end
	 endcase
    end
  end
  
endmodule
`default_nettype wire
/******************************************************************************/
