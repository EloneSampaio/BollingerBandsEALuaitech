//+------------------------------------------------------------------+
//|                                   Wamek_BuyStopOrders.mq4        |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script-2023"
#property link      "eawamek@gmail.com"
#property version   "1.00"
#property script_show_inputs

#include <Trade\Trade.mqh>

//create instance of the trade
CTrade trade;

//--- input parameters
enum ChooseOption {Target=1,NumOfPips=2};

input string   Option = "SELECT TargetPrice OR NumOfPips BELOW";
input string   NOTEWELL = "When TargetPrice is selected,Pips has no effect & Vice Versa";

input ChooseOption TargetOrPips = 2;
input int      Pips_4rm_AskPrice = 400;
input double   TargetPrice = 1.03350;
input double   Lots = .01;
input int      TakeProfit=400;
input int      StopLoss=200;
input int      NumOfBuyStop = 1;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      int pick = MessageBox("You are about to open "+DoubleToString(NumOfBuyStop,0)+" BuyStop order(s)\n","BuyStop",0x00000001);
      if(pick==1)
         for(int i =0 ; i< NumOfBuyStop; i++)
            place_order();

     }
   else
      MessageBox("Please enable AutoTrading");

  }
//+------------------------------------------------------------------+

double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double WhereToBuy()
  {
   if(TargetOrPips == 1)
      return(TargetPrice);
   else
      return(Ask+Pips_4rm_AskPrice*_Point);
  }

//+------------------------------------------------------------------+
//|      Place order                                                 |
//+------------------------------------------------------------------+
void place_order()
  {

   double stoplosslevel,takeprofitlevel;

   if(StopLoss == 0)
      stoplosslevel=0;
   else
      stoplosslevel=WhereToBuy() - StopLoss*_Point;

   if(TakeProfit == 0)
      takeprofitlevel=0;
   else
      takeprofitlevel =WhereToBuy() + TakeProfit*_Point;

   bool TBS= trade.BuyStop(Lots,WhereToBuy(),_Symbol,stoplosslevel,takeprofitlevel);

   if(TBS ==false)
      Alert("OrderSend failed with error #",GetLastError());


  }
//+------------------------------------------------------------------+
