/****************************************************************************************/
/* Clock Frequency Definition                                                           */
/* Clock Freq = (System Clock Freq) * (DCM_CLKFX_MULTIPLY) / (DCM_CLKFX_DIVIDE)         */
/****************************************************************************************/
`define SYSTEM_CLOCK_FREQ   100     // Atlys, Nexys4 -> 100 MHz,   VC707 -> 200 MHz
`define DCM_CLKIN_PERIOD    10.000  // Atlys, Nexys4 -> 10.000 ns, VC707 -> 5.000 ns

// note: CLKFX_MULTIPLY must be 2~32, CLKFX_DIVIDE must be 1~32

// for User Logic
`define DCM_CLKFX_MULTIPLY  4
`define DCM_CLKFX_DIVIDE    10

// for DRAM
`define DCM_DRAMC_MULTIPLY  8
`define DCM_DRAMC_DIVIDE    10
