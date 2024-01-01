/*
GetBollingerBandsValues

Objetivo: Extrai os valores das Bandas de Bollinger.
Parâmetros de Saída: upperBand, lowerBand, e moving_average (passados por referência).
Ação: Usa a função CopyBuffer para obter os valores da Banda Superior (upperBand), Banda Inferior (lowerBand), e Média Móvel (moving_average) do indicador Bollinger Bands.
ManageOpenPositions

Objetivo: Gerencia as posições abertas, incluindo a modificação ou fechamento parcial com base nas condições de mercado.
Parâmetros de Entrada: upperBand, lowerBand, e moving_average.
Ação: Itera sobre as posições abertas e chama funções específicas para gerenciar posições de compra (ManageBuyPosition) e venda (ManageSellPosition).
ManageBuyPosition e ManageSellPosition

Objetivo: Gerencia posições específicas de compra e venda, incluindo fechamento parcial e modificação de stop loss.
Parâmetros de Entrada: Informações da posição (posLots, lotsToClose, moving_average, posStopLoss, etc.).
Ação: Implementa lógicas específicas para modificar stop loss e fechar parcialmente posições de compra ou venda.
CheckEntrySignals

Objetivo: Verifica os sinais de entrada com base nas Bandas de Bollinger.
Parâmetros de Entrada: upperBand, lowerBand, closeValue1, e closeValue2.
Ação: Decide se deve executar operações de compra ou venda com base nas condições dos sinais de entrada.
ExecuteSellTrade e ExecuteBuyTrade

Objetivo: Executa operações de venda ou compra com base nos sinais de entrada.
Parâmetros de Entrada: Informações das Bandas de Bollinger (upperBand ou lowerBand).
Ação: Calcula stop loss e take profit, e executa a ordem de venda ou compra.
PrintInformation

Objetivo: Imprime informações relevantes no console.
Parâmetros de Entrada: Informações das Bandas de Bollinger, média móvel, e valores de fechamento.
Ação: Cria uma string informativa com os valores relevantes e a imprime no console usando a função Comment.

*/

#include <Trade/Trade.mqh>

CTrade myTrade;
int handleBb;
int handleMaFilter;
int handleEmaFilter;
int handleRsiFilter;
int barsTotal;

input ENUM_TIMEFRAMES selectedTimeframe = PERIOD_CURRENT;
input ENUM_TIMEFRAMES selectedTimeframeMaFilter = PERIOD_CURRENT;
input ENUM_TIMEFRAMES selectedTimeframeEmaFilter = PERIOD_CURRENT; 
input ENUM_APPLIED_PRICE priceSelected = PRICE_CLOSE;
input ENUM_MA_METHOD MaMethod = MODE_SMA;
input ENUM_MA_METHOD EMaMethod =  MODE_EMA;
input ENUM_APPLIED_PRICE priceMAselected = PRICE_CLOSE;
input int bands_periods = 20;
input int EmaPeriod = 50;
input int MAPeriods =  200;
input int RSIPeriods =  14;
input double bands_deviation = 2.0;
input double Lots = 0.01;
input bool IsMaFilter = true;
input bool IsTrendFilter = true;
input double closePercent = 30;
input double StopLossFactor = 2;
input double TakeProfitFactor = 0.5;


int OnInit()
{
    barsTotal = iBars(_Symbol, selectedTimeframe);
    handleBb = iBands(_Symbol, selectedTimeframe, bands_periods, 0, bands_deviation, priceSelected);
    handleMaFilter = iMA(_Symbol,selectedTimeframeMaFilter,MAPeriods,0,MaMethod,priceMAselected);
    handleEmaFilter = iMA(_Symbol, selectedTimeframeEmaFilter, EmaPeriod, 0, EMaMethod, priceMAselected);
    handleRsiFilter = iRSI(_Symbol, selectedTimeframe, RSIPeriods, priceSelected);


    Print("Bollinger Bands handle: ", handleBb);
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    // Funções de desinicialização, se necessário
}

void OnTick()
{
    int bars = iBars(_Symbol, selectedTimeframe);

    if (barsTotal < bars)
    {
        barsTotal = bars;

        double upperBand[], lowerBand[], moving_average[],maFilter[],emaFilter[],rsiFilter[];
        double closeValue1 = iClose(_Symbol, selectedTimeframe, 1);
        double closeValue2 = iClose(_Symbol, selectedTimeframe, 2);
      

        GetBollingerBandsValues(upperBand, lowerBand, moving_average,maFilter,emaFilter,rsiFilter);
        
          if (IsTrendFilter){
             if (!IsTrending(emaFilter) && !IsStrongTrend(rsiFilter))
             {
                 string noTrendMessage = "Nenhuma tendencia clara detectada. Pulando a execução da Trade.";
                 Print(noTrendMessage);
                 Comment(noTrendMessage);
                 return;
             }
         }


        ManageOpenPositions(upperBand, lowerBand, moving_average);
        CheckEntrySignals(upperBand, lowerBand, closeValue1, closeValue2,maFilter);
        PrintInformation(upperBand, lowerBand, moving_average, closeValue1, closeValue2,maFilter);
    }
}

void GetBollingerBandsValues(double &upperBand[], double &lowerBand[], double &moving_average[],double &maFilter[],double &emaFilter[],double &rsiFilter[])
{
    CopyBuffer(handleBb, BASE_LINE, 1, 2, moving_average);
    CopyBuffer(handleBb, UPPER_BAND, 1, 2, upperBand);
    CopyBuffer(handleBb, LOWER_BAND, 1, 2, lowerBand);
    CopyBuffer(handleMaFilter, BASE_LINE, 1, 1, maFilter);
    CopyBuffer(handleEmaFilter, BASE_LINE, 0, 2, emaFilter); // Obtém os valores da EMA
    CopyBuffer(handleRsiFilter, BASE_LINE, 0, 2, rsiFilter);


}

void ManageOpenPositions(const double &upperBand[], const double &lowerBand[], const double &moving_average[])
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong posTicket = PositionGetTicket(i);

        if (PositionSelectByTicket(posTicket))
        {
            double posLots = PositionGetDouble(POSITION_VOLUME);
            double posStopLoss = PositionGetDouble(POSITION_SL);
            double posTakeProfit = PositionGetDouble(POSITION_TP);

            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double lotsToClose = posLots * (closePercent/100);
            lotsToClose = NormalizeDouble(lotsToClose, 2);

            if (posType == POSITION_TYPE_BUY)
            {
                ManageBuyPosition(posLots, lotsToClose, moving_average, posStopLoss,posTicket,posTakeProfit);
            }
            else if (posType == POSITION_TYPE_SELL)
            {
                ManageSellPosition(posLots, lotsToClose, moving_average, posStopLoss,posTicket,posTakeProfit);
            }
        }
    }
}

void ManageBuyPosition(const double &posLots, const double &lotsToClose, const double &moving_average[], const double &posStopLoss,const ulong &posTicket,const double &posTakeProfit)
{
    double closeValue1 = iClose(_Symbol, selectedTimeframe, 1);

    if (closeValue1 > moving_average[0])
    {
        if (posLots == Lots)
        {
             
            if (myTrade.PositionClosePartial(posTicket, lotsToClose))
            {
                Print("Position #", posTicket, " was closed partially.");
            }
        }
    }

    if (posLots < Lots)
    {
        double s1 = moving_average[1];
        s1 = NormalizeDouble(s1, _Digits);

        if (s1 > posStopLoss)
        {
            if (myTrade.PositionModify(posTicket, posStopLoss, posTakeProfit))
            {
                Print("Position #", posTicket, " was modified by trailing stop loss.");
            }
        }
    }
}

void ManageSellPosition(const double &posLots, const double &lotsToClose, const double &moving_average[], const double &posStopLoss,const ulong &posTicket,const double &posTakeProfit)
{
    double closeValue1 = iClose(_Symbol, selectedTimeframe, 1);

    if (closeValue1 > moving_average[0])
    {
        if (posLots == Lots)
        {
            if (myTrade.PositionClosePartial(posTicket, lotsToClose))
            {
                Print("Position #", posTicket, " was closed partially.");
            }
        }
    }

    if (posLots < Lots)
    {
        double s1 = moving_average[1];
        s1 = NormalizeDouble(s1, _Digits);

        if (s1 < posStopLoss || posStopLoss == 0)
        {
            if (myTrade.PositionModify(posTicket, posStopLoss, posTakeProfit))
            {
                Print("Position #", posTicket, " was modified by trailing stop loss.");
            }
        }
    }
}

