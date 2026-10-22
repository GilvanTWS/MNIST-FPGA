// =============================================================================
// tb_mac.v - Testbench autoverificavel da unidade MAC (hardware/comum/mac.v)
//
// Estrategia:
//   - As entradas mudam na borda de DESCIDA e o resultado e conferido na
//     borda de descida seguinte, depois que a borda de subida atualizou acc.
//   - O valor esperado vem de um modelo de referencia independente, que usa
//     aritmetica inteira de 32 bits. Assim, um estouro dos 24 bits do MAC
//     aparece como divergencia.
//
// Grupos de teste:
//   1. Reset
//   2. Casos calculados a mao
//   3. Controle: en = 0 mantem o valor; clr tem prioridade sobre en
//   4. Pior caso de um neuronio da camada 1 (64 produtos extremos)
//   5. Neuronio realista: 64 pixels 0..127 x pesos int8 aleatorios
//   6. Teste aleatorio longo (en e clr aleatorios, no maximo 64 MACs por clr)
//
// Saida esperada no Transcript: "RESULTADO: TODOS OS TESTES PASSARAM"
// cd C:/Dev/MNIST-FPGA-main/MNIST-FPGA-main/testes
// =============================================================================
`timescale 1ns/1ps

module tb_mac;

    // ---------------------------------------------------------------- sinais
    reg                clk, rst, clr, en;
    reg  signed [7:0]  a, b;
    wire signed [23:0] acc;

    // ---------------------------------------------- unidade sob teste (UUT)
    mac #(.W_IN(8), .W_ACC(24)) uut (
        .clk(clk), .rst(rst), .clr(clr), .en(en),
        .a(a), .b(b), .acc(acc)
    );

    // ------------------------------------------------ clock de 50 MHz (20 ns)
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // ------------------------------------------------- modelo de referencia
    integer esperado;     // valor esperado de acc (inteiro de 32 bits)
    integer erros;        // numero de divergencias
    integer checagens;    // numero de comparacoes feitas
    integer n_macs;       // produtos acumulados desde o ultimo clr
    integer i, semente;

    // Aplica um ciclo de clock com as entradas dadas, atualiza o modelo
    // e compara o resultado. Deve ser chamada logo apos uma borda de descida:
    // as entradas mudam agora e a conferencia acontece na proxima descida.
    task ciclo;
        input              en_i;
        input              clr_i;
        input signed [7:0] a_i;
        input signed [7:0] b_i;
        begin
            en = en_i; clr = clr_i; a = a_i; b = b_i;
            @(negedge clk);                 // a borda de subida ja passou
            if (clr_i)
                esperado = 0;
            else if (en_i)
                esperado = esperado + a_i * b_i;
            confere;
        end
    endtask

    // Compara acc com o modelo. Tambem acusa um valor esperado fora da faixa
    // de 24 bits, que seria estouro do acumulador.
    task confere;
        begin
            checagens = checagens + 1;
            if (esperado > 8388607 || esperado < -8388608) begin
                $display("ERRO  t=%0t: esperado %0d nao cabe em 24 bits (estouro)",
                         $time, esperado);
                erros = erros + 1;
            end else if (acc !== esperado[23:0]) begin
                $display("ERRO  t=%0t: acc = %0d, esperado %0d",
                         $time, acc, esperado);
                erros = erros + 1;
            end
        end
    endtask

    // Mostra o resultado de um grupo de testes.
    task relatorio;
        input [8*48-1:0] nome;
        input integer    erros_antes;
        begin
            if (erros == erros_antes)
                $display("OK    %0s (acc = %0d)", nome, acc);
            else
                $display("FALHA %0s (%0d erro(s))", nome, erros - erros_antes);
        end
    endtask

    integer e0;

    // ---------------------------------------------------- sequencia de testes
    initial begin
        erros = 0; checagens = 0; esperado = 0; semente = 2026;
        rst = 1; clr = 0; en = 0; a = 0; b = 0;

        $display("==== Teste da unidade MAC (int8 x int8, acumulador 24 bits) ====");

        // ---- 1. Reset ------------------------------------------------------
        e0 = erros;
        @(negedge clk); @(negedge clk);
        esperado = 0; confere;
        rst = 0;
        relatorio("1. Reset zera o acumulador", e0);

        // ---- 2. Casos calculados a mao -------------------------------------
        // 2*3 + (-4)*5 + 7*(-1) + 10*2 = 6 - 20 - 7 + 20 = -1
		  // Obs: 8'sd2 quer dizer: número de 8 bits, signed, decimal e 2(3, -4, 5 e etc) é o valor
        e0 = erros;
        ciclo(1, 0,  8'sd2,   8'sd3); // faz 2*3
        ciclo(1, 0, -8'sd4,   8'sd5); // faz -4*5
        ciclo(1, 0,  8'sd7,  -8'sd1); // faz 7*-1
        ciclo(1, 0,  8'sd10,  8'sd2); // faz 10*2
        relatorio("2a. 2*3 + (-4)*5 + 7*(-1) + 10*2 = -1", e0);

        // 127*127 + (-128)*(-128) = 16129 + 16384 = 32513
        e0 = erros;
        ciclo(0, 1, 8'sd0, 8'sd0);
        ciclo(1, 0,  8'sd127,  8'sd127);
        ciclo(1, 0, -8'sd128, -8'sd128);
        relatorio("2b. 127*127 + (-128)*(-128) = 32513", e0);

        // (-128)*127 = -16256 (produto mais negativo)
        e0 = erros;
        ciclo(0, 1, 8'sd0, 8'sd0);
        ciclo(1, 0, -8'sd128, 8'sd127);
        relatorio("2c. (-128)*127 = -16256", e0);

        // ---- 3. Controle ---------------------------------------------------
        e0 = erros;
        ciclo(0, 0, 8'sd50, 8'sd50);       // en = 0: nao pode mudar
        ciclo(0, 0, -8'sd99, 8'sd77);
        relatorio("3a. en = 0 mantem o valor", e0);

        e0 = erros;
        ciclo(1, 1, 8'sd100, 8'sd100);     // clr e en juntos: clr vence
        relatorio("3b. clr tem prioridade sobre en", e0);

        e0 = erros;
        ciclo(1, 0, 8'sd5, 8'sd5);
        rst = 1; en = 1; a = 8'sd9; b = 8'sd9;   // rst e en juntos: rst vence
        @(negedge clk);
        rst = 0; en = 0; esperado = 0; confere;
        relatorio("3c. rst tem prioridade sobre en", e0);

        // ---- 4. Pior caso de um neuronio da camada 1 -----------------------
        // 64 x (-128 x -128) = 1.048.576 (maior valor positivo possivel)
        e0 = erros;
        ciclo(0, 1, 8'sd0, 8'sd0);
        for (i = 0; i < 64; i = i + 1)
            ciclo(1, 0, -8'sd128, -8'sd128);
        relatorio("4a. Pior caso positivo: 64 x 16384 = 1048576", e0);

        // 64 x (-128 x 127) = -1.040.384 (maior valor negativo possivel)
        e0 = erros;
        ciclo(0, 1, 8'sd0, 8'sd0);
        for (i = 0; i < 64; i = i + 1)
            ciclo(1, 0, -8'sd128, 8'sd127);
        relatorio("4b. Pior caso negativo: 64 x -16256 = -1040384", e0);

        // ---- 5. Neuronio realista ------------------------------------------
        // pixels de 0 a 127 (entrada) e pesos int8 aleatorios
        e0 = erros;
        ciclo(0, 1, 8'sd0, 8'sd0);
        for (i = 0; i < 64; i = i + 1)
            ciclo(1, 0, $random(semente) & 8'h7F, $random(semente));
        relatorio("5. Neuronio com 64 pixels (0..127) x pesos", e0);

        // ---- 6. Teste aleatorio longo --------------------------------------
        // en e clr aleatorios; clr forcado depois de 64 produtos, como num
        // neuronio real, para o acumulador nunca passar do pior caso.
        e0 = erros;
        n_macs = 0;
        for (i = 0; i < 10000; i = i + 1) begin
            if (n_macs >= 64 || ($random(semente) % 32) == 0) begin
                ciclo(($random(semente) % 2) != 0, 1, $random(semente), $random(semente));
                n_macs = 0;
            end else if (($random(semente) % 4) != 0) begin
                ciclo(1, 0, $random(semente), $random(semente));
                n_macs = n_macs + 1;
            end else begin
                ciclo(0, 0, $random(semente), $random(semente));
            end
        end
        relatorio("6. Aleatorio: 10000 ciclos", e0);

        // ---- Resultado final -----------------------------------------------
        $display("------------------------------------------------------------");
        $display("Verificacoes: %0d   Erros: %0d", checagens, erros);
        if (erros == 0)
            $display("RESULTADO: TODOS OS TESTES PASSARAM");
        else
            $display("RESULTADO: %0d TESTE(S) FALHARAM", erros);
        $display("------------------------------------------------------------");
        $stop;
    end

endmodule
