function [FixParts,PartsDerivative,IndexParts,OscillationParts,IndexOscillationParts] = FixNormalizeDerivative(Parts, IndexParts, CutProcent, NormalizeMode)
%Отсечение коротких фрагментов и нормализация длинных. Вычисление конечных
%разностей

LevelsNumb = length(Parts); %Число уровней
    %Выделение коротких фрагментов
for i = 1:LevelsNumb
    SaveIndex = 0; %Номер конца предыдущего фрагмента    
    for j = 1:length(IndexParts{i}) %Цикл по всем уровням
        LengthsFragment{i}(j,1) = length(Parts{i}(SaveIndex + 1:IndexParts{i}(j),2)); %Запись длин всех фрагментов
        SaveIndex = IndexParts{i}(j); %Запись индекса конца фрагмента        
    end
    MaxLength(i) = max(LengthsFragment{i}); %Нахождение максимальной длиный для заданного уровня
    LimCut(i) = ceil(MaxLength(i)*CutProcent); %Предел длины отрезка для каждого из уровней
end
    %Отсечение коротких фрагментов
for i = 1:LevelsNumb
    SaveIndex = 0;
    FixParts{i} = []; %Начальное значение усеченных сигнала
    OscillationParts{i} = []; %Начальное значение файла биений сигнала
    for j = 1:size(IndexParts{i},1)
        if LengthsFragment{i}(j,1) > LimCut(i) %Оценка длины фрагмента
            FixParts{i} = [FixParts{i};Parts{i}(SaveIndex + 1:IndexParts{i}(j),:)]; %Добавление фрагмента в конец записи
        elseif LengthsFragment{i}(j,1) > 1 %Пропускаем фрагменты из одной точки
            OscillationParts{i} = [OscillationParts{i}; Parts{i}(SaveIndex + 1:IndexParts{i}(j),:)]; %Добавление нейтрального фрагмента
        end
        SaveIndex = IndexParts{i}(j); %Запись индекса конца фрагмента
    end
    IndexParts{i} = find(FixParts{i}(:,3) == 1); %Запись номеров фрагментов в локальную переменную
    if IndexParts{i}(end,1) < size(FixParts{i},1)
        IndexParts{i}(end + 1,1) = size(FixParts{i},1); %Добавление индекса конца последнего фрагмента
        FixParts{i}(end,3) = 1;
    end
    if ~isempty(OscillationParts{i})
        IndexOscillationParts{i} = find(OscillationParts{i}(:,3) == 1); %Запись номеров фрагментов в локальную переменную
        if IndexOscillationParts{i}(end,1) < size(OscillationParts{i},1)
            IndexOscillationParts{i}(end + 1,1) = size(OscillationParts{i},1); %Добавление индекса конца последнего фрагмента
            OscillationParts{i}(end,3) = 1;
        end
    else
        IndexOscillationParts{i} = OscillationParts{i}; %Проверка соответствия длин
    end
end
    %Нормировка каждого фрагмента сигнала 
for i = 1:LevelsNumb %Цикл по всем уровням
    SaveIndex = 0; %Номер конца предыдущего фрагмента
    for j = 1:length(IndexParts{i}) %Цикл по номерам индексов фрагментов
        MeanTemp = mean(FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2)); %Среднее значение каждого фрагмента
        FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2) = FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2) - MeanTemp;
        if NormalizeMode %Нормировка каждого фрагмента по максимуму
            MaxTemp = max(abs(FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2))); %Локальный максимум фрагмента
            if MaxTemp ~= 0 %Пропуск нормировки нулевых фрагментов
                FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2) = FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2)./MaxTemp;
            end
        end
        SaveIndex = IndexParts{i}(j); %Запись индекса конца фрагмента
    end
end
    %Нахождение производных на каждом фрагменте
for i = 1:LevelsNumb %Цикл по всем уровням
    SaveIndex = 0; %Номер конца предыдущего фрагмента
    for j = 1:length(IndexParts{i}) %Цикл по номерам индексов фрагментов
        if LengthsFragment{i}(j) ~= 1 %Проверка одиночных фрагментов
            PartsDerivative{i}(IndexParts{i}(j),1) = FixParts{i}(IndexParts{i}(j),2) - FixParts{i}(IndexParts{i}(j) - 1,2); %Левая конечная разность
            for s = SaveIndex + 1:IndexParts{i}(j) - 1 %Цикл по всем точкам следующего фрагмента
                PartsDerivative{i}(s,1) = FixParts{i}(s + 1,2) - FixParts{i}(s,2);
            end
        else
            PartsDerivative{i}(IndexParts{i}(j),1) = 0; %Обнулить производную, если фрагмент одиночный
        end
        SaveIndex = IndexParts{i}(j); %Запись индекса конца фрагмента
    end 
    PartsDerivative{i} = [FixParts{i}(:,1),PartsDerivative{i}];
    PartsDerivative{i}(:,3) = FixParts{i}(:,3);
end 

end

