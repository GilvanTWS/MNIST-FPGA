import numpy as np


# Executar: python3 modelo/perceptron_demo.py
np.set_printoptions(precision=2)  # mostra os pesos com 2 casas decimais

# ---------------------------------------------------------------------------
# 1. DADOS - Aula 1: imagem e lista de listas, preto = 0 e branco = 1
# ---------------------------------------------------------------------------
# Cada exemplo e um par (x, y): x e a imagem e y e o rotulo correto
# (Aula 1, item 1.5). Ha varios exemplos de cada digito.

exemplos = [
    # digito 1
    ([
        [0, 0, 1, 0, 0],
        [0, 1, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 1, 0],
    ], 1),
    ([
        [0, 0, 0, 1, 0],
        [0, 0, 1, 1, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 1, 1, 0, 0],
    ], 1),
    ([
        [0, 1, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 1, 0],
    ], 1),
    # digito 0
    ([
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
    ], 0),
    ([
        [0, 0, 1, 0, 0],
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 0, 1, 0, 0],
    ], 0),
    ([
        [1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1],
    ], 0),
]


def achatar(imagem):
    # Aula 1, item 1.3: a matriz 5x5 vira um vetor de 25 entradas.
    return np.array(imagem).flatten()


def degrau(z):
    # Aula 3: retorna 1 se z > 0, senao retorna 0.
    if z > 0:
        return 1
    else:
        return 0


# ---------------------------------------------------------------------------
# 2. ESTRUTURA - um unico neuronio com 25 entradas (Aulas 4 e 5)
# ---------------------------------------------------------------------------
#   z = np.dot(w, x) + b   ->  soma ponderada + bias  (Aula 5: z = Wx + b)
#   saida = degrau(z)      ->  decisao                (Aula 3)
#
# e o mesmo calculo que a classe Network (modelo/modelo.py) faz em cada camada.

n_entradas = 25  # 25 pixels da imagem
taxa = 0.1       # taxa de aprendizado: tamanho do passo de ajuste

w = np.random.randn(n_entradas)  # pesos iniciais aleatorios (Aula 2)
b = 0.0                          # bias inicial

print("Treinamento do perceptron (25 entradas -> 1 saida)")
print("-" * 52)

# ---------------------------------------------------------------------------
# 3. TREINAMENTO - apostila ainda nao abordou esse assunto
# ---------------------------------------------------------------------------
# Para cada exemplo: calcula a saida, compara com o rotulo y e, se errou,
# ajusta pesos e bias um pouco na direcao certa (ciclo da Aula 1, item 1.6).
#
#   erro = y - saida
#   w[i] = w[i] + taxa * erro * x[i]   (o peso de cada um dos 25 pixels)
#   b    = b    + taxa * erro

for epoca in range(1, 31):
    erros = 0

    for imagem, y in exemplos: # imagem é a matriz e y é o rotulo, équivalente a escrever imagem = item [0] ; y = item[1] (ai, no for, onde tem "imagem, y in exemplos", ficaria "item in exemplos")
        x = achatar(imagem)

        z = np.dot(w, x) + b # calcula o produto entre pesos*entradas e soma com o bias
# z = w0*x0 + w1*p1 + ... + wn*xn (pesos vezes entrada)
        
        saida = degrau(z)
        erro = y - saida # aqui verifica se a saida (resposta) esta correta
#Y (certo)  |  saida (Resposta)  | erro = y-saida  | significado
#   1           1                       1-1=0           acerto
#   0           0                       0-0=0      |    acerto
#   1           0                       1-0= 1     |    era 1, disse 0 -> errou
#   0           1                       0-1 = -1   |    era 0, disse 1 -> errou
        if erro != 0:
            erros += 1
            for i in range(n_entradas):
                w[i] += taxa * erro * x[i]  # ajusta o peso de cada pixel
            b += taxa * erro                # ajusta o bias

    print("epoca", epoca, "| erros:", erros)

    if (erros == 0):
        print("Treinamento encerrado na epoca", epoca, ": zero erros.")
        break

print()
print("bias aprendido:", round(b, 2))
print("pesos aprendidos (matriz 5x5, uma linha da matriz por linha da imagem):")

pesos_5x5 = w.reshape(5, 5)
for linha in pesos_5x5:
    print("  ", linha)

imagem_nova = [
    [0, 0, 0, 1, 0],
    [0, 0, 0, 1, 0],
    [0, 0, 1, 1, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 1, 0, 0],
]

x_novo = achatar(imagem_nova)
z_novo = np.dot(w, x_novo) + b
predicao = degrau(z_novo)

print()
print("imagem nova, nao usada no treinamento:")
for linha in imagem_nova:
    print("  ", linha)

print()
print("z = np.dot(w, x) + b =", round(z_novo, 2))
print("predicao = degrau(z) =", predicao)
print("a imagem nova e o digito", predicao)