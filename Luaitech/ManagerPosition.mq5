#include "MakeOrder.mqh"

// Variáveis globais
int maHandle;
double riskValue;
// Input parameters
input int MA_Period = 20;
input ENUM_MA_METHOD MA_Method = MODE_SMA;
input double RiskPercent = 1.0;
input double TakeProfitFactor = 0.5;

MakeOrder orderManager;

//+------------------------------------------------------------------+
//| Função chamada na inicialização do Expert Advisor               |
//+------------------------------------------------------------------+
int OnInit()
{
   // Cria o indicador Distance from MA
   maHandle = iCustom(_Symbol, _Period, "Distance from MA\Distance from MA", MA_Period, MA_Method);

   // Verifica se o identificador do indicador é válido
   if (maHandle == INVALID_HANDLE)
   {
      Print("Erro ao criar o indicador Distance from MA. Certifique-se de que o indicador está instalado.");
      return(INIT_FAILED);
   }

   // Calcula o valor de risco com base em RiskPercent
   riskValue = RiskPercent / 100.0;

   // Inicialização bem-sucedida
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Função chamada a cada tick                                      |
//+------------------------------------------------------------------+
void OnTick()
{
   // Obtém o valor Distance from MA
   double distanceValue = iCustom(_Symbol, _Period, "Distance from MA", MA_Period, MA_Method, 0);

   // Lógica de entrada (substitua isso pela sua lógica)
   if (distanceValue > 0.0)
   {
      // Lógica de Compra
      double stopLoss = iLow(_Symbol, _Period, 1); // Define o stop loss abaixo da mínima anterior
      double lotSize = CalculateLotSize(stopLoss);
      double takeProfitFactor = TakeProfitFactor;

      // Coloca a ordem de Compra
      orderManager.ExecuteBuyTrade(lotSize, stopLoss, takeProfitFactor);
   }
   else if (distanceValue < 0.0)
   {
      // Lógica de Venda
      double stopLoss = iHigh(_Symbol, _Period, 1); // Define o stop loss acima da máxima anterior
      double lotSize = CalculateLotSize(stopLoss);
      double takeProfitFactor = TakeProfitFactor;

      // Coloca a ordem de Venda
      orderManager.ExecuteSellTrade(lotSize, stopLoss, takeProfitFactor);
   }

   // Lógica de saída ou redução com base em distanceValue
   if (distanceValue > 0.0)
   {
      // Lógica de saída ou redução para ordens de Compra
      double currentProfit = orderManager.ask - orderManager.ask;
      if (currentProfit >= 0.75 * (orderManager.ask - orderManager.stop_loss))
      {
         // Reduz a posição fechando 50% dos lotes
         double lotsToClose = 0.5 * orderManager.lotSize;
         orderManager.ManageBuyPosition(lotsToClose, 0, 0, 0);
      }
   }
   else if (distanceValue < 0.0)
   {
      // Lógica de saída ou redução para ordens de Venda
      double currentProfit = orderManager.bid - orderManager.bid;
      if (currentProfit >= 0.75 * (orderManager.stop_loss - orderManager.bid))
      {
         // Reduz a posição fechando 50% dos lotes
         double lotsToClose = 0.5 * orderManager.lotSize;
         orderManager.ManageSellPosition(lotsToClose, 0, 0, 0);
      }
   }
}

//+------------------------------------------------------------------+
//| Função para calcular o tamanho dos lotes com base no risco       |
//+------------------------------------------------------------------+
double CalculateLotSize(double stopLoss)
{
   // Obter o saldo da conta
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);

   // Calcular o tamanho do lote com base no risco
   double lotSize = riskValue * accountBalance / stopLoss;

   return lotSize;
}
