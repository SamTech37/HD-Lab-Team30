## For Car FPGA
## Change the I/O accordingly

## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## DO USE different constraints files for each FPGA questions

## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]	

## Switches

set_property PACKAGE_PIN V17 [get_ports {sonic_en}]
set_property IOSTANDARD LVCMOS33 [get_ports {sonic_en}]
set_property PACKAGE_PIN V16 [get_ports {tracker_en}]
set_property IOSTANDARD LVCMOS33 [get_ports {tracker_en}]
# set_property PACKAGE_PIN W16 [get_ports {tone[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[2]}]
# set_property PACKAGE_PIN W17 [get_ports {tone[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[3]}]
# set_property PACKAGE_PIN W15 [get_ports {tone[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[4]}]
# set_property PACKAGE_PIN V15 [get_ports {tone[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[5]}]
# set_property PACKAGE_PIN W14 [get_ports {tone[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[6]}]
# set_property PACKAGE_PIN W13 [get_ports {tone[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[7]}]
# set_property PACKAGE_PIN V2 [get_ports {tone[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[8]}]
# set_property PACKAGE_PIN T3 [get_ports {tone[9]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[9]}]
# set_property PACKAGE_PIN T2 [get_ports {tone[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[10]}]
# set_property PACKAGE_PIN R3 [get_ports {tone[11]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[11]}]
# set_property PACKAGE_PIN W2 [get_ports {tone[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[12]}]
# set_property PACKAGE_PIN U1 [get_ports {tone[13]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[13]}]
# set_property PACKAGE_PIN T1 [get_ports {tone[14]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[14]}]
# set_property PACKAGE_PIN R2 [get_ports {tone[15]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {tone[15]}]


