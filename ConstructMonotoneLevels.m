function [PartsMonotoneAccel, IndexMonotoneAccel] = ConstructMonotoneLevels(PartsAccel, PartsDisplacement, LineLevels)
%Выделение монотонных частей в уровнях 
%(Signal->Levels(Increase, Neutral, Decrease)

MaxLengthParts = [0, 0, 0]; %Инициализация массива наибольших длин по всем уровням
for i = 1:size(LineLevels,1) %По всем уровням
    IndexParts = find(PartsAccel{i}(:,3) == 1); %Получение индексов концов фрагментов
    Boundary = abs(LineLevels(i,2) - LineLevels(i,1)) * 0.05; %Максимальная величина расхождения границ (5% длины)
    for s = 1:3 %Обнуление сигналов : [Increase, Neutral, Decrease]
        PartsMonotoneAccel{s}{i} = [];
    end
    SaveIndex = 1; %Индекс конца фрагмента
    for j = 1:length(IndexParts)
        Difference = PartsDisplacement{i}(IndexParts(j),2) - PartsDisplacement{i}(SaveIndex,2); %Запись разницы границ
        FlagMonotone = 0; %Флаг переключение записи 
        if abs(Difference) > Boundary %Проверка превышение погрешности
            %Возрастающие
            if Difference > 0
                FlagMonotone = 1;
            end
            %Убывающие
            if Difference < 0
                FlagMonotone = 3;
            end
        %Нейтральные
        else
            FlagMonotone = 2;
        end
            %Запись матрицы по флагу
        PartsMonotoneAccel{FlagMonotone}{i} = [PartsMonotoneAccel{FlagMonotone}{i}; PartsAccel{i}(SaveIndex:IndexParts(j),:)]; 
        SaveIndex = IndexParts(j) + 1; %Приращение индекса следующего за концом фрагмента   
    end
    %Нахождение длин монотонных фрагментов по уровню
    for s = 1:3 %[Increase, Neutral, Decrease]
        if MaxLengthParts(s) < length(PartsMonotoneAccel{s}{i})
            MaxLengthParts(s) = length(PartsMonotoneAccel{s}{i});
        end
    end
end
%Проверка + индексация 
for i = 1:size(LineLevels,1)
    for s = 1:3
        if isempty(PartsMonotoneAccel{s}{i})
            if MaxLengthParts(s) ~= 0
                PartsMonotoneAccel{s}{i} = zeros(MaxLengthParts(s),3);
            else
                PartsMonotoneAccel{s}{i} = zeros(max(MaxLengthParts),3);
            end
            PartsMonotoneAccel{s}{i}(end, 3) = 1;
        end %Проверка записи
        IndexMonotoneAccel{s}{i} = find(PartsMonotoneAccel{s}{i}(:,3) == 1); %Запись индексов
    end
    
end

end