void CheckEntrySignals(const double &upperBand[], const double &lowerBand[], const double &closeValue1, const double &closeValue2,const double &maFilter[])
{
    if (closeValue1 > upperBand[1] && closeValue2 < upperBand[0])
    {
        ExecuteSellTrade(upperBand,lowerBand,maFilter);
    }
    else if (closeValue1 < lowerBand[1] && closeValue2 < lowerBand[0])
    {
        ExecuteBuyTrade(upperBand,lowerBand,maFilter);
    }
}

void ExecuteSellTrade(const double &upperBand[],const double &lowerBand[],const double &maFilter[])
{
    Print("Price closed above the upper Bollinger Bands -> Time to sell");
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    bid = NormalizeDouble(bid, _Digits);
    double distance = upperBand[1] - lowerBand[1];
    
    if(IsMaFilter == false || bid < maFilter[0]){
       double stop_loss = bid + distance*StopLossFactor;
       stop_loss = NormalizeDouble(stop_loss, _Digits);
   
       double take_profit = bid - distance*TakeProfitFactor;
       take_profit = NormalizeDouble(take_profit, _Digits);
   
       myTrade.Sell(Lots, _Symbol, bid, stop_loss, take_profit);
       }
}

void ExecuteBuyTrade(const double &upperBand[],const double &lowerBand[],const double &maFilter[])
{
    Print("Price closed below the lower Bollinger Bands -> Time to buy");
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    ask = NormalizeDouble(ask, _Digits);
    double distance = upperBand[1] - lowerBand[1];
    
    if(IsMaFilter==false || ask > maFilter[0]){
       double stop_loss = ask - distance*StopLossFactor;
       stop_loss = NormalizeDouble(stop_loss, _Digits);
       double take_profit = ask + distance*TakeProfitFactor;
       take_profit = NormalizeDouble(take_profit, _Digits);
       
       myTrade.Buy(Lots, _Symbol, ask,stop_loss,take_profit);
   }
}

void PrintInformation(const double &upperBand[], const double &lowerBand[], const double &moving_average[], const double &closeValue1, const double &closeValue2, const double &maFilter[])
{
    string comment;
    comment = "BB Middle[0]:" + DoubleToString(moving_average[0], _Digits) + " BB Middle[1]" + DoubleToString(moving_average[1], _Digits);
    comment += "\nBB Upper[0]:" + DoubleToString(upperBand[0], _Digits) + " BB Middle[1]" + DoubleToString(upperBand[1], _Digits);
    comment += "\nBB Lower[0]:" + DoubleToString(lowerBand[0], _Digits) + " BB Middle[1]" + DoubleToString(lowerBand[1], _Digits);
    comment += "\n Close1:" + DoubleToString(closeValue1, _Digits);
    comment += "\n Close2:" + DoubleToString(closeValue2, _Digits);
    comment += "\n maFilter:" + DoubleToString(maFilter[0], _Digits);
    Comment(comment);
}

bool IsTrending(const double &emaFilter[])
{
    // Verifica se a inclinação da EMA é positiva (tendência de alta) ou negativa (tendência de baixa)
    return emaFilter[0] > emaFilter[1];
}

bool IsStrongTrend(const double &rsiFilter[])
{
    // Verifica se o RSI está acima de um determinado limiar (por exemplo, 70) indicando uma tendência forte de alta.
    bool isUptrend = rsiFilter[0] > 70;

    // Verifica se o RSI está abaixo de um determinado limiar (por exemplo, 30) indicando uma tendência forte de baixa.
    bool isDowntrend = rsiFilter[0] < 30;

    // Retorna verdadeiro se estiver em uma tendência forte de alta ou baixa.
    return isUptrend || isDowntrend;
}

