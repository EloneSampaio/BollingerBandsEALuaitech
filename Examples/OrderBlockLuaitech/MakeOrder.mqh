#include <Trade/Trade.mqh>

class MakeOrder
{
public:
    CTrade myTrade;
    double lotSize;

    MakeOrder();
    ~MakeOrder();
    void ExecuteBuyTrade(double size, double orderBlockPrice);
    void ExecuteSellTrade(double size, double orderBlockPrice);
};

MakeOrder::MakeOrder()
{
}

MakeOrder::~MakeOrder()
{
}

void MakeOrder::ExecuteBuyTrade(double size, double orderBlockPrice)
{
    lotSize = size;
    double stopLoss = orderBlockPrice;
    double takeProfit = orderBlockPrice + (orderBlockPrice - stopLoss) * 3.0;
    myTrade.Buy(lotSize, _Symbol, orderBlockPrice, stopLoss, takeProfit);
}

void MakeOrder::ExecuteSellTrade(double size, double orderBlockPrice)
{
    lotSize = size;
    double stopLoss = orderBlockPrice;
    double takeProfit = orderBlockPrice - (stopLoss - orderBlockPrice) * 3.0;
    myTrade.Sell(lotSize, _Symbol, orderBlockPrice, stopLoss, takeProfit);
}