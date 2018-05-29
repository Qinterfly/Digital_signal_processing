function [PartsSignalApproxSpline,TableDecrementVisualize,PartsExpSignal,IndexPartsExpSignal,Limits] = FindExpDecrease(Signal,LimExpLevel,AccuracyExp,FreqDecrement,SampleRate,ModelApprox)
%Поиск экспонециального затухания в сигнале
%Output: 1 - убывающие; 2 - нулевые; 

%Находим лимитирующее значение
ExpLevel = max(abs(Signal))*LimExpLevel;
Limits = [mean(Signal) - ExpLevel, mean(Signal) + ExpLevel]; %Пределы с учетом средней линии
%Находим период, соответствующий анализируемой частоте
PeriodDecrement = floor(1/FreqDecrement*SampleRate/200);
if PeriodDecrement == 0
   error('Искомая частота не может быть обнаружена. Частоты дискретизации прибора недостаточно'); 
end
%Ищем части сигнала по уровням
IndUp = 1; IndDown = 1; IndNeutral = 1; %Счетчики убывающих фрагментов
for i = 1:length(Signal)
    %Убывающие фрагменты выше оси
    if Signal(i) >= Limits(2)
       PartsExpSignalTemp{1}(IndUp,:) = [i Signal(i) 0];
       IndUp = IndUp + 1;
    end
    %Убывающие фрагменты ниже оси
    if Signal(i) <= Limits(1)
        PartsExpSignalTemp{3}(IndDown,:) = [i Signal(i) 0];
        IndDown = IndDown + 1;
    end
    %Нейтральные фрагменты фрагменты
    if Signal(i) >= Limits(1) && Signal(i) <= Limits(2)
        PartsExpSignalTemp{2}(IndNeutral,:) = [i Signal(i) 0];
        IndNeutral = IndNeutral + 1;
    end
end
    %Находим концы фрагментов 
for s = [1 3] %Фрагменты выше и ниже оси
    [ExpSignalApprox ExpSignalApproxDerivative] = ApproxSpline(PartsExpSignalTemp{s}(:,1),PartsExpSignalTemp{s}(:,1),PartsExpSignalTemp{s}(:,2),AccuracyExp,2); %Аппроксимация B-сплайнами
    k = 1;
    for i = 1:length(ExpSignalApproxDerivative) - 1
        if ExpSignalApproxDerivative(i+1)*ExpSignalApproxDerivative(i) < 0 %Отыскание корня
            IndexPartsExpSignalTemp{s}(k,1) = PartsExpSignalTemp{s}(i,1); %Запись корня в индекс конца фрагмента
            k = k + 1; %Приращение счётчика
        end
    end
    IndexPartsExpSignalTemp{s}(1:2:length(IndexPartsExpSignalTemp{s})-1) = []; %Удаление левых границ (определены неточно)
    %Проставление индексов концов фрагментов
    k = 1;
    for i = 1:length(IndexPartsExpSignalTemp{s})
        for j = 1:length(PartsExpSignalTemp{s})
            if PartsExpSignalTemp{s}(j,1) == IndexPartsExpSignalTemp{s}(i)
                PartsExpSignalTemp{s}(j,3) = 1; %Конец фрагмента
                IndexPartsSignalApproxSpline{s}(k,1) = j;
                k = k + 1;
                break
            end
        end
    end
    %Выделение частичных сплайнов для каждого пика
    SaveIndex = 0; %Начальное значение индекса конца предыдущего фрагмента
    PartsSignalApproxSpline{s} = [];
    for i = 1:length(IndexPartsSignalApproxSpline{s}) %Нахождение всех частичных сплайнов
        Xdata = PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),1); %Значения для аппроксимации
        Ydata = PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),2);
        try
            switch ModelApprox %Модель аппроксимации затухания
                case 'B-Spline'
                    [ResultTemp, ~] = ApproxSpline(Xdata,Xdata,Ydata,AccuracyExp,0); %Аппроксимация B-сплайнами
                case 'Exponential'
                    FitModel = fittype('exp2');
                    FitFun = fit(Xdata,Ydata,FitModel); %Построение модели
                    ResultTemp = feval(FitFun,Xdata); %Расчёт результатов на заданной сетке
                case 'Rational'
                    FitModel = fittype('rat23');
                    FitFun = fit(Xdata,Ydata,FitModel); %Построение модели
                    ResultTemp = feval(FitFun,Xdata); %Расчёт результатов на заданной сетке
                case 'Power'
                    FitModel = fittype('power2');
                    FitFun = fit(Xdata,Ydata,FitModel); %Построение модели
                    ResultTemp = feval(FitFun,Xdata); %Расчёт результатов на заданной сетке
            end
        catch %Если точек для аппроксимации недостаточно
            ResultTemp = zeros(length(Xdata),1);
        end
        ResultTemp = [PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),1),ResultTemp]; %Время для частичных сплайнов
        ResultTemp(:,3) = PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),3); %Концы фрагментов для частичных сплайнов
        PartsSignalApproxSpline{s} = [PartsSignalApproxSpline{s}; ResultTemp];
        SaveIndex = IndexPartsSignalApproxSpline{s}(i);
    end
    SaveIndex = 0; %Начальное значение индекса конца предыдущего фрагмента
    for i = 1:length(IndexPartsSignalApproxSpline{s}) %Выделение декрементов
        LengthFragment = length(PartsSignalApproxSpline{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),1)); %Длина текущего фрагмента
        NumbPeriodDecrement = floor((LengthFragment - 1)/PeriodDecrement); %Число периодов, соответствующее заданной частоте в данном фрагменте
        Decrement{i} = []; %Инициализация переменной
        if NumbPeriodDecrement ~= 0
            TempIndexStart = SaveIndex + 1; %Начало периода
            for j = 1:NumbPeriodDecrement
                TempIndexEnd = TempIndexStart + PeriodDecrement; %Конец периода
                Decrement{i}(j) = abs(PartsSignalApproxSpline{s}(TempIndexStart,2)/PartsSignalApproxSpline{s}(TempIndexEnd,2)); %Вычисление декремента затуханий
                TempIndexStart = TempIndexEnd;
            end
        end
        if isempty(Decrement{i})
            Decrement{i} = 0; %Зануление в случае короткого фрагмента
        end
        SaveIndex = IndexPartsSignalApproxSpline{s}(i);
    end 
    TableDecrementVisualize{s} = CreateTableVisualize(Decrement); %Cоздание таблицу для визуализации декрементов по пикам (1 - верх, 3 - низ)
end

%Нивелирование погрешности выбора
if length(IndexPartsExpSignalTemp{1}) <= length(IndexPartsExpSignalTemp{3})
    IndexPartsExpSignalFull = IndexPartsExpSignalTemp{1};
else
    IndexPartsExpSignalFull = IndexPartsExpSignalTemp{3};
end
%Отыскание левых границ
IndexPartsExpSignalFull = [PartsExpSignalTemp{1}(1,1);IndexPartsExpSignalFull];
k = 1; j = 1;
for i = 1:length(IndexPartsExpSignalFull) %Цикл по правым границам
    while 1
        if PartsExpSignalTemp{1}(j,1) > IndexPartsExpSignalFull(i) %Сравнение с текущей правой границей
            LeftExpIndexTemp(k,1) = PartsExpSignalTemp{1}(j,1); %Запись левой границы
            k = k + 1; 
            break
        end
        j = j + 1;
    end
end
LeftExpIndexTemp(1) = []; %Обнуляем первое приближение
IndexPartsExpSignalFull = sort([LeftExpIndexTemp;IndexPartsExpSignalFull]); %Левая + правая граница
IndexPartsExpSignalFull(end + 1) = PartsExpSignalTemp{1}(end,1); %Добавляем правую границу последнего фрагмента
%Корректируем угловые значения
IndexPartsExpSignalFull(end + 1) = length(Signal); %Правая граница ускорений
IndexPartsExpSignalFull = [1;IndexPartsExpSignalFull]; %Левая граница ускорений
    %Собирание нейтральных фрагментов
k = 1;
for i = 1:2:length(IndexPartsExpSignalFull) - 1 %Цикл по нечетным номерам
    for j = 1:length(Signal)
        if j >= IndexPartsExpSignalFull(i) && j < IndexPartsExpSignalFull(i + 1) %Проверка попадания в отрезок
            PartsExpSignal{2}(k,:) = [j Signal(j) 0]; 
            if j == IndexPartsExpSignalFull(i + 1)-1 %Для правой границы
                PartsExpSignal{2}(k,3) = 1; %Идентификатор конца фрагмента
            end
            k = k + 1;
        end
    end
end
    %Собирание убывающих фрагментов
k = 1;
for i = 2:2:length(IndexPartsExpSignalFull) - 2 %Цикл по четным номерам
    for j = 1:length(Signal)
        if j >= IndexPartsExpSignalFull(i) && j <= IndexPartsExpSignalFull(i + 1) %Проверка попадания в отрезок
            PartsExpSignal{1}(k,:) = [j Signal(j) 0];
            if j == IndexPartsExpSignalFull(i + 1) %Для правой границы
                PartsExpSignal{1}(k,3) = 1; %Идентификатор конца фрагмента
            end
            k = k + 1; %Приращение счетчика
        end
    end
end
    %Получение индексов фрагментов для каждого уровня
IndexPartsExpSignal{1} = find(PartsExpSignal{1}(:,3) == 1); %Отыскание концов убывающих фрагментов
IndexPartsExpSignal{2} = find(PartsExpSignal{2}(:,3) == 1); %Отысканые концов нулевых фрагментов
end

function TableVisualize = CreateTableVisualize(Signal) %Создание единой таблицы для сравнения  
    if ~iscell(Signal), error('Неверный формат ввода'), end %Провера ячеистой структуры
    RowsTable = length(Signal); %Число пиков в сигнале
    MaxLength = 0; %Начальное значение второго измерения
    for i = 1:RowsTable
        if length(Signal{i}) > MaxLength %Поиск максимальной длины фрагмента
            MaxLength =  length(Signal{i});
        end
    end
    ColsTable = MaxLength;
    TableVisualize = zeros(RowsTable,ColsTable); %Выделение памяти под таблицу для визуализции
    %Занесение данных в таблицу
    for i = 1:RowsTable %По каждому пику
        for j = 1:length(Signal{i})
            TableVisualize(i,j) = Signal{i}(j); %Поэлементная запись сигнала в строку
        end
    end
end