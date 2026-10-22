# Restricoes de tempo - arquitetura sequencial
# Clock da DE1: 50 MHz (periodo de 20 ns)
create_clock -name clk -period 20.000 [get_ports clk]
derive_clock_uncertainty

# Entradas e saidas vem de/vao para pinos e ja sao registradas no topo.
# So o caminho interno (registrador -> registrador) interessa para o Fmax.
set_false_path -from [get_ports {rst clr en a[*] b[*]}]
set_false_path -to   [get_ports {acc_out[*]}]
