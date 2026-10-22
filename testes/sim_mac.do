# =============================================================================
# sim_mac.do - Simulacao do MAC no ModelSim-Altera
#
# Uso, no Transcript do ModelSim (aspas obrigatorias por causa do espaco):
#   cd "C:/caminho/do/repositorio/testes"
#   do sim_mac.do
#
# Resultado esperado no Transcript: "RESULTADO: TODOS OS TESTES PASSARAM"
# =============================================================================
if {[file exists work]} { vdel -lib work -all }
vlib work
vlog -vlog01compat ../hardware/comum/mac.v tb_mac.v
vsim work.tb_mac

add wave -divider "Controle"
add wave /tb_mac/clk /tb_mac/rst /tb_mac/clr /tb_mac/en
add wave -divider "Dados (decimal com sinal)"
add wave -radix decimal /tb_mac/a /tb_mac/b /tb_mac/acc
add wave -divider "Modelo de referencia"
add wave -radix decimal /tb_mac/esperado /tb_mac/erros

run -all
wave zoom full
