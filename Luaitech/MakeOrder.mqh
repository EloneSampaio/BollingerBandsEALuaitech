#include <Trade/Trade.mqh>

class MakeOrder
{
public:
    CTrade myTrade;
    double ask;
    double bid;
    double stop_loss;
    double take_profit;
    double lotSize;

    MakeOrder();
    ~MakeOrder();
    void ExecuteBuyTrade(double size, double stopLoss, double takeProfitFactor);
    void ExecuteSellTrade(double size, double stopLoss, double takeProfitFactor);
    void ManageSellPosition(double lotsToClose, double posStopLoss, ulong posTicket, double posTakeProfit);
    void ManageBuyPosition(double lotsToClose, double posStopLoss, ulong posTicket, double posTakeProfit);
};

MakeOrder::MakeOrder()
{
}

MakeOrder::~MakeOrder()
{
}

void MakeOrder::ExecuteBuyTrade(double size, double stopLoss, double takeProfitFactor)
{
    lotSize = size;
    ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    ask = NormalizeDouble(ask, _Digits);
    stop_loss = stopLoss;
    take_profit = ask + (ask - stopLoss) * takeProfitFactor;
    myTrade.Buy(lotSize, _Symbol, ask, stop_loss, take_profit);
}

void MakeOrder::ExecuteSellTrade(double size, double stopLoss, double takeProfitFactor)
{
    lotSize = size;
    bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    bid = NormalizeDouble(bid, _Digits);
    stop_loss = stopLoss;
    take_profit = bid - (stopLoss - bid) * takeProfitFactor;
    myTrade.Sell(lotSize, _Symbol, bid, stop_loss, take_profit);
}

void MakeOrder::ManageSellPosition(double lotsToClose, double posStopLoss, ulong posTicket, double posTakeProfit)
{
    if (lotSize == lotsToClose)
    {
        if (myTrade.PositionClosePartial(posTicket, lotsToClose))
        {
            Print("Entrou na posição #", posTicket, " foi fechada parcialmente.");
        }
    }

    if (lotSize < lotsToClose)
    {
        if (myTrade.PositionModify(posTicket, posStopLoss, posTakeProfit))
        {
            Print("Posição #", posTicket, " foi modificada para evitar stop loss.");
        }
    }
}

void MakeOrder::ManageBuyPosition(double lotsToClose, double posStopLoss, ulong posTicket, double posTakeProfit)
{
    if (lotSize == lotsToClose)
    {
        if (myTrade.PositionClosePartial(posTicket, lotsToClose))
        {
            Print("Position #", posTicket, " was closed partially.");
        }
    }

    if (lotSize < lotsToClose)
    {
        if (myTrade.PositionModify(posTicket, posStopLoss, posTakeProfit))
        {
            Print("Position #", posTicket, " was modified by trailing stop loss.");
        }
    }
}
