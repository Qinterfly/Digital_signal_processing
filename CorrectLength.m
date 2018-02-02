function NewSignal = CorrectLength(Signal,LengthCorrect,MonotoneFragmentIndent,DepthGluing)
    %Приведение склеек по длине

if LengthCorrect == 0 %Если приведение по длине не включено
    NewSignal = Signal; %Возвращаем исходные данные
    return;
end
    %Проверка формата ввода
if iscell(Signal) 
    LevelsNumb = length(Signal); %Число уровней
else
    error('Формат входных данных: cell');
end
    %Приведение к единому фрагменту
for i = 1:LevelsNumb
    TempIndex = find(Signal{i}(:,3) == 1); %Индексы всех фрагментов
    TempIndex(end) = []; %За исключением конца
    Signal{i}(TempIndex,3) = 0; 
end
    %Вычисление производных
for i = 1:LevelsNumb
    for j = 1:size(Signal{i},1) - 1
        SignalDerivative{i}(j,2) = Signal{i}(j + 1,2) - Signal{i}(j,2);        
    end
    SignalDerivative{i}(end + 1,2) = Signal{i}(end,2) - Signal{i}(end - 1,2); %Левая конечная разность
    SignalDerivative{i}(:,1) = Signal{i}(:,1); %Глобальные индексы
    SignalDerivative{i}(:,3) = Signal{i}(:,3); %Индексы конца фрагментов
    %Удвоение для паттерна
    TempSignal{i} = [Signal{i}; Signal{i}]; %Сигнал
    TempSignalDerivative{i} = [SignalDerivative{i}; SignalDerivative{i}]; %Производные
    %Получение индексов
    IndexTempSignal{i} = find(TempSignal{i}(:,3) == 1);
end
    %Вызов оптимальной склейки
if ~MonotoneFragmentIndent %Для работы с монотонными фрагментами
    [SignalGlued FailSignalGlued] = OptimalGluing(IndexTempSignal,TempSignal,TempSignalDerivative,0.4,DepthGluing); %Для работы с сигналом, делённым на уровни
    %Выделения паттерна для клонирования
    for i = 1:LevelsNumb %Цикл по числу уровней
        IndexSignalGlued{i} = find(SignalGlued{i}(:,3) == 1); %Выделение индексов двух фрагментов
        Pattern{i} = SignalGlued{i}(IndexSignalGlued{i}(1) + 1:end,:); %Забираем паттерн
    end
else
    for i = 1:LevelsNumb %Цикл по числу уровней
        Pattern{i} = Signal{i}; %Забираем паттерн
        SignalGlued{i} = Signal{i}; 
    end
end
    %Приведение к длине
for i = 1:LevelsNumb %Цикл по всем уровням
    CopyNumb = ceil(LengthCorrect/length(Pattern{i})); %Число копирований по длине
    if CopyNumb > 1 %Если склейка больше заданной длины
        NewSignal{i} = [Signal{i};Pattern{i}];
        for j = 1:CopyNumb %Копируем CopyNumb раз
            NewSignal{i} = [NewSignal{i}; Pattern{i}];
        end
    else
        NewSignal{i} = Signal{i}(1:LengthCorrect,:);
        NewSignal{i}(end,3) = 1; %Новые конец
    end
    IndexNewSignal{i} = find(NewSignal{i}(:,3) == 1);
end
    %При работе с монотонными фрагментами провести повторную склейку
if MonotoneFragmentIndent  
    NewSignal = SimpleGluing(NewSignal, IndexNewSignal);
end
    %Проверка по длине
for i = 1:LevelsNumb
    if length(NewSignal{i}) > LengthCorrect %Корректировка по длине
        NewSignal{i} = NewSignal{i}(1:LengthCorrect,:);
        NewSignal{i}(end,3) = 1;
    end
end

end
