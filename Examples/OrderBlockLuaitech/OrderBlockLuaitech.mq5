//+------------------------------------------------------------------+
//|                        EA OrderBlockFGV                         |
//|                  Copyright 2024, OpenAI                         |
//+------------------------------------------------------------------+

#include "MakeOrder.mqh"

#property strict

// Parâmetros de entrada
input int orderBlockSize = 10; // Tamanho do bloco de ordens
input double big = 0.9; // tamanho da barra
MakeOrder makeOrder;


struct OrderBlockData
{
    bool isOrderBlock;
    double orderBlockPrice;
    int blockStartIndex;
};

//+------------------------------------------------------------------+
//| Função de inicialização do EA                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Função de tick do EA                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Obtenha o índice inicial e final do período desejado
   int startBar = iBarShift(_Symbol, _Period, iTime(_Symbol, _Period, 0), true);
   int endBar = 0;

   // Chame a função principal para encontrar Order Blocks e FGV
   FindOrderBlocksAndFGV(startBar, endBar, orderBlockSize);
}

//+------------------------------------------------------------------+
//| Função para encontrar Order Blocks e Fair Value Gaps (FGV)      |
//+------------------------------------------------------------------+
void FindOrderBlocksAndFGV(int startBar, int endBar, int orderBlockSize)
{
   int blockStart = -1;

   for (int i = endBar; i >= startBar; i--)
   {
      //CheckAndDrawOrderBlock(i, orderBlockSize, blockStart);
      OrderBlockData orderBlockData = CheckAndDrawOrderBlock(i, orderBlockSize,blockStart);
       if (orderBlockData.isOrderBlock)
    {
        // Usar os valores retornados para desenhar a linha
        DrawHorizontalLine(orderBlockData.orderBlockPrice, orderBlockData.blockStartIndex);

        // Armazenar o início do bloco de ordem
        blockStart = orderBlockData.blockStartIndex;
        
        
        double orderBlockPrice =orderBlockData.orderBlockPrice; // Obtenha o valor do order block
        double lotSize = 0.01;// Defina o tamanho do lote
         
         makeOrder.ExecuteSellTrade(lotSize, orderBlockPrice);
        
    }
    
    
    else if (blockStart >= 0 && i - blockStart >= orderBlockSize)
    {
        // Remover a linha após um certo número de barras
        ObjectDelete(0, "LinhaPreco_" + DoubleToString(orderBlockData.orderBlockPrice, 2));
        blockStart = -1;
    }
      
      if (blockStart >= 0 )
      {
         Print("Order Block encontrado de ", TimeToString(iTime(_Symbol, _Period, blockStart), TIME_DATE | TIME_MINUTES),
               " até ", TimeToString(iTime(_Symbol, _Period, endBar), TIME_DATE | TIME_MINUTES));

         // Chame a função para verificar Fair Value Gap
         CheckFairValueGap(blockStart);

         // Reiniciar a busca
         blockStart = -1;
      }
   }
}

//+------------------------------------------------------------------+
//| Função para verificar se é um potencial Order Block             |
//+------------------------------------------------------------------+
bool IsPotentialOrderBlock2(int index)
{
   double high = iHigh(_Symbol, _Period, index);
   double low = iLow(_Symbol, _Period, index);
   double open = iOpen(_Symbol, _Period, index);
   double close = iClose(_Symbol, _Period, index);

   double body = MathAbs(close - open);
   double upperWick = high - MathMax(close, open);
   double lowerWick = MathMin(close, open) - low;

   // Condição de desequilíbrio
   return (body > 2 * upperWick && body > 2 * lowerWick);
}

