#property copyright "Copyright 2023, Luaitech."
#property link      "https://www.luaitech.com"
#property version   "1.00"

//https://github.com/je-suis-tm/web-scraping
//https://smarttbot.com/trader/como-usar-bandas-de-bollinger/

// Parâmetros
input int periodos = 20; // número de candle que utilizzara
input int ultimosToposFundos = 5; // últimos 5 candles de alta e baixa

// Objetos gráficos
int supportLine,resistanceLine,highLine,lowLine;

int OnInit()
  {
     // Encontrar níveis de suporte e resistência
   double suportLevel = FindSupportLevel(periodos);
   double resistanceLine = FindResistenceLevel(periodos);
   
   // Desenhar linhas de suporte e resistência
   DrawSupportResistenceLine(suportLevel,resistanceLine);
   
   // Encontrar e desenhar os últimos topos e fundos
   DrawHighLowLines(ultimosToposFundos);
   


   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   
  }
void OnTick()
  {
  
      for(int i = ObjectsTotal(0,0,OBJ_TREND)-1; i>=0; i-- ){
         string name = ObjectName(0,i,0,OBJ_TREND);
         Comment("Nome do icone",name);
    }
      
  }
  
  //+------------------------------------------------------------------+
//| Função para encontrar o nível de suporte                         |
//+------------------------------------------------------------------+
  double FindSupportLevel(int periodos){
      double lowestLower = iLowest(_Symbol,_Period,MODE_LOW,periodos,0);
      return (lowestLower);
  }
  

  double FindResistenceLevel(int periodos){
   double highestHigh = iHighest(_Symbol,_Period,MODE_HIGH,periodos,0);
   return (highestHigh);
  }
  
  //+------------------------------------------------------------------+
//| Função para desenhar linhas de suporte e resistência            |
//+------------------------------------------------------------------+
void DrawSupportResistenceLine(double supportLevel, double resistanceLevel){
         // Desenhar linha de suporte
         supportLine = ObjectCreate(0,"Linha de suporte",OBJ_TREND,0,0,0,0);
         ObjectSetInteger(0, "TREND_LINE_TIME1", 0, supportLine);
         ObjectSetInteger(0, "TREND_LINE_TIME2", 1, supportLine);
         ObjectSetInteger(0, "TREND_LINE_RAY_RIGHT", false, supportLine);
         ObjectSetInteger(0, "TREND_LINE_COLOR", clrGreen, supportLine);
         ObjectSetDouble(0, "TREND_LINE_PRICE1", supportLevel, supportLine);
         ObjectSetDouble(0, "TREND_LINE_PRICE2", supportLevel, supportLine);
      
               
        // Desenhar linha de resistência
         resistanceLine = ObjectCreate(0,"Linha de resistencia", OBJ_TREND, 0, 0, 0,0);
         ObjectSetInteger(0, "TREND_LINE_TIME1", 0, resistanceLine);
         ObjectSetInteger(0, "TREND_LINE_TIME2", 1, resistanceLine);
         ObjectSetInteger(0, "TREND_LINE_RAY_RIGHT", false, resistanceLine);
         ObjectSetInteger(0, "TREND_LINE_COLOR", clrRed, resistanceLine);
         ObjectSetDouble(0, "TREND_LINE_PRICE1", resistanceLevel, resistanceLine);
         ObjectSetDouble(0, "TREND_LINE_PRICE2", resistanceLevel, resistanceLine);


}

//+------------------------------------------------------------------+
//| Função para desenhar as últimas barras mais altas e mais baixas |
//+------------------------------------------------------------------+
void DrawHighLowLines(int ultimosToposFundos)
{
   double highPrices[];
   double lowPrices[];

   // Encontrar as últimas barras mais altas e mais baixas
   ArraySetAsSeries(highPrices, true);
   ArraySetAsSeries(lowPrices, true);

   for (int i = 0; i < ultimosToposFundos; i++)
   {
      highPrices[i] = iHigh(_Symbol, _Period, i);
      lowPrices[i] = iLow(_Symbol, _Period, i);
   }

   // Desenhar linhas para os últimos topos
   for (int i = 0; i < ultimosToposFundos; i++)
   {
      highLine = ObjectCreate(0, OBJ_TREND, 0, 0, 0);
      ObjectSetInteger(0, "TREND_LINE_TIME1", 0, 2 + i);
      ObjectSetInteger(0, "TREND_LINE_TIME2", 1, 2 + i);
      ObjectSetInteger(0, "TREND_LINE_RAY_RIGHT", false, 2 + i);
      ObjectSetInteger(0, "TREND_LINE_COLOR", clrBlue, 2 + i);
      ObjectSetDouble(0, "TREND_LINE_PRICE1", highPrices[i], 2 + i);
      ObjectSetDouble(0, "TREND_LINE_PRICE2", highPrices[i], 2 + i);
   }

   // Desenhar linhas para os últimos fundos
   for (int i = 0; i < ultimosToposFundos; i++)
   {
      lowLine = ObjectCreate(0, OBJ_TREND, 0, 0, 0);
      ObjectSetInteger(0, "TREND_LINE_TIME1", 0, 2 + ultimosToposFundos + i);
      ObjectSetInteger(0, "TREND_LINE_TIME2", 1, 2 + ultimosToposFundos + i);
      ObjectSetInteger(0, "TREND_LINE_RAY_RIGHT", false, 2 + ultimosToposFundos + i);
      ObjectSetInteger(0, "TREND_LINE_COLOR", clrOrange, 2 + ultimosToposFundos + i);
      ObjectSetDouble(0, "TREND_LINE_PRICE1", lowPrices[i], 2 + ultimosToposFundos + i);
      ObjectSetDouble(0, "TREND_LINE_PRICE2", lowPrices[i], 2 + ultimosToposFundos + i);
   }

}
