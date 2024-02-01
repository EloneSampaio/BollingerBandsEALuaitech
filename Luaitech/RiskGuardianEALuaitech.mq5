// Define parâmetros de entrada
input int fastEmaPeriod = 12;
input int slowEmaPeriod = 26;
input int macdSignalPeriod = 9;
input int atrPeriod = 14;
input double riskPerTrade = 2.0; // Risco por trade em percentual
input double stopLossPriceChange = 1.5; // Variação de preço para o Stop Loss em ATR

// Define variáveis globais
double lotSize; // Tamanho da posição
int maHandle, macdHandle, atrHandle;
double accountEquity;

// Define sinais de negociação
bool SinalCompra() {
    return (iMA(NULL, 0, fastEmaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0) > iMA(NULL, 0, slowEmaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0));
}

bool SinalVenda() {
    return (iMA(NULL, 0, fastEmaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0) < iMA(NULL, 0, slowEmaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0));
}

// Inicializa o Expert Advisor
int OnInit() {
    maHandle = iMA(NULL, 0, fastEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
    macdHandle = iMACD(NULL, 0, fastEmaPeriod, slowEmaPeriod, macdSignalPeriod, PRICE_CLOSE);
    atrHandle = iATR(NULL, 0, atrPeriod);
    
    return(INIT_SUCCEEDED);
}

// Lida com decisões de negociação
void OnTick() {
    if (SinalCompra()) {
        lotSize = CalcularTamanhoPosicao();
        OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 0, 0, "Ordem de Compra", 0, 0, clrGreen);
    }

    if (SinalVenda()) {
        lotSize = CalcularTamanhoPosicao();
        OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, 0, 0, "Ordem de Venda", 0, 0, clrRed);
    }

    // Lógica de saída
    VerificarStopLoss();
    VerificarPosicoesOpostas();
}

// Calcula o tamanho da posição com base no risco
double CalcularTamanhoPosicao() {
    accountEquity = AccountEquity();
    double valorRisco = accountEquity * (riskPerTrade / 100.0);
    double atrValor = iATR(NULL, 0, atrPeriod, 0);
    
    return valorRisco / (atrValor * stopLossPriceChange * Point);
}

// Função de lógica de saída
void VerificarStopLoss() {
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == Symbol()) {
            // Verifica posições longas abertas
            if (OrderType() == OP_BUY) {
                double stopLossAtual = OrderOpenPrice() - stopLossPriceChange * Point;
                if (OrderStopLoss() != stopLossAtual) {
                    OrderModify(OrderTicket(), OrderOpenPrice(), stopLossAtual, OrderTakeProfit(), 0, clrBlue);
                }
            }
            // Verifica posições curtas abertas
            else if (OrderType() == OP_SELL) {
                double stopLossAtual = OrderOpenPrice() + stopLossPriceChange * Point;
                if (OrderStopLoss() != stopLossAtual) {
                    OrderModify(OrderTicket(), OrderOpenPrice(), stopLossAtual, OrderTakeProfit(), 0, clrRed);
                }
            }
        }
    }
}

// Função para verificar posições opostas e fechá-las
void VerificarPosicoesOpostas() {
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == Symbol()) {
            // Verifica posições longas abertas
            if (OrderType() == OP_BUY) {
                for (int j = OrdersHistoryTotal() - 1; j >= 0; j--) {
                    if (OrderSelect(j, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
                        OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrRed);
                    }
                }
            }
            // Verifica posições curtas abertas
            else if (OrderType() == OP_SELL) {
                for (int j = OrdersHistoryTotal() - 1; j >= 0; j--) {
                    if (OrderSelect(j, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
                        OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrBlue);
                    }
                }
            }
        }
    }
}
