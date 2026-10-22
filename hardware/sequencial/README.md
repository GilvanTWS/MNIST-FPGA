# Arquitetura sequencial 

Uma única unidade MAC é reaproveitada para calcular todos os neurônios, um produto por ciclo, sob o controle de uma FSM. Essa versão é a linha de base da comparação com a arquitetura parcialmente paralela.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `../comum/mac.v` | MAC int8 × int8 com acumulador de 24 bits (compartilhado com a versão paralela) |
| `top_mac_sintese.v` | Topo temporário que registra entradas e saída do MAC para medir recursos e Fmax |
| `quartus/rede_seq.qpf` | Projeto Quartus II 13.0 SP1 (Cyclone II EP2C20F484C7) |
| `quartus/rede_seq.sdc` | Clock de 50 MHz (20 ns) |
| `../../testes/tb_mac.v` | Testbench autoverificável do MAC |
| `../../testes/sim_mac.do` | Script de simulação para o ModelSim |

## Compilar no Quartus

1. File → Open Project → `hardware/sequencial/quartus/rede_seq.qpf`.
2. Processing → Start Compilation (Ctrl+L).
3. Métricas:
   - Fitter → Resource Usage Summary: LEs, registradores e "Embedded Multiplier 9-bit elements".
   - TimeQuest → Slow Model → Fmax Summary.
   - Tools → Netlist Viewers → RTL Viewer: diagrama do circuito.

## Simular no ModelSim

**Opção A, ModelSim direto (mais simples):**
```tcl
cd "C:/caminho/do/repositorio/testes"
do sim_mac.do
```

**Opção B, pelo Quartus:** Tools → Run Simulation Tool → RTL Simulation. O NativeLink já está configurado no `.qsf` com o testbench `tb_mac`.

Resultado esperado no Transcript:
```
Verificacoes: 10210   Erros: 0
RESULTADO: TODOS OS TESTES PASSARAM
```

## Testes do MAC

| # | O que verifica |
|---|---|
| 1 | Reset zera o acumulador |
| 2 | Casos calculados à mão, incluindo os extremos de int8 |
| 3 | `en = 0` mantém o valor; `clr` e `rst` têm prioridade sobre `en` |
| 4 | Pior caso de um neurônio da camada 1: 64 × (−128 × −128) = 1.048.576 e 64 × (−128 × 127) = −1.040.384 |
| 5 | Neurônio realista: 64 pixels (0 a 127) × pesos int8 |
| 6 | 10.000 ciclos aleatórios contra um modelo de referência inteiro de 32 bits |

O testbench foi validado com mutações: ele acusa erro quando o produto é calculado sem sinal, quando `en` é ignorado, quando `clr` perde a prioridade e quando o acumulador tem só 20 bits. Esse último caso só é detectado pelo teste 4.

## Próximos módulos

`rom_pesos.v`, `rom_bias.v`, `rom_imagens.v`, `ram_oculta.v`, `ativacao.v`, `argmax.v`, `controle_seq.v` e `top_seq.v`.
