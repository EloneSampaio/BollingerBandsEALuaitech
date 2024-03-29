//+------------------------------------------------------------------+
//|                     Parâmetros de Entrada                      |
//+------------------------------------------------------------------+

#property script_show_inputs

input double LotSize = 0.01;       // Tamanho do lote para cada negociação
//input int StopLoss = 50;          // Stop Loss em pips
input int TakeProfit = 100;       // Take Profit em pips
input int Repeticoes = 5;         // Número de vezes para duplicar a posição
input double taxaCrescimento = 0.05; // Aumento percentual a cada entrada do take profit

//+------------------------------------------------------------------+
//|                  Criação da Instância de Trade                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Função para Duplicar ou Triplicar uma Posição Existente         |
//+------------------------------------------------------------------+
void DuplicatePosition()
{
    // Verifique se há posições abertas
    int totalPositions = PositionsTotal();

    if (totalPositions > 0)
    {
        ulong lastTicket = PositionGetTicket(totalPositions - 1);
        Print("Last open ticket: ", lastTicket);
    }
    else
    {
        Print("No open positions found.");
    }

    if (PositionsTotal() > 0)
    {
        // Obtenha informações da posição mais recente
        ulong ticket = PositionGetTicket(totalPositions - 1);
        double volume = PositionGetDouble(POSITION_VOLUME);
        double price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
        double stopLoss = NormalizeDouble(PositionGetDouble(POSITION_SL), Digits());  // Obtenha o nível de stop loss da posição existente
        double takeProfit = NormalizeDouble(PositionGetDouble(POSITION_TP), Digits());

         printf("stopLoss "+stopLoss);
        // Abra várias posições no mesmo nível de preço e com o mesmo stop loss
        for (int i = 0; i < Repeticoes; i++)
        {
            // Ajuste o Take Profit em 10% a cada repetição
            takeProfit = takeProfit + (takeProfit * taxaCrescimento);

            // Abra uma nova posição com o mesmo volume, stop loss e take profit
            bool result = trade.Buy(volume, _Symbol, price, stopLoss, takeProfit, "Duplicating Position");

            // Verifique o resultado da abertura da posição
            if (result)
            {
                Print("Nova posição aberta com sucesso. Repetição: ", i + 1);
            }
            else
            {
                Print("Erro ao duplicar a posição. Código do erro: ", GetLastError());
                Print("Informações adicionais: ", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
            }
        }
    }
    else
    {
        Print("Não há posições abertas para duplicar.");
    }
}

//+------------------------------------------------------------------+
//| Função Principal de Início do Script                            |
//+------------------------------------------------------------------+
void OnStart()
{
    // Execute a função para duplicar a posição várias vezes
    DuplicatePosition();
}