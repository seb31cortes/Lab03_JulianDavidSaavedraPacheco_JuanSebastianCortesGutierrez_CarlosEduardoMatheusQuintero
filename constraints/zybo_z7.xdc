## Zybo Z7-10 / Z7-20 Rev B. Fuente: docs/Zybo-Z7-Master.xdc (Digilent).
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -name sys_clk -period 8.000 [get_ports clk]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports rgb_r]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports rgb_g]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports rgb_b]
## Pmod JC1 y JC2 (JC existe en Z7-10; JB no).
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports tm_clk]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports tm_dio]
## Pull-up fisico externo a 3.3 V en DIO, o lado LV del adaptador de niveles.
## Entradas asincronas: excepcion SOLO hasta D de la primera etapa.
set first_sw [get_cells -hier -regexp {.*u_sw_sync/meta_reg\[[0-3]\]}]
set first_btn [get_cells -hier -regexp {.*u_db/btn_sync_0_reg}]
set_false_path -from [get_ports {sw[*]}] -to [get_pins -of_objects $first_sw -filter {REF_PIN_NAME == D}]
set_false_path -from [get_ports {btn[*]}] -to [get_pins -of_objects $first_btn -filter {REF_PIN_NAME == D}]
## El diagnostico ACK no tiene consumidor fisico; sintesis elimina su entrada.
## Si se expone en una revision futura, anadir su restriccion hasta dio_meta.
## LEDs: observacion humana. Bus TM1637: salida lenta por FSM; no es reloj
## interno ni receptor referido a sys_clk. Sus fases se prueban en simulacion.
set_false_path -to [get_ports {led[*] rgb_r rgb_g rgb_b tm_clk tm_dio}]

## Switches externos de operacion, independientes de sw[3:0].
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {sw_sel[0]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33 PULLDOWN TRUE} [get_ports {sw_sel[1]}]
set first_op [get_cells -hier -regexp {.*u_op_sync/meta_reg\[[0-1]\]}]
set_false_path -from [get_ports {sw_sel[*]}] -to [get_pins -of_objects $first_op -filter {REF_PIN_NAME == D}]
