class Network(object):
    def __init__(self, sizes): #paramentro sizes contem o numero de neuronios das respectivas camadas. É um objeto do tipo lista
        self.num_layers = len(sizes)
        self.sizes = sizes
        self.biases = [np.random.randn(y,1) for y in sizes[1:]]
        self.weights = [np.random.randn(y,x) for x,y in zip(sizes[:-1], sizes[1:])]
#se quisermos um objeto Network com 2 neuronios na primeira camada, 3 na segunda e 1 na terceira (final).
#faremos: rede1 = Network([2,3,1])
#Bias e pesos sao inicializados aleatoreamente com o np.random.randn para gerar distribuições daussianas com 0 de media e desvio padrao 1
