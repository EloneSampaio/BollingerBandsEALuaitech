//+------------------------------------------------------------------+
//|                   TrendIdentificationComplete.mq5              |
//|                 Copyright 2024, OpenAI                         |
//|                   https://www.openai.com                        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, OpenAI"
#property link      "https://www.openai.com"
#property version   "1.00"
#property strict

// Variáveis globais
input int fastMA_Period = 10;   // Período da Média Móvel Rápida
input int slowMA_Period = 20;   // Período da Média Móvel Lenta
input int adx_Period = 14;      // Período do ADX
input int adx_Level = 25;       // Nível do ADX para identificar tendências fortes
input double lotSize = 0.1;     // Tamanho do lote para abrir uma ordem

// Identificadores de ordem
ulong ticketBuy = 0;
ulong ticketSell = 0;

// Buffers para médias móveis
double fastMABuffer[];
double slowMABuffer[];

//+------------------------------------------------------------------+
//| Função de inicialização do Expert Advisor                        |
//+------------------------------------------------------------------+
void OnInit()
{
    // Aloca buffers para médias móveis
    ArraySetAsSeries(fastMABuffer, true);
    ArraySetAsSeries(slowMABuffer, true);
}

//+------------------------------------------------------------------+
//| Função principal do Expert Advisor                                |
//+------------------------------------------------------------------+
void OnTick()
{
    // Calcula os valores das médias móveis
    int copied = CopyBuffer(0, 0, 0, fastMA_Period, fastMABuffer);
    if (copied != fastMA_Period)
    {
        Print("Erro ao copiar o buffer da média móvel rápida! Código do erro: ", GetLastError());
        return;
    }

    copied = CopyBuffer(1, 0, 0, slowMA_Period, slowMABuffer);
    if (copied != slowMA_Period)
    {
        Print("Erro ao copiar o buffer da média móvel lenta! Código do erro: ", GetLastError());
        return;
    }

    // Calcula o valor do ADX
    double adx = iADX(Symbol(), 0, adx_Period, PRICE_CLOSE, 0);

    // Verifica se o mercado está em uma tendência de alta (UpTrend)
    if (fastMABuffer[0] > slowMABuffer[0] && adx > adx_Level)
    {
        // Verifica se não há ordem de compra aberta
        if (ticketBuy == 0)
        {
            // Abre uma ordem de compra
            ticketBuy = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, 0, 0, "Buy Order", 0, 0, Green);
            if (ticketBuy > 0)
            {
                Print("Ordem de compra aberta! Ticket: ", ticketBuy);
            }
            else
            {
                Print("Erro ao abrir a ordem de compra! Código do erro: ", GetLastError());
            }
        }
    }
    else
    {
        // Verifica se há uma ordem de compra aberta e a fecha
        if (ticketBuy > 0)
        {
            OrderClose(ticketBuy, OrderLots(), Bid, 3, Red);
            ticketBuy = 0;
            Print("Ordem de compra fechada! Ticket: ", ticketBuy);
        }
    }

    // Verifica se o mercado está em uma tendência de baixa (DownTrend)
    if (fastMABuffer[0] < slowMABuffer[0] && adx > adx_Level)
    {
        // Verifica se não há ordem de venda aberta
        if (ticketSell == 0)
        {
            // Abre uma ordem de venda
            ticketSell = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, 0, 0, "Sell Order", 0, 0, Red);
            if (ticketSell > 0)
            {
                Print("Ordem de venda aberta! Ticket: ", ticketSell);
            }
            else
            {
                Print("Erro ao abrir a ordem de venda! Código do erro: ", GetLastError());
            }
        }
    }
    else
    {
        // Verifica se há uma ordem de venda aberta e a fecha
        if (ticketSell > 0)
        {
            OrderClose(ticketSell, OrderLots(), Ask, 3, Green);
            ticketSell = 0;
            Print("Ordem de venda fechada! Ticket: ", ticketSell);
        }
    }
}
