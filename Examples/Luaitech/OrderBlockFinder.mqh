class OrderBlockFinder {

private:
    int orderBlockSize;
    int blockStart;

public:
    OrderBlockFinder(int blockSize) : orderBlockSize(blockSize), blockStart(-1) {}

    void FindBlocks(int startBar, int endBar) {
        double high, low, open, close;

        for (int i = endBar; i >= startBar; i--) {
            high = iHigh(_Symbol, _Period, i);
            low = iLow(_Symbol, _Period, i);
            open = iOpen(_Symbol, _Period, i);
            close = iClose(_Symbol, _Period, i);

            double body = MathAbs(close - open);
            double upperWick = high - MathMax(close, open);
            double lowerWick = MathMin(close, open) - low;

            // Condição de desequilíbrio
            if (body > 2 * upperWick && body > 2 * lowerWick) {
                // Potencial Order Block encontrado
                blockStart = i;
            }

            // Verificar se já encontrou um bloco suficientemente grande
            if (blockStart >= 0 && endBar - blockStart >= orderBlockSize) {
                Print("Order Block encontrado de ", TimeToString(iTime(_Symbol, _Period, blockStart), TIME_DATE | TIME_MINUTES),
                      " até ", TimeToString(iTime(_Symbol, _Period, endBar), TIME_DATE | TIME_MINUTES));

                // Aqui você pode realizar ações adicionais, como desenhar linhas no gráfico, etc.

                // Reiniciar a busca
                blockStart = -1;
            }
        }
    }
};
