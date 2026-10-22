// =============================================================================
// top_mac_sintese.v - Topo TEMPORARIO para sintetizar e medir o MAC sozinho
//
// Por que existe: se o MAC fosse o topo, as entradas a e b viriam direto dos
// pinos  e o caminho do multiplicadr ficaria fora da analise de Fmax
// (o TimeQuest so mede caminhos registrador -> registrador).
// Aqui todas as entradas passam por registradores, entao o caminho medido e:
//   registrador -> multiplicador -> somador -> registrador acc
// que e o mesmo caminho critico que o MAC tera dentro da rede.
//
// Quando top_seq.v existir, o projeto Quartus passa a usar ele como topo e
// este arquivo pode ser removido.
// =============================================================================
`timescale 1ns/1ps

module top_mac_sintese (
    input  wire               clk,
    input  wire               rst,
    input  wire               clr,
    input  wire               en,
    input  wire signed [7:0]  a,
    input  wire signed [7:0]  b,
    output reg  signed [23:0] acc_out
);
    reg               clr_r, en_r;
    reg signed [7:0]  a_r, b_r;
    wire signed [23:0] acc;

    // Registra as entradas vindas dos pinos
    always @(posedge clk) begin
        clr_r <= clr;
        en_r  <= en;
        a_r   <= a;
        b_r   <= b;
    end

    mac #(.W_IN(8), .W_ACC(24)) u_mac (
        .clk(clk), .rst(rst), .clr(clr_r), .en(en_r),
        .a(a_r), .b(b_r), .acc(acc)
    );

    // Registra a saida antes dos pinos
    always @(posedge clk)
        acc_out <= acc;
endmodule
