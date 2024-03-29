//+------------------------------------------------------------------+
//| Calculadora de Odd para Stop Loss e Take Profit                 |
//|                    Copyright 2024, OpenAI                      |
//|                       https://www.openai.com                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, OpenAI"
#property version   "1.00"
#property script_show_inputs

// Valores padrão para Stop Loss e Take Profit
double stopLoss = 0;
double takeProfit = 0;

// Objetos de texto
int labelStopLoss, labelTakeProfit;

//+------------------------------------------------------------------+
//| Função principal do Script                                      |
//+------------------------------------------------------------------+
void OnInit()
{
   // Cria objetos de entrada no gráfico
   CreateInputObjects();

   // Calcula a Odd
   double odd = CalculateOdd(stopLoss, takeProfit);

   // Exibe a Odd, Stop Loss e Take Profit no gráfico
   string text = StringFormat("Odd: %.2f\nStop Loss: %.5f\nTake Profit: %.5f", odd, stopLoss, takeProfit);
   Print(text);
}

//+------------------------------------------------------------------+
//| Função para criar objetos de entrada no gráfico                 |
//+------------------------------------------------------------------+
void CreateInputObjects()
{
   // Cria objeto de entrada para Stop Loss
   labelStopLoss = ObjectCreate(0, "labelStopLoss", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "labelStopLoss", OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, "labelStopLoss", OBJPROP_YDISTANCE, 10);
   ObjectSetString(0, "labelStopLoss", OBJPROP_TEXT, "Stop Loss: " + DoubleToString(stopLoss, 5));

   // Cria objeto de entrada para Take Profit
   labelTakeProfit = ObjectCreate(0, "labelTakeProfit", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "labelTakeProfit", OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, "labelTakeProfit", OBJPROP_YDISTANCE, 30);
   ObjectSetString(0, "labelTakeProfit", OBJPROP_TEXT, "Take Profit: " + DoubleToString(takeProfit, 5));
}

// Função para calcular a Odd
double CalculateOdd(double stopLoss, double takeProfit)
{
   // Certifique-se de que o stopLoss e takeProfit sejam diferentes de zero
   if (stopLoss == 0 || takeProfit == 0)
      return 0;

   // Calcula a Odd
   return MathAbs(takeProfit / stopLoss);
}
void OnDeinit(const int reason)
{
    
}