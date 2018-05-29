function LineLevels = CreateLevels(Signal, LevelsStep, OverlapFactor)
%Создание уровней для заданного сигнала и шага уровней

if ~OverlapFactor %Соотношение эквивалентности разбиения перекрывающихся уровней
   OverlapFactor = 1; 
end
%Отсчетные значения
MaxSignal = max(Signal); %Максимальное значение функции пермещений
MeanSignal = mean(Signal); %Среднее значение функции пермещений
MinSignal = min(Signal); %Минимальное значение функции перемещений

%Реализация единственного уровня
if MaxSignal <= (mean(Signal) + LevelsStep/2) && MinSignal >= (mean(Signal) - LevelsStep/2)
    LineLevels(1,:) = [mean(Signal) - LevelsStep/2, mean(Signal) + LevelsStep/2, 0]; %Единичное срединное окно    
    return;
end

%Разбивка от min сигнала
LineLevels(1,:) = [min(Signal), min(Signal) + LevelsStep, -1]; %Параметры нулевого уровня 
i = 1; %Начальное значение инкремента
while 1 %Формируем нижние уровни
    if LineLevels(i,2) >= MaxSignal
        break;
    end
    i = i + 1; %Приращение инкремента
    LineLevels(i,:) = [LineLevels(i - 1, 1) + OverlapFactor*LevelsStep, LineLevels(i - 1, 2) + OverlapFactor*LevelsStep, -1]; %Запись значений линий уровня для нижней части
end
%Нумерация уровней
IndexZeroLevel = floor(size(LineLevels,1)/2); %Индекс нулевого уровня
LineLevels(IndexZeroLevel,3) = 0; %Проставление номера уровня
LineLevels(1:IndexZeroLevel - 1,3) = -(IndexZeroLevel - 1):-1; %Нижние уровни
LineLevels(IndexZeroLevel + 1:end,3) = 1:(size(LineLevels,1) - IndexZeroLevel); %Нижние уровни

end
