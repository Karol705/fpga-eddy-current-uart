### ZEGAR SYSTEMOWY 12 MHz (Wbudowany w Cmod A7)
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports {clk}];

### KANA£ XADC VAUX4 (Do pinu nr 15 na z³¹czu Cmod A7)
# G3 to pad na chipie przypisany do pinu nr 15. 
# Tutaj pod³¹czasz sygna³ ze swojego czujnika wiropr¹dowego (pamiêtaj: max 3.3V!)
set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { vauxp4 }]; 

# G2 to pad negatywny. Na p³ytce Cmod A7 jest on sprzêtowo zlutowany do masy (GND),
# ale musimy go podaæ w pliku XDC, by Vivado wiedzia³o, gdzie on jest.
set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { vauxn4 }]; 

#### PIN UART TX (Do Malinki)
## Wyprowadzony na pin nr 1 z³¹cza szpilkowego Cmod A7 (pad M3 w uk³adzie Artix)
#set_property -dict { PACKAGE_PIN M3    IOSTANDARD LVCMOS33 } [get_ports { tx }];

### PIN UART TX (Przez z³¹cze micro-USB do Malinki)
# Wewnêtrzny pin uk³adu Artix pod³¹czony do mostka USB-UART (FTDI)
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { tx }];