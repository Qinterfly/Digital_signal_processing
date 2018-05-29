function  [PartsSignal IndexPartsSignal] = AssignLevels(Time, Signal, LineLevels)
%Выделение частей сигнала по уровнями

LevelsNumb = size(LineLevels, 1); %Число уровней
for i = 1:LevelsNumb %Цикл по числу уровней
    k = 1; %Значение инкремента 
    for j = 1:length(Signal) %Цикл по значениям сигнала
        if Signal(j) >= LineLevels(i,1) && Signal(j) <= LineLevels(i,2) %Оценка вхождения в уровень
            PartsSignal{i}(k,1) = Time(j); %Запись времени 
            PartsSignal{i}(k,2) = Signal(j); %Запись сигнала
            if j ~= length(Signal) %Если конец не достигнут
               if ~(Signal(j+1) >= LineLevels(i,1) && Signal(j+1) <= LineLevels(i,2)) %Проверка конца фрагмента
                   PartsSignal{i}(k,3) = 1; %Идентификатор конца фрагмента
               end
            end
            k = k + 1; %Приращение инкремента номера строки
        end
    end
    PartsSignal{i}(end,3) = 1; %Проставление индекса конца последнего фрагмента 
    IndexPartsSignal{i} = find(PartsSignal{i}(:,3) == 1); %Получение индексов концов фрагментов
end
    
end