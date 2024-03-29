//+------------------------------------------------------------------+
//|                                                    MediaTest.mq5 |
//|                                        Copyright 2023, Luaitech. |
//|                                         https://www.luaitech.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Luaitech."
#property link      "https://www.luaitech.com"
#property version   "1.00"
#define OP_BUY  0           //Buy 
#define OP_SELL 1          //Sell 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//Estratégia:
//https://www.mql5.com/en/docs/constants/structures/mqltraderequest
//https://www.mql5.com/en/docs/trading/ordersend
//Compra quando a média móvel curta (ex: 9 períodos) cruza acima da média móvel longa (ex: 21 períodos) e o RSI está abaixo de 30.
//Venda quando a média móvel curta cruza abaixo da média móvel longa e o RSI está acima de 70.

input int media_menor = 10; //média móvel de menor período
input int media_maior = 20; // média móvel de médio período
input int periodRSI = 14; //período do RSI
input int nivelRSIHigh=70;//Nível de sobrecompra/sobrevenda RSI 
input int nivelRSILower=30;//Nível de sobrecompra/sobrevenda RSI 
input double Quantidade = 0.01;
input double StopLoss = 1.3;
input double TakeProfit = 3;

int OnInit()
  {
//---
   //"Essa função é chamada quando eu arrasto o Robô no gráfico");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  //Essa função é chamada sempre que houver uma variação no pip
  //iMA(symbol, timeframe, period, ma_shift, ma_method, applied_price);

  double media_menorValue = iMA(Symbol(), PERIOD_CURRENT,media_menor,0,MODE_SMA,PRICE_CLOSE);
  double media_maiorValue = iMA(Symbol(), PERIOD_CURRENT,media_maior,0,MODE_SMA,PRICE_CLOSE);
  double rsiValue = iRSI(Symbol(), Period(),periodRSI,PRICE_CLOSE);
  
  //condição de compra
  if(media_menorValue>media_maiorValue && rsiValue<nivelRSILower){
      // Coloque a lógica para abrir uma ordem de compra aqui
     // OrderSend(Symbol(), OP_BUY, Quantidade, Close, StopLoss, TakeProfit);

     SendOrder(OP_BUY, 1.0, 456);

            
  }
  
    //condição de venda
  if(media_maiorValue<media_menorValue && rsiValue>nivelRSIHigh){
      // Coloque a lógica para abrir uma ordem de venda aqui
      
      SendOrder(OP_SELL, 0.01, 123);
            
  }
   
  }
  
  // Função para enviar ordens de compra ou venda usando CMqlTradeRequest
// Função para enviar ordens de compra ou venda
void SendOrder(int orderType, double lotSize, int magicNumber)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   // Parâmetros da solicitação
   request.action = orderType;
   request.symbol = Symbol();
   request.volume = lotSize;
   request.type = (orderType == OP_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price = (orderType == OP_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   request.deviation = 5;
   request.magic = magicNumber;

   // Envia a solicitação
   if (!OrderSend(request, result))
      PrintFormat("OrderSend error %d", GetLastError());
   
   // Informações sobre a operação
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);

}
//+------------------------------------------------------------------+
