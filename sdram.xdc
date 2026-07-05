## ============================================================
## Zybo Rev B - Constraint File
## Project  : SDR SDRAM Controller
## Target   : Xilinx Zynq XC7Z010 (Zybo Rev B)
##
## ???????????????????????????????????????????????????????????
## ?              COMPLETE PIN ASSIGNMENT TABLE              ?
## ???????????????????????????????????????????????????????????
## ? Signal       ? Pin      ? Location   ? Description      ?
## ???????????????????????????????????????????????????????????
## ? clk          ? L16      ? Onboard    ? 125 MHz clock    ?
## ? rst_n        ? Y16  button
## ? key[0]       ? R18      ? Onboard    ? Write trigger    ?
## ? key[1]       ? P16      ? Onboard    ? Read trigger     ?
## ? key[2]       ? V16      ? Onboard    ? Error inject en  ?
## ? led[0]       ? M14      ? Onboard    ? Controller ready ?
## ? led[1]       ? M15      ? Onboard    ? Write successful ?
## ? led[2]       ? G14      ? Onboard    ? Read successful  ?
## ? led[3]       ? D18      ? Onboard    ? Error detected   ?
## ???????????????????????????????????????????????????????????
## ? sdram_dq[0]  ? T20      ? JB pin 1   ? Data bus bit 0   ?
## ? sdram_dq[1]  ? U20      ? JB pin 2   ? Data bus bit 1   ?
## ? sdram_dq[2]  ? V20      ? JB pin 3   ? Data bus bit 2   ?
## ? sdram_dq[3]  ? W20      ? JB pin 4   ? Data bus bit 3   ?
## ? sdram_dq[4]  ? Y18      ? JB pin 7   ? Data bus bit 4   ?
## ? sdram_dq[5]  ? Y19      ? JB pin 8   ? Data bus bit 5   ?
## ? sdram_dq[6]  ? W18      ? JB pin 9   ? Data bus bit 6   ?
## ? sdram_dq[7]  ? W19      ? JB pin 10  ? Data bus bit 7   ?
## ???????????????????????????????????????????????????????????
## ? sdram_dq[8]  ? V15      ? JC pin 1   ? Data bus bit 8   ?
## ? sdram_dq[9]  ? W15      ? JC pin 2   ? Data bus bit 9   ?
## ? sdram_dq[10] ? T11      ? JC pin 3   ? Data bus bit 10  ?
## ? sdram_dq[11] ? T10      ? JC pin 4   ? Data bus bit 11  ?
## ? sdram_dq[12] ? W14      ? JC pin 7   ? Data bus bit 12  ?
## ? sdram_dq[13] ? Y14      ? JC pin 8   ? Data bus bit 13  ?
## ? sdram_dq[14] ? T12      ? JC pin 9   ? Data bus bit 14  ?
## ? sdram_dq[15] ? U12      ? JC pin 10  ? Data bus bit 15  ?
## ???????????????????????????????????????????????????????????
## ? sdram_clk    ? T14      ? JD pin 1   ? SDRAM clock out  ?
## ? sdram_cke    ? T15      ? JD pin 2   ? Clock enable     ?
## ? sdram_cs_n   ? P14      ? JD pin 3   ? Chip select      ?
## ? sdram_ras_n  ? R14      ? JD pin 4   ? Row addr strobe  ?
## ? sdram_cas_n  ? U14      ? JD pin 7   ? Col addr strobe  ?
## ? sdram_we_n   ? U15      ? JD pin 8   ? Write enable     ?
## ? sdram_ba[0]  ? V17      ? JD pin 9   ? Bank addr 0      ?
## ? sdram_ba[1]  ? V18      ? JD pin 10  ? Bank addr 1      ?
## ???????????????????????????????????????????????????????????
## ? sdram_addr[0]? V12      ? JE pin 1   ? Address bit 0    ?
## ? sdram_addr[1]? W16      ? JE pin 2   ? Address bit 1    ?
## ? sdram_addr[2]? J15      ? JE pin 3   ? Address bit 2    ?
## ? sdram_addr[3]? H15      ? JE pin 4   ? Address bit 3    ?
## ? sdram_addr[4]? V13      ? JE pin 7   ? Address bit 4    ?
## ? sdram_addr[5]? U17      ? JE pin 8   ? Address bit 5    ?
## ? sdram_addr[6]? T17      ? JE pin 9   ? Address bit 6    ?
## ? sdram_addr[7]? Y17      ? JE pin 10  ? Address bit 7    ?
## ???????????????????????????????????????????????????????????
## ?sdram_addr[8] ? N15      ? JA pin 1   ? Address bit 8    ?
## ?sdram_addr[9] ? L14      ? JA pin 2   ? Address bit 9    ?
## ?sdram_addr[10]? K16      ? JA pin 3   ? Address bit 10   ?
## ?sdram_addr[11]? K14      ? JA pin 4   ? Address bit 11   ?
## ?sdram_addr[12]? N16      ? JA pin 7   ? Address bit 12   ?
## ?sdram_dqm[0] ? L15      ? JA pin 8   ? Data mask low    ?
## ?sdram_dqm[1] ? J16      ? JA pin 9   ? Data mask high   ?
## ? rst_n        ? J14      ? JA pin 10  ? Active-low reset ?
## ???????????????????????????????????????????????????????????
##
## NOTE: sdram_dq[14:8] + dq[15] are all on JC (pins 1-4,7-10).
##       rst_n is on JA pin 10 (J14) - pull HIGH via 10k? to 3.3V,
##       button to GND to trigger reset.
##       DQ lines are bidirectional - use direct wires only.
## ============================================================


