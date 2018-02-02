function [Signal, DependentArray] = PeakFilter(Signal, DependentArray)
%Простой фильтр пиков

DerivativeSignal = diff(Signal); %Находим первую производную от сигнала
Deviation = std(DerivativeSignal); %Стандартное отклонение производной
DelIndicies = find(abs(DerivativeSignal) > 3*Deviation); %Индексы выбросов
Signal(DelIndicies) = []; %Удаление выбросов
if ~isempty(DependentArray) %Корректировка зависимых массивов по заданному порядку
    DependentArray(DelIndicies,:) = [];
else
    DependentArray = 0;
end

end

