//| Variáveis globais

input ENUM_TIMEFRAMES selectedTimeframe = PERIOD_CURRENT;                                               
//+------------------------------------------------------------------+
double lastHigh, currentHigh, previousHigh;
double lastLow, currentLow, previousLow;
int handleFractals;
input int   bar_number=3;
//+------------------------------------------------------------------+
//| Função de inicialização do Expert Advisor                       |
//+------------------------------------------------------------------+
int OnInit()
{
   // Adiciona o indicador Fractals ao gráfico atual
   handleFractals = iFractals(_Symbol, selectedTimeframe);
   
   if(handleFractals == INVALID_HANDLE)
   {
      handleFractals = iFractals(_Symbol, selectedTimeframe);
   }
   if(handleFractals == INVALID_HANDLE)
   {
      Print("Erro ao adicionar o indicador Fractals ao gráfico!");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}


double iFractalsGet(const int buffer,const int index)
  {
   double Fractals[3];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iFractalsBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handleFractals,buffer,index,1,Fractals)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Fractals[0]);
  }
//+------------------------------------------------------------------+

void GetFractalsValues(double &fractal_up[], double &fractal_down[], const int buffer)
{
   ResetLastError();
   
   // Copia os valores do buffer MODE_UPPER para o array fractal_up
   if (CopyBuffer(handleFractals, UPPER_LINE, 0, buffer, fractal_up) < 0)
   {
      PrintFormat("Falha ao copiar dados do indicador Fractals para MODE_UPPER, código de erro %d", GetLastError());
   }

   // Copia os valores do buffer MODE_LOWER para o array fractal_down
   if (CopyBuffer(handleFractals, LOWER_LINE, 0, buffer, fractal_down) < 0)
   {
      PrintFormat("Falha ao copiar dados do indicador Fractals para MODE_LOWER, código de erro %d", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Função do tick do Expert Advisor                                |
//+------------------------------------------------------------------+
void OnTick()
{
   double fractal_up[], fractal_down[];
   
   //ArraySetAsSeries (fractal_up, true);
   //ArraySetAsSeries (fractal_down, true);
   
   GetFractalsValues(fractal_up,fractal_down,bar_number);
  
   //double upper=iFractalsGet(UPPER_LINE,bar_number);
//--- find fractal in LOWER
  // double lower=iFractalsGet(LOWER_LINE,bar_number);
   
     // Lógica para identificar 3 High High consecutivos
 
   if (IsThreeHighHigh(fractal_up,fractal_down))
    {
      Print("Três High High consecutivos identificados!");
      DrawTrendLine(currentHigh, lastHigh, previousHigh);
      // Lógica de negociação aqui
   }

   // Lógica para identificar 3 High Low consecutivos
   if (IsThreeHighLow(fractal_up,fractal_down))
   {
      Print("Três High Low consecutivos identificados!");
      DrawTrendLine(currentHigh, lastHigh, previousHigh);
      DrawTrendLine(currentLow, lastLow, previousLow);
      // Lógica de negociação aqui
   }
     /*
  
   if(upper!=DBL_MAX){
      Print("On bar № "+IntegerToString(bar_number)+" there is the UPPER fractal"+"\n");
      Print("\n Value encontrado" + DoubleToString(upper));
   }
   if(lower!=DBL_MAX){
      Print("On bar № "+IntegerToString(bar_number)+" there is the LOwer fractal"+"\n");
      Print("\n Value encontrado" + DoubleToString(lower));
   }
    */
   
    PrintInformation(fractal_up,fractal_down);
}

//+------------------------------------------------------------------+
//| Função para verificar 3 High High consecutivos                  |
//+------------------------------------------------------------------+
bool IsThreeHighHigh(double &fractal_up[], double &fractal_down[])
{
   lastHigh = fractal_up[0];
   currentHigh = fractal_up[1];
   previousHigh = fractal_up[2];

   return (currentHigh > lastHigh && lastHigh > previousHigh);
}

//+------------------------------------------------------------------+
//| Função para verificar 3 High Low consecutivos                   |
//+------------------------------------------------------------------+
bool IsThreeHighLow(double &fractal_up[], double &fractal_down[])
{
   lastHigh = fractal_up[1];
   lastLow = fractal_down[1];

   currentHigh = fractal_up[0];
   currentLow = fractal_down[0];

   previousHigh = fractal_up[2];
   previousLow = fractal_down[2];

   return (currentHigh > lastHigh && lastHigh > previousHigh &&
           currentLow > lastLow && lastLow > previousLow);
}


//+------------------------------------------------------------------+
//| Função para desenhar linha de tendência                          |
//+------------------------------------------------------------------+
void DrawTrendLine(double point1, double point2, double point3)
{
   // Coordenadas dos pontos
   datetime timeArray[3];
   double priceArray[3];

   // Obtemos as coordenadas dos pontos
   timeArray[0] = iTime(NULL, selectedTimeframe, point1);
   priceArray[0] = iHigh(NULL, selectedTimeframe, point1);
   
   timeArray[1] = iTime(NULL, selectedTimeframe, point2);
   priceArray[1] = iHigh(NULL, selectedTimeframe, point2);
   
   timeArray[2] = iTime(NULL, selectedTimeframe, point3);
   priceArray[2] = iHigh(NULL, selectedTimeframe, point3);

   // Criamos a linha de tendência
   ObjectCreate(0, "TrendLine", OBJ_TREND, 0, timeArray[0], priceArray[0], timeArray[2], priceArray[2]);
}




void PrintInformation(double &fractal_up[], double &fractal_down[])
{
    string comment;
    if(fractal_up[0] == EMPTY_VALUE) 
        Comment("UP: --");
    if(fractal_down[0] == EMPTY_VALUE) 
        Comment("Down: --");
    
    comment = "Fractal UP[0]:" + DoubleToString(fractal_up[2]) + "\n Fractal Down[0]" + DoubleToString(fractal_down[2]);
    Comment(comment);
}