//+------------------------------------------------------------------+
//| Calculadora de Odd para Stop Loss e Take Profit                 |
//|                    Copyright 2024, OpenAI                      |
//|                       https://www.openai.com                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, OpenAI"
#property version   "1.00"
#property script_show_inputs

// Valores padrão para Stop Loss e Take Profit
input double stopLossPips = 1.002; // Stop Loss em pips
input double takeProfitPips = 1.003; // Take Profit em pips
input double entryPrice = 1.001; // Take Profit em pips
// Objetos de texto
int labelStopLoss, labelTakeProfit,labelOdd;

//+------------------------------------------------------------------+
//| Função principal do Expert Advisor                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // Calcula os preços de entrada, stop loss e take profit
   
   double stopLossPrice = entryPrice - stopLossPips ;
   double takeProfitPrice = entryPrice + takeProfitPips ;



   // Calcula a Odd
   double odd = CalculateOdd(entryPrice, stopLossPrice, takeProfitPrice);

   // Cria objetos de entrada no gráfico
   PrintInformation(stopLossPrice, takeProfitPrice,odd);
   // Exibe a Odd, Stop Loss e Take Profit no gráfico
   string text = StringFormat("Odd: %.2f\nStop Loss: %.5f\nTake Profit: %.5f", odd, stopLossPrice, takeProfitPrice);
   Print(text);
}

//+------------------------------------------------------------------+
//| Função para criar objetos de entrada no gráfico                 |
//+------------------------------------------------------------------+
void CreateInputObjects(double stopLossPrice, double takeProfitPrice,double odd)
{
      
      
}
void PrintInformation(double stopLossPrice, double takeProfitPrice,double odd)
{
    string comment;
    comment = "Stop Loss:  " + DoubleToString(stopLossPrice, _Digits) + "\nTake Profit: " + DoubleToString(takeProfitPrice, _Digits);
    comment += "\nOdd:  " + DoubleToString(odd, _Digits) ; 
    Comment(comment);
}

// Função para calcular a Odd
double CalculateOdd(double entryPrice, double stopLossPrice, double takeProfitPrice)
{
   // Certifique-se de que o risco não seja zero para evitar divisão por zero
   double risk = entryPrice - stopLossPrice;
   if (risk == 0)
      risk = 0.00001; // Pequeno valor para evitar divisão por zero

   // Calcula a Odd
   return MathAbs((takeProfitPrice - entryPrice) / risk);
}