//+------------------------------------------------------------------+
//| Função para verificar se é um potencial Order Block e desenhar   |
//| a linha horizontal                                               |
//+------------------------------------------------------------------+
OrderBlockData CheckAndDrawOrderBlock(int index, int orderBlockSize, int &blockStart)
{

   OrderBlockData data;
   data.isOrderBlock = false;
   data.orderBlockPrice = 0.0;
   data.blockStartIndex = -1;
    
   double high = iHigh(_Symbol, _Period, index);
   double low = iLow(_Symbol, _Period, index);
   double open = iOpen(_Symbol, _Period, index);
   double close = iClose(_Symbol, _Period, index);

   // Verifica se a vela atual é contrária à direção da tendência anterior
   bool isContraryCandle = close < open; // ou qualquer outra condição que você usar para identificar a vela contrária

   // Verifica se as próximas velas têm a mesma cor
   bool isFollowedBySameColorCandles = true;
   for (int i = index - 1; i >= index - orderBlockSize + 1; i--)
   {
      double prevOpen = iOpen(_Symbol, _Period, i);
      double prevClose = iClose(_Symbol, _Period, i);
      if (prevOpen != prevClose)
      {
         isFollowedBySameColorCandles = (prevOpen < prevClose) == (close < open);
         break;
      }
   }

   // Verifica se o corpo da vela é considerado grande (pelo menos 80% do intervalo)
   double bodySize = MathAbs(close - open);
   double range = high - low;
   bool hasLargeBody = (bodySize >= big * range);
   
   
    // Verifica se o corpo da vela está quebrando estruturas anteriores
   bool isBreakingStructures = true;
   for (int i = index - 1; i >= index - orderBlockSize + 1; i--)
   {
      double prevHigh = iHigh(_Symbol, _Period, i);
      double prevLow = iLow(_Symbol, _Period, i);
      bool isBullishCandle = close > open;

      if (isBullishCandle && high > prevHigh)
      {
         isBreakingStructures = false;
         break;
      }
      else if (!isBullishCandle && low < prevLow)
      {
         isBreakingStructures = false;
         break;
      }
   }

   // Condição de desequilíbrio (Order Block)
   if (isContraryCandle && isFollowedBySameColorCandles && hasLargeBody)
   {
      // Obtém o preço na posição do Order Block
      double orderBlockPrice = close; // ou open, dependendo de como você deseja representar a direção

           // Desenha uma linha horizontal no gráfico com o nome "LinhaPreco" na posição do Order Block
     // ObjectCreate(0, "LinhaPreco_" + DoubleToString(orderBlockPrice, 2), OBJ_HLINE, 0, iTime(_Symbol, _Period, index), high);
     // ObjectCreate(0, "LinhaPreco_" + DoubleToString(orderBlockPrice, 2), OBJ_HLINE, 0, iTime(_Symbol, _Period, index), low);      
      
      // Marca o início do order block
      
      data.isOrderBlock = true;
      data.orderBlockPrice = close; // ou open, dependendo de como você deseja representar a direção
      data.blockStartIndex = index;
      //blockStart = index;
      
      
   }
   return data;
   
}

//+------------------------------------------------------------------+
//| Função para verificar Fair Value Gap                            |
//+------------------------------------------------------------------+
void CheckFairValueGap(int blockStart)
{
   // Chame a função para calcular o valor justo estimado
   double fairValue = CalculateFairValue(blockStart);

   // Defina um limite para considerar como Fair Value Gap
   double fairValueGapThreshold = 0.002; // Ajuste conforme necessário
   double priceImbalance = MathAbs(iClose(_Symbol, _Period, blockStart) - fairValue);

   if (priceImbalance > fairValueGapThreshold)
   {
      // FGV encontrado devido a desequilíbrio significativo
      Print("FGV encontrado em ", TimeToString(iTime(_Symbol, _Period, blockStart), TIME_DATE | TIME_MINUTES));

      // Aqui você pode realizar ações adicionais, como enviar ordens, etc.
   }
}

//+------------------------------------------------------------------+
//| Função para calcular Fair Value                                 |
//+------------------------------------------------------------------+
double CalculateFairValue(int index)
{
   // Lógica para calcular o valor justo estimado
   // Substitua isso com sua lógica específica
   return (iHigh(_Symbol, _Period, index) + iLow(_Symbol, _Period, index)) / 2.0;
}


void DrawHorizontalLine(double price, int index)
{
    double high = iHigh(_Symbol, _Period, index);
    double low = iLow(_Symbol, _Period, index);

    // Desenha uma linha horizontal no gráfico com o nome "LinhaPreco" na posição desejada
    ObjectCreate(0, "LinhaPreco_" + DoubleToString(price, 2), OBJ_HLINE, 0, iTime(_Symbol, _Period, index), high);
    ObjectCreate(0, "LinhaPreco_" + DoubleToString(price, 2), OBJ_HLINE, 0, iTime(_Symbol, _Period, index), low);
}