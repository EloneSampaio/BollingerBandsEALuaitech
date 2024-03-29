// Parâmetros do indicador
input int maPeriod = 17;

int OnInit() {
   
    return(INIT_SUCCEEDED);
}

void OnTick() {
    // Obter os valores do indicador
    int bufferSize = iCustom(_Symbol, _Period, "Distance from MA\\DistanciaFromMA", maPeriod, 0, 0, 0, 0);
    if (bufferSize > 0) {
        double buffer[];
        ArraySetAsSeries(buffer, true);

        // Obter os valores do indicador usando CopyBuffer
        if (CopyBuffer(0, 0, 0, bufferSize, buffer) > 0) {
            for (int i = 0; i < bufferSize; i++) {
                // Aqui você pode analisar os valores do indicador conforme necessário
                double indicatorValue = buffer[i];
                Print("Valor do indicador no índice ", i, ": ", indicatorValue);

                // Adicione sua lógica de negociação com base nos valores do indicador aqui
            }
        }
    }
}

void OnDeinit(const int reason) {
    // Encerrar o gráfico
    ChartClose(0);
    ResetLastError();
}
