function [PartsSignalGlued Fail] = OptimalGluing(IndexPartsSignal,FixPartsSignal,PartsSignalDerivative,CutIntervalProcent,ShiftIntervalProcent)
%Склейка концов фрагментов по критерию минимума среднего между разницей по
%сигнала и производной от сигнала
%ShiftIntervalProcent - смещение конца предыдущего отрезка в процентах
%CutIntervalProcent - глубина прохода для склейки

LevelsNumb = length(IndexPartsSignal);
for i = 1:LevelsNumb
    if isempty(IndexPartsSignal{i}) %Обработка пустого уровня
        PartsSignalGlued{i} = zeros(500,2); 
    else
        SaveIndex = IndexPartsSignal{i}(1); %Номер конца предыдущего фрагмента
        PartsSignalGlued{i} = FixPartsSignal{i}(1:SaveIndex,:); %Запись показаний сигнала для предыдущего фрагмента
        PartsSignalDerivativeGlued{i} = PartsSignalDerivative{i}(1:SaveIndex,:); %Запись производных для предыдушего фрагмента
        Fail{i} = 0; %Обнуление счётчика ошибок для текущего уровня
        for j = 2:length(IndexPartsSignal{i})
            LengthIntervalRight = IndexPartsSignal{i}(j) - SaveIndex; %Длина текущего фрагмента
            IndexFrag = find(PartsSignalGlued{i}(:,3) == 1);
            if length(IndexFrag) ~= 1 %Проверка первого фрагмента
                LengthIntervalLeft = IndexFrag(end) - IndexFrag(end - 1); %Длина левого фрагмента
            else
                LengthIntervalLeft = IndexFrag;
            end
            CutValue = ceil(CutIntervalProcent*LengthIntervalRight); %Число точек для среза справа
            ShiftValue = ceil(ShiftIntervalProcent*LengthIntervalLeft); %Число точек для оценки слева
            ErrorComplex = {}; %Обнуление массива погрешностей
            MinErrorLocal = []; 
            for m = 0:ShiftValue
                MarkValueSignal = PartsSignalGlued{i}(end - m,2); %Значение ускорения конца предыдущего фрагмента
                MarkValueSignallDerivative = PartsSignalDerivativeGlued{i}(end - m,2); %Значение производной от ускорения конца предыдущего фрагмента
                ErrorComplex{m + 1} = []; %Обнулением комплекса оценки
                k = 1; %Фиктивный счётчик точек
                for s = SaveIndex + 1:IndexPartsSignal{i}(j) - CutValue %Цикл по всем точкам следующего фрагмента до среза
                    if PartsSignalDerivative{i}(s,2)*MarkValueSignallDerivative >= 0
                        ErrorComplex{m + 1}(k,1) = s; %Глобальный номер точки
                        ErrorComplex{m + 1}(k,2) = abs(FixPartsSignal{i}(s,2) - MarkValueSignal); %Разница ускорений
                        ErrorComplex{m + 1}(k,3) = abs(PartsSignalDerivative{i}(s,2) - MarkValueSignallDerivative); %Разница производных от ускорений
                        ErrorComplex{m + 1}(k,4) = (ErrorComplex{m + 1}(k,2) + ErrorComplex{m + 1}(k,3))/2; %Среднее между разницей ускорений и производной от ускорений (быстрее mean)
                        k = k + 1; %Приращение счётчика точек
                    end
                end
                if ~isempty(ErrorComplex{m + 1}) %Проверка наличия оптимальных точек
                    [MinErrorLocal(m + 1) NumbErrorRowLocal(m + 1)] = min(ErrorComplex{m + 1}(1:end,4)); %Нахождение локального номера точки начала следующего фрагмента
                else
                    MinErrorLocal(m + 1) = Inf; %Для избежания потери индекса (смещения)
                    NumbErrorRowLocal(m + 1) = Inf;
                    Fail{i} = Fail{i} + 1; %Приращение счётчика ошибок
                end
            end
            if ~min(MinErrorLocal == Inf) %Если есть варинты склейки
                %Поиск лучшего варианта
                [MinErrorGlobal IndexErrorGlobal] = min(MinErrorLocal); %Минимум из варианта решений
                NumbErrorRowGlobal = NumbErrorRowLocal(IndexErrorGlobal); %Строка с правой оптимальной точкой
                RightIndex = ErrorComplex{IndexErrorGlobal}(NumbErrorRowGlobal,1) + 1; %Точка следующая за оптимальной
                LeftIndex = size(PartsSignalGlued{i},1) - IndexErrorGlobal + 1; %Индекс среза левого фрагмента
                %Усечение последнего фрагмента по лучшему варианту
                PartsSignalGlued{i} = PartsSignalGlued{i}(1:LeftIndex,:); %Ускорения
                PartsSignalGlued{i}(LeftIndex,3) = 1; %Проставление конца фрагмента
                PartsSignalDerivativeGlued{i} = PartsSignalDerivativeGlued{i}(1:LeftIndex,:); %Производные
                PartsSignalDerivativeGlued{i}(LeftIndex,3) = 1; %Проставление конца фрагмента
                %Присоединение новых частей
                PartsSignalGlued{i} = [PartsSignalGlued{i}; FixPartsSignal{i}(RightIndex:IndexPartsSignal{i}(j),:)]; %Склейка фрагментов ускорений
                PartsSignalDerivativeGlued{i} = [PartsSignalDerivativeGlued{i}; PartsSignalDerivative{i}(RightIndex:IndexPartsSignal{i}(j),:)]; %Склейка фрагментов производных от ускорений
            end
            SaveIndex = IndexPartsSignal{i}(j); %Запись индекса конца фрагмента
        end
    end
%PartsSignalGlued{i}(:,2) = PartsSignalGlued{i}(:,2) - PartsSignalGlued{i}(1,2); %Отнулевое смещение после склейки
end

end