## ------------------------------------------------------------
## 1. CLOCK  -  125 MHz onboard oscillator
## ------------------------------------------------------------
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];


## ------------------------------------------------------------
## 2. PUSH BUTTONS  key[2:0]  -  onboard
##    key[0] = write trigger   (active low, debounced)
##    key[1] = read  trigger   (active low, debounced)
##    key[2] = error injection enable (held low = inject errors)

## ------------------------------------------------------------
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { key[0] }];
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { key[1] }];
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { key[2] }];
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { rst_n }];
#set_property INVERT [get_ports { rst_n }];  ## invert BTN3 so active-high becomes active-low
## ------------------------------------------------------------
## 3. STATUS / ERROR LEDs  led[3:0]  -  onboard
##    led[0] = controller ready
##    led[1] = write successful
##    led[2] = read  successful
##    led[3] = error detected
## ------------------------------------------------------------
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];


## ------------------------------------------------------------
## 4. PMOD JB  -  sdram_dq[7:0]
##    (previously seg_out[7:0], now repurposed as DQ low byte)
## ------------------------------------------------------------
## -- seg_out[7:0] REMOVED --
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[0] }];  ## JB pin 1
set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[1] }];  ## JB pin 2
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[2] }];  ## JB pin 3
set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[3] }];  ## JB pin 4
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[4] }];  ## JB pin 7
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[5] }];  ## JB pin 8
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[6] }];  ## JB pin 9
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[7] }];  ## JB pin 10


## ------------------------------------------------------------
## 5. PMOD JC  -  sdram_dq[15:8]  (all 8 pins of high byte)
##    rst_n has moved to JA pin 10 - JC is now fully DQ high byte.
## ------------------------------------------------------------
## -- sel_out[5:0] REMOVED --
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[8]  }];  ## JC pin 1
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[9]  }];  ## JC pin 2
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[10] }];  ## JC pin 3
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[11] }];  ## JC pin 4
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[12] }];  ## JC pin 7
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[13] }];  ## JC pin 8
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[14] }];  ## JC pin 9
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { sdram_dq[15] }];  ## JC pin 10


## ------------------------------------------------------------
## 6. PMOD JD  -  SDRAM Control Bus + Bank Address
## ------------------------------------------------------------
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { sdram_clk   }];  ## JD pin 1
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { sdram_cke   }];  ## JD pin 2
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { sdram_cs_n  }];  ## JD pin 3
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { sdram_ras_n }];  ## JD pin 4
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { sdram_cas_n }];  ## JD pin 7
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { sdram_we_n  }];  ## JD pin 8
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { sdram_ba[0] }];  ## JD pin 9
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { sdram_ba[1] }];  ## JD pin 10


## ------------------------------------------------------------
## 7. PMOD JE  -  SDRAM Address Bus [7:0]
## ------------------------------------------------------------
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[0] }];  ## JE pin 1
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[1] }];  ## JE pin 2
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[2] }];  ## JE pin 3
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[3] }];  ## JE pin 4
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[4] }];  ## JE pin 7
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[5] }];  ## JE pin 8
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[6] }];  ## JE pin 9
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[7] }];  ## JE pin 10


## ------------------------------------------------------------
## 8. PMOD JA  -  SDRAM Address [12:8]  +  DQM[1:0]  +  rst_n
##    JA is the XADC header - safe to use as GPIO when XADC
##    is not required (which is the case here).
##    rst_n on pin 10: pull HIGH via 10k? to 3.3V; button to GND = reset.
## ------------------------------------------------------------
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[8]  }];  ## JA pin 1
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[9]  }];  ## JA pin 2
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[10] }];  ## JA pin 3
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[11] }];  ## JA pin 4
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { sdram_addr[12] }];  ## JA pin 7
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { sdram_dqm[0]   }];  ## JA pin 8
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { sdram_dqm[1]   }];  ## JA pin 9



## ============================================================
## WIRING GUIDE FOR SDRAM DATA BUS (sdram_dq[15:0])
## ============================================================
##
##  sdram_dq LOW BYTE  [7:0]  - connect via JB connector
##  ??????????????????????????????????????????????????????????
##  JB pin 1  (T20) ? sdram_dq[0]
##  JB pin 2  (U20) ? sdram_dq[1]
##  JB pin 3  (V20) ? sdram_dq[2]
##  JB pin 4  (W20) ? sdram_dq[3]
##  JB pin 7  (Y18) ? sdram_dq[4]
##  JB pin 8  (Y19) ? sdram_dq[5]
##  JB pin 9  (W18) ? sdram_dq[6]
##  JB pin 10 (W19) ? sdram_dq[7]
##
##  sdram_dq HIGH BYTE [15:8] - split across JC and JA
##  ??????????????????????????????????????????????????????????
##  JC pin 1  (V15) ? sdram_dq[8]
##  JC pin 2  (W15) ? sdram_dq[9]
##  JC pin 3  (T11) ? sdram_dq[10]
##  JC pin 4  (T10) ? sdram_dq[11]
##  JC pin 7  (W14) ? sdram_dq[12]
##  JC pin 8  (Y14) ? sdram_dq[13]
##  JC pin 9  (T12) ? sdram_dq[14]
##  JC pin 10 (U12) ? sdram_dq[15]
##
##  
##
## ============================================================
