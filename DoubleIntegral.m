function [SignalSecondIntegralOutput] = DoubleIntegral(Time, Signal, CutOffFrequency, SampleRate)
%Двойное интегрирование исходного сигнала c выделением высоких частот

PolyDegree = 20; %Степень интерполирующего среднюю линию полинома
    %Первый интеграл
SignalFirstIntegral = cumsum(Signal); %Вычисление первого интеграла по методу трапеций
MeanLineCoeffs = polyfit(Time,SignalFirstIntegral,PolyDegree); %Нахождение коэффициентов интерполирующего полинома
MeanLine = polyval(MeanLineCoeffs,Time); %Нахождение средней линии по коэффициентам полинома
SignalFirstIntegralHighFreq = SignalFirstIntegral - MeanLine; %Отсечение низкочастотной составляющей для первого интеграла
SignalFirstIntegralHighFreq = SignalFirstIntegralHighFreq - SignalFirstIntegralHighFreq(1); %Смещение интеграла к нулевой линии
    %Второй интеграл
SignalSecondIntegral = cumtrapz(SignalFirstIntegralHighFreq); %Второе интегрирование сигнала
if isempty(CutOffFrequency) || CutOffFrequency == 0 %Проверка наличия фильтра
    SignalSecondIntegralOutput = SignalSecondIntegral; %Сохраняем сигнала без фильтра
else
    CutOffFrequencyFilter = CutOffFrequency*200; %Частота сигнала для фильтрации
    [b, a] = butter(4,CutOffFrequencyFilter/(SampleRate/2),'high'); %Параметры фильтрации ФВЧ Баттерворта
    SignalSecondIntegralOutput = filter(b,a,SignalSecondIntegral); %Применение фильтра
end
end

