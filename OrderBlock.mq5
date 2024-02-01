#https://www.youtube.com/watch?v=NaWpOBxdsCY
#https://www.youtube.com/watch?v=c03leZWLVDw

//+------------------------------------------------------------------+
//| Função para obter pontos de entrada e saída                      |
//+------------------------------------------------------------------+
void ObterPontosOperacao(int index, out double pontoEntrada, out double pontoSaida)
{
   // Armazenar os preços do Order Block
   double orderBlockHigh = iHigh(_Symbol, PERIOD_H4, index - 1);
   double orderBlockLow = iLow(_Symbol, PERIOD_H4, index - 1);

   // Armazenar o preço do novo topo formado após o Order Block
   double novoTopo = iHigh(_Symbol, PERIOD_H4, 0);

   // Definir o ponto de entrada como o preço do novo topo
   pontoEntrada = novoTopo;

   // Definir o ponto de saída como o preço do Order Block
   pontoSaida = orderBlockLow;

   Print("Ponto de Entrada: ", pontoEntrada);
   Print("Ponto de Saída: ", pontoSaida);
}

//+------------------------------------------------------------------+
//| Função para realizar a entrada na posição                        |
//+------------------------------------------------------------------+
void EntrarNaPosicao(double pontoEntrada, double pontoSaida)
{
   // Coloque aqui lógica para realizar a entrada na posição no gráfico de 15 minutos
   // Por exemplo: OrderSend, OrderModify, etc.
   // Use os valores de pontoEntrada e pontoSaida conforme necessário
   Print("Entrando na posição no gráfico de 15 minutos");
}

//+------------------------------------------------------------------+
//| Função para confirmar o Bloco de Ordem                           |
//+------------------------------------------------------------------+
void ConfirmarOrderBlock(int index)
{
   // Armazenar os preços do Order Block
   double orderBlockHigh = iHigh(_Symbol, PERIOD_H4, index - 1);

   // Aguardar o teste do Order Block com novo topo
   while (true)
   {
      // Verificar se há um novo topo formado
      if (iHigh(_Symbol, PERIOD_H4, 0) > orderBlockHigh)
      {
         Print("Novo topo formado após o Order Block");

         // Obter pontos de entrada e saída
         double pontoEntrada, pontoSaida;
         ObterPontosOperacao(index, pontoEntrada, pontoSaida);

         // Realizar a entrada na posição no gráfico de 15 minutos
         EntrarNaPosicao(pontoEntrada, pontoSaida);

         // Coloque aqui qualquer ação adicional que você deseje realizar
         break; // Saia do loop de verificação de novo topo
      }

      Sleep(1000); // Aguardar um segundo antes de verificar novamente
   }
}


//+------------------------------------------------------------------+
//| Função para verificar toque no Order Block                       |
//+------------------------------------------------------------------+
void VerificarToqueNoOrderBlock2(int index)
{
   // Armazenar os preços do Order Block
   double orderBlockHigh = iHigh(_Symbol, PERIOD_H4, index - 1);
   double orderBlockLow = iLow(_Symbol, PERIOD_H4, index - 1);

   // Aguardar o toque no Order Block durante a reversão
   while (true)
   {
      // Verificar se o preço toca o Order Block
      if (iHigh(_Symbol, PERIOD_M15, 0) >= orderBlockLow && iLow(_Symbol, PERIOD_M15, 0) <= orderBlockHigh)
      {
         Print("Preço tocou o Order Block no gráfico de 15 minutos");

         // Coloque aqui lógica para realizar a entrada na posição no gráfico de 15 minutos
         // Por exemplo: OrderSend, OrderModify, etc.
      }

      Sleep(1000); // Aguardar um segundo antes de verificar novamente
   }
}

//+------------------------------------------------------------------+
//| Função para confirmar o Bloco de Ordem                           |
//+------------------------------------------------------------------+
void ConfirmarOrderBlock2(int index)
{
   // Armazenar os preços do Order Block
   double orderBlockHigh = iHigh(_Symbol, PERIOD_H4, index - 1);

   // Aguardar o teste do Order Block com novo topo
   while (true)
   {
      // Verificar se há um novo topo formado
      if (iHigh(_Symbol, PERIOD_H4, 0) > orderBlockHigh)
      {
         Print("Novo topo formado após o Order Block");

         // Armazenar o preço do novo topo
         double novoTopo = iHigh(_Symbol, PERIOD_H4, 0);

         // Desenhar uma linha no novo topo
         ObjectCreate(0, "NewTopLine", OBJ_TREND, 0, 0, iTime(_Symbol, PERIOD_H4, 0), novoTopo, iTime(_Symbol, PERIOD_H4, index - 1), novoTopo);
         ObjectSetInteger(0, "NewTopLine", OBJPROP_COLOR, clrBlue); // Cor da linha (azul)

         // Calcular a distância em pips entre o Order Block e o novo topo
         double distanciaEmPips = MathAbs(orderBlockHigh - novoTopo) / _Point;
         Print("Distância entre Order Block e Novo Topo: ", distanciaEmPips, " pips");

         // Aguardar a reversão para baixo
         while (true)
         {
            // Verificar se ocorreu uma reversão para baixo
            if (iLow(_Symbol, PERIOD_H4, 0) < novoTopo)
            {
               Print("Confirmação: Reversão para baixo após o novo topo");

               // Verificar toque no Order Block no gráfico de 15 minutos
               VerificarToqueNoOrderBlock(index);

               // Coloque aqui qualquer ação adicional que você deseje realizar
               break; // Saia do loop de verificação de reversão
            }

            Sleep(1000); // Aguardar um segundo antes de verificar novamente
         }

         break; // Saia do loop de verificação de novo topo
      }

      Sleep(1000); // Aguardar um segundo antes de verificar novamente
   }
}

