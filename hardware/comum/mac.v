// =============================================================================
// mac.v - Unidade de Multiplicacao e Acumulacao (MAC)
// Projeto: Rede neural quantizada na FPGA DE1 (Cyclone II EP2C20F484C7)
// Modulo COMPARTILHADO entre a arquitetura sequencial e a paralela.
// Qualquer mudanca aqui precisa ser revisada pelas Pessoas 2 e 3.
//
// Operacao (a cada borda de subida do clock):
//   rst = 1 ou clr = 1  ->  acc <= 0              (clr tem prioridade sobre en)
//   en  = 1             ->  acc <= acc + a * b
//   en  = 0             ->  acc mantem o valor
//
// Larguras padrao (int8 x int8, acumulador de 24 bits):
//   produto maximo em modulo: (-128) x (-128) = 16.384  -> 16 bits com sinal
//   pior caso de um neuronio da camada 1: 64 x 16.384 = 1.048.576 -> 22 bits
//   24 bits (faixa de -8.388.608 a 8.388.607) deixam margem para o bias.
//
// Latencia: o resultado de um produto aparece em acc 1 ciclo depois de en = 1.
// No Cyclone II, a multiplicacao 8x8 e mapeada para um multiplicador embutido.
// =============================================================================
`timescale 1ns/1ps

module mac #(
    parameter W_IN  = 8,    // largura das entradas a e b (com sinal)
    parameter W_ACC = 24    // largura do acumulador (com sinal)
) (
    input  wire                     clk,   // clock da placa (50 MHz)
    input  wire                     rst,   // reset sincrono: zera o acumulador
    input  wire                     clr,   // zera o acumulador no inicio de cada neuronio
    input  wire                     en,    // 1 = acumula neste ciclo; 0 = mantem o valor
    input  wire signed [W_IN-1:0]   a,     // pixel ou ativacao (int8)
    input  wire signed [W_IN-1:0]   b,     // peso (int8)
    output reg  signed [W_ACC-1:0]  acc    // soma acumulada
);
    // Produto com o dobro da largura das entradas: nao ha perda de bits.
    wire signed [2*W_IN-1:0] prod;
    assign prod = a * b;

    // Os dois operandos sao signed, entao o produto e estendido com sinal
    // ate W_ACC bits antes da soma.
    always @(posedge clk) begin
        if (rst || clr)
            acc <= {W_ACC{1'b0}};
        else if (en)
            acc <= acc + prod;
    end
endmodule