## LEDs
set_property PACKAGE_PIN U16 [get_ports {version[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[0]}]
set_property PACKAGE_PIN E19 [get_ports {version[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[1]}]
set_property PACKAGE_PIN U19 [get_ports {version[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[2]}]
set_property PACKAGE_PIN V19 [get_ports {version[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[3]}]
set_property PACKAGE_PIN W18 [get_ports {version[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[4]}]
set_property PACKAGE_PIN U15 [get_ports {version[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[5]}]
set_property PACKAGE_PIN U14 [get_ports {version[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {version[6]}]
set_property PACKAGE_PIN L1 [get_ports {left_LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {left_LED[0]}]
set_property PACKAGE_PIN P1 [get_ports {left_LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {left_LED[1]}]
set_property PACKAGE_PIN N3 [get_ports {right_LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {right_LED[0]}]
set_property PACKAGE_PIN P3 [get_ports {right_LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {right_LED[1]}]
#set_property PACKAGE_PIN V14 [get_ports {led[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
#set_property PACKAGE_PIN V13 [get_ports {led[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
#set_property PACKAGE_PIN V3 [get_ports {led[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
#set_property PACKAGE_PIN W3 [get_ports {led[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
#set_property PACKAGE_PIN U3 [get_ports {led[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
#set_property PACKAGE_PIN P3 [get_ports {led[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
#set_property PACKAGE_PIN N3 [get_ports {led[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
#set_property PACKAGE_PIN P1 [get_ports {led[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
# #set_property PACKAGE_PIN L1 [get_ports {led[15]}]
# #set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]


# #7 segment display
set_property PACKAGE_PIN W7 [get_ports {display[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[0]}]
set_property PACKAGE_PIN W6 [get_ports {display[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[1]}]
set_property PACKAGE_PIN U8 [get_ports {display[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[2]}]
set_property PACKAGE_PIN V8 [get_ports {display[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[3]}]
set_property PACKAGE_PIN U5 [get_ports {display[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[4]}]
set_property PACKAGE_PIN V5 [get_ports {display[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[5]}]
set_property PACKAGE_PIN U7 [get_ports {display[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {display[6]}]

# #set_property PACKAGE_PIN V7 [get_ports dp]							
# #set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN U2 [get_ports {digit[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[0]}]
set_property PACKAGE_PIN U4 [get_ports {digit[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[1]}]
set_property PACKAGE_PIN V4 [get_ports {digit[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[2]}]
set_property PACKAGE_PIN W4 [get_ports {digit[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {digit[3]}]


##Buttons
#btnC
set_property PACKAGE_PIN U18 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]
#btnU
#set_property PACKAGE_PIN T18 [get_ports btnU]
#set_property IOSTANDARD LVCMOS33 [get_po rts btnU]
#btnL
#set_property PACKAGE_PIN W19 [get_ports btnL]
#set_property IOSTANDARD LVCMOS33 [get_ports btnL]
#btnR
#set_property PACKAGE_PIN T17 [get_ports btnR]
#set_property IOSTANDARD LVCMOS33 [get_ports btnR]
#btnD
#set_property PACKAGE_PIN U17 [get_ports rst]
#set_property IOSTANDARD LVCMOS33 [get_ports rst]



##Pmod Header JA
##Sch name = JA1
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
##Sch name = JA2
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
##Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
##Sch name = JA4
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
##Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]



##Pmod Header JB 
    # input left_signal, //from tracker sensor
    # input right_signal,
    # input mid_signal,
##Sch name = JB1
# set_property PACKAGE_PIN A14 [get_ports {pmod_1}]
#     set_property IOSTANDARD LVCMOS33 [get_ports {pmod_1}]
# ##Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {right_signal}]
    set_property IOSTANDARD LVCMOS33 [get_ports {right_signal}]
##Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {mid_signal}]
set_property IOSTANDARD LVCMOS33 [get_ports {mid_signal}]
##Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {left_signal}]
    set_property IOSTANDARD LVCMOS33 [get_ports {left_signal}]
##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
##Sch name = JB9
set_property PACKAGE_PIN C15 [get_ports {echo}]
set_property IOSTANDARD LVCMOS33 [get_ports {echo}]
##Sch name = JB10
set_property PACKAGE_PIN C16 [get_ports {trig}]
set_property IOSTANDARD LVCMOS33 [get_ports {trig}]



##Pmod Header JC
##Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports {right[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {right[0]}]
##Sch name = JC2
######test
set_property PACKAGE_PIN M18 [get_ports {right[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {right[1]}]
##Sch name = JC3
set_property PACKAGE_PIN N17 [get_ports {right_motor}]
set_property IOSTANDARD LVCMOS33 [get_ports {right_motor}]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
##Sch name = JC7
set_property PACKAGE_PIN L17 [get_ports {left_motor}]
set_property IOSTANDARD LVCMOS33 [get_ports {left_motor}]
##Sch name = JC8
set_property PACKAGE_PIN M19 [get_ports {left[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {left[0]}]
#Sch name = JC9
set_property PACKAGE_PIN P17 [get_ports {left[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {left[1]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]


##Pmod Header JXADC
##Sch name = XA1_P
#set_property PACKAGE_PIN J3 [get_ports {JXADC[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[0]}]
##Sch name = XA2_P
#set_property PACKAGE_PIN L3 [get_ports {JXADC[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[1]}]
##Sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {JXADC[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[2]}]
##Sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {JXADC[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[3]}]
##Sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {JXADC[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[4]}]
##Sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {JXADC[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[5]}]
##Sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {JXADC[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[6]}]
##Sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {JXADC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[7]}]



##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
#set_property PACKAGE_PIN P19 [get_ports hsync]
#set_property IOSTANDARD LVCMOS33 [get_ports hsync]
#set_property PACKAGE_PIN R19 [get_ports vsync]
#set_property IOSTANDARD LVCMOS33 [get_ports vsync]


##USB-RS232 Interface
#set_property PACKAGE_PIN B18 [get_ports RsRx]
#set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
#set_property PACKAGE_PIN A18 [get_ports RsTx]
#set_property IOSTANDARD LVCMOS33 [get_ports RsTx]


##USB HID (PS/2)
# set_property PACKAGE_PIN C17 [get_ports PS2_CLK]						
# 	set_property IOSTANDARD LVCMOS33 [get_ports PS2_CLK]
# 	set_property PULLUP true [get_ports PS2_CLK]
# set_property PACKAGE_PIN B17 [get_ports PS2_DATA]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports PS2_DATA]	
# 	set_property PULLUP true [get_ports PS2_DATA]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property PACKAGE_PIN D18 [get_ports {QspiDB[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[0]}]
#set_property PACKAGE_PIN D19 [get_ports {QspiDB[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[1]}]
#set_property PACKAGE_PIN G18 [get_ports {QspiDB[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[2]}]
#set_property PACKAGE_PIN F18 [get_ports {QspiDB[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[3]}]
#set_property PACKAGE_PIN K19 [get_ports QspiCSn]
#set_property IOSTANDARD LVCMOS33 [get_ports QspiCSn]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
