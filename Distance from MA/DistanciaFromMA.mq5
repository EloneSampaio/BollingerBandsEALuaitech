//+------------------------------------------------------------------+
//|                                             Distance from MA.mq5 |
//|                                Copyright 2019, Leonardo Sposina. |
//|           https://www.mql5.com/en/users/leonardo_splinter/seller |
//+------------------------------------------------------------------+

#include "MovingAverage.mqh"
#include "AverageLevel.mqh"

enum ENUM_COUNT_DAYS {
  today       = 0,  // today
  one_day     = 1,  // today + yesterday
  two_days    = 2,  // today + past 2 days
  three_days  = 3,  // today + past 3 days
  four_days   = 4,  // today + past 4 days
  five_days   = 5,  // today + past 5 days
  six_days    = 6,  // today + past 6 days
};


input int MA_Period = 14;                   // Moving average period
input ENUM_MA_METHOD MA_Method = MODE_SMA;  // Moving average method

input ENUM_COUNT_DAYS AD_Period = 1;        // Average distance calculation period

MovingAverage* movingAverage;
MqlDateTime candleDatetime, currentDatetime;

// Buffer to store calculated values
double buffer[];

int OnInit() {
  //ArraySetAsSeries(buffer, true);

  movingAverage = new MovingAverage(2, MA_Period, MA_Method);

  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  delete movingAverage;
}

int OnCalculate(
  const int rates_total,
  const int prev_calculated,
  const datetime &time[],
  const double &open[],
  const double &high[],
  const double &low[],
  const double &close[],
  const long &tick_volume[],
  const long &volume[],
  const int &spread[]
) {
  ArraySetAsSeries(buffer, true);
  ArrayResize(buffer, rates_total);  // Dimensionar o array uma vez

  if (movingAverage.update(rates_total) && !IsStopped()) {
    AverageLevel averageDistanceAbove(0, "Average distance above");
    AverageLevel averageDistanceBelow(1, "Average distance below");

    TimeCurrent(currentDatetime);

    for (int i = 0; i < rates_total; i++) {
      double movingAverageValue = movingAverage.getvalue(i);
      double highDiff = MathAbs(movingAverageValue - high[i]);
      double lowDiff = MathAbs(movingAverageValue - low[i]);

      TimeToStruct(time[i], candleDatetime);
      
      if (highDiff >= lowDiff && high[i] > movingAverageValue) {
        if (isWithinPeriod(candleDatetime, currentDatetime))
          averageDistanceAbove.push(highDiff);
      } else if (highDiff <= lowDiff && low[i] < movingAverageValue) {
        if (isWithinPeriod(candleDatetime, currentDatetime))
          averageDistanceBelow.push(-lowDiff);
      }

      // Store calculated values in the buffer
      if (i < ArraySize(buffer))
         buffer[i] = highDiff - lowDiff;
      else
         Print("Tentativa de acessar índice fora dos limites do array. Índice: ", i);
    }

    // Exemplo de impressão dos valores do buffer no log
    for (int i = 0; i < rates_total; i++) {
      Print("Valor do buffer no índice ", i, ": ", buffer[i]);
    }

    averageDistanceAbove.calculate();
    averageDistanceBelow.calculate();
  }

  return(rates_total);
}

string enumMAMethodToString(ENUM_MA_METHOD movingAverageMethod) {
  string methodNameString = EnumToString(movingAverageMethod);
  return StringSubstr(methodNameString, 5);
}

bool isWithinPeriod(MqlDateTime &candle, MqlDateTime &current) {
  return ((candle.day_of_year >= current.day_of_year - AD_Period) && (candle.year == current.year));
}
