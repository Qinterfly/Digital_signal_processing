function FunCorrect = LineCorrect(Arg, Fun)
%Линейная корректировка сигнала

LowFrequencyLine = (Fun(end) - Fun(1)).*(Arg - Arg(1))./(Arg(end) - Arg(1)) + Fun(1); %Прямая, соединяющая концы сигнала
FunCorrect = Fun - LowFrequencyLine; %Вычитание низкочастотной части

end

