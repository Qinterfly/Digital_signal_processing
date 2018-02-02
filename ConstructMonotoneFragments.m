function [SignalIncrease SignalDecrease IndexIncrease IndexDecrease] = ConstructMonotoneFragments(Signal,SignalDerivative,Accel,ModeMonotone)
%Выделение одномонотонных фрагментов по перемещениям

SignalIncrease = []; %Обнуление возрастающих фрагментов
SignalDecrease = []; %Обнуление убывающих фрагментов
AccelIncrease = []; %Обнуление возрастающих фрагментов ускорений
AccelDecrease = []; %Обнуление убывающих фрагментов
    %Выделение фрагментов
LastIncrease = 1;
LastDecrease = 1;
for i = 1:length(Signal) - 1 %Цикл по всем точкам сигнала
    if SignalDerivative(i) >= 0 %Если производная неотрицательна - относим к возрастающим фрагментам
        SignalIncrease(LastIncrease,:) = [i, Signal(i,:), 0] ; %Значения сигнала перемещений
        AccelIncrease(LastIncrease,:) = [i, Accel(i,:), 0]; %Значения сигнала ускорений
        if LastIncrease > 1 
           if SignalIncrease(end,1) - SignalIncrease(end - 1,1) > 1
               SignalIncrease(end - 1,3) = 1;
               AccelIncrease(end - 1,3) = 1; 
           end
        end
        LastIncrease = LastIncrease + 1; %Приращение последнего индекса
    end
    if SignalDerivative(i) <= 0 %Если производная неположительна - относим к убывающим фрагментам
        SignalDecrease(LastDecrease,:) = [i, Signal(i,:), 0] ; %Значения сигнала перемещений
        AccelDecrease(LastDecrease,:) = [i, Accel(i,:), 0]; %Значения сигнала ускорений
        if LastDecrease > 1 
           if SignalDecrease(end,1) - SignalDecrease(end - 1,1) > 1
               SignalDecrease(end - 1,3) = 1;
               AccelDecrease(end - 1,3) = 1;               
           end
        end
        LastDecrease = LastDecrease + 1; %Приращение последнего индекса
    end
end
    %Проверка выбора режима работы
switch ModeMonotone
    case 'Accel'
        SignalIncrease = AccelIncrease; %Перенос фрагментов на ускорения
        SignalDecrease = AccelDecrease;
    case 'Displacement'
        SignalIncrease = SignalIncrease; %Фрагменты на перемещениях (зарезервированный case)
        SignalDecrease = SignalDecrease;
end
    %Проверка нахождения фрагментов
%Убывающие
if isempty(SignalDecrease)
    SignalDecrease = zeros(size(SignalIncrease));
    SignalDecrease(:,1) = SignalIncrease(:,1); %Столбец номеров точек
end
%Возрастающие
if isempty(SignalIncrease)
    SignalIncrease = zeros(size(SignalDecrease));
    SignalIncrease(:,1) = SignalDecrease(:,1); %Столбец номеров точек
end
SignalDecrease(end,3) = 1; %Проставление последнего индекса конца фрагмента
SignalIncrease(end,3) = 1; 
IndexIncrease = find(SignalIncrease(:,3) == 1); %Отыскание индексов всех фрагментов
IndexDecrease = find(SignalDecrease(:,3) == 1); %Отыскание индексов всех фрагментов
end



