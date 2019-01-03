function [RegressionTable, Title] = CalculateRegression(InputAccel, Accel, MonotoneAccel, ExpAccel, FrequencyInputAccel, FrequencyAccel, FrequencyMonotoneAccel, FrequencyExpAccel, RegressionArg, CurrentLevels)
%Создание таблицы регрессионных коэффициентов по заданным аргументам.

ComplexTableSignal = []; Title.Rows = {}; Title.Cols = {}; %Таблица сигналов и заголовков по всем уровням
ParamsNumb.Full = 5; %Число параметров для табличного анализа
ParamsNumb.Vec = 2; %Число параметров для векторного анализа

%Составление массива сигналов по маске
try
for i = 1:length(RegressionArg)
    switch RegressionArg{i}
        case 'НУ' %Ускорения исходные
            ComplexTableSignal = [ComplexTableSignal, InputAccel]; %Добавление ускорений по уровням
            Title.Rows = [Title.Rows, CreateTitleNameByID(0, RegressionArg{i})]; %Заголовки по строкам
        case 'У' %Ускорения по уровням
            for j = 1:size(MonotoneAccel{1},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyAccel, FrequencyInputAccel, Accel(:,j), 1, 0)]; %Аппроксимация спектров на сетке ускорений
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %Заголовки по строкам
        case 'УВ' %Ускорения возрастающие
            for j = 1:size(MonotoneAccel{1},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyMonotoneAccel{1}, FrequencyInputAccel, MonotoneAccel{1}(:,j), 1, 0)]; %Аппроксимация спектров на сетке ускорений
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %Заголовки по строкам
        case 'УН' %Ускорения нейтральные
            for j = 1:size(MonotoneAccel{2},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyMonotoneAccel{2}, FrequencyInputAccel, MonotoneAccel{2}(:,j), 1, 0)]; %Аппроксимация спектров на сетке ускорений
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %Заголовки по строкам
        case 'УУ' %Ускорения убывающие
            for j = 1:size(MonotoneAccel{3},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyMonotoneAccel{3}, FrequencyInputAccel, MonotoneAccel{3}(:,j), 1, 0)]; %Аппроксимация спектров на сетке ускорений
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %Заголовки по строкам
        case 'УЗ'
            for j = 1:2
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyExpAccel, FrequencyInputAccel, ExpAccel(:,j), 1, 0)]; %Аппроксимация спектров на сетке ускорений
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID([-1, 0], RegressionArg{i})]; %Заголовки по строкам
    end
end
catch %Недостаточное число точек
    for s = 1:ParamsNumb.Full + ParamsNumb.Vec, RegressionTable{s} = 0; end
    Title.Rows = 'Empty'; Title.Cols = 'Empty';
    return
end
% Фильтрация пустых сигналов
for i = size(ComplexTableSignal,2):-1:1
    if ~nnz(ComplexTableSignal(:, i))
        ComplexTableSignal(:,i) = []; % Удаление нулевого столбца
        Title.Rows(i) = []; % Удаление заголовка
    end
end
Title.Cols = Title.Rows; %Placeholder
ColsNumb = size(ComplexTableSignal, 2); %Число колонок

%Инициализация полей структуры
    %Табличный
for s = 1:ParamsNumb.Full
    RegressionTable{s} = zeros(ColsNumb); %Таблица [угловых коэффициентов, дистанций рассеяния, длин кривых, коэффициенты амплитуд рассеяния, коэффициенты подобия]
end
    %Векторный
for s = ParamsNumb.Full + 1:ParamsNumb.Full + ParamsNumb.Vec
    RegressionTable{s} = zeros(ColsNumb, 1); %Таблица [амплитуда, максимальная частота]
end
%Вычисление регресионных параметров по сигналам
for i = 1:ColsNumb 
    BaseSignal = ComplexTableSignal(:, i); %Основной сигнал
    %Вычисление параметров регрессии
    [MaxBaseSignal MaxBaseSignalInd] = max(BaseSignal);  %Максимумы рассеяния
    FreqMaxBaseSignal = FrequencyInputAccel(MaxBaseSignalInd);  %Частоты
    %Запись результатов расчёта
    RegressionTable{5}(i) = MaxBaseSignal; %Амплитуда сигнала
    RegressionTable{6}(i) = FreqMaxBaseSignal; %Частота сигнала
    for j = 1:ColsNumb
        ShowSignal = ComplexTableSignal(:, j); %Сигнал для сравнения
        %Построение линейной регрессии
        LinearRegressionCoeffs = polyfit(BaseSignal, ShowSignal, 1); % Коэффициенты для линейной регрессии
        LinearRegressionFun = polyval(LinearRegressionCoeffs, BaseSignal); % Вычисление значений линейной регрессии
        alpha = atan(LinearRegressionCoeffs(1)); % Угол наклона прямой
        % Расчет дистанций рассения
        DistanceScatter = 1 / length(ShowSignal) * sum(abs(ShowSignal - LinearRegressionFun)) * cos(alpha); % Cуммарная
        tShowSignal = sum(abs(ShowSignal - mean(ShowSignal)));
        tBaseSignal = sum(abs(BaseSignal - mean(BaseSignal)));
        CoeffScatter = DistanceScatter * length(ShowSignal) / sqrt(tBaseSignal ^ 2 + tShowSignal ^ 2); % Коэффициент рассеяния
        % Длина кривой
        LengthCurve = 0; %Инициализация длины кривой
        for p = 1:length(BaseSignal) - 1
            LengthCurve = LengthCurve + sqrt((BaseSignal(p + 1) - BaseSignal(p)) ^ 2 + (ShowSignal(p + 1) - ShowSignal(p)) ^ 2); %Длина кривой
        end
        %Запись результатов расчёта
        RegressionTable{1}(i, j) = LinearRegressionCoeffs(1); % Угловой коэффициент
        RegressionTable{2}(i, j) = DistanceScatter; % Дистанция рассеяния суммарная
        RegressionTable{3}(i, j) = LengthCurve; % Длина рассеяния
        RegressionTable{4}(i, j) = CoeffScatter; % Коэффициент амлитуд рассеяния
    end
end
% Вычисление коэффициентов подобия
for i = 1:ColsNumb
    for j = 1:ColsNumb
        RegressionTable{5}(i, j) = sqrt(RegressionTable{1}(i, j) * RegressionTable{1}(j, i));
    end
end

end

function Title = CreateTitleNameByID(Levels, ID)
    % Создание заголовка простой конкатенацией номера уровня и идентификатора
    for i = 1:length(Levels)
        if Levels(i) <= 0
            Title{i} = strcat(ID, num2str(Levels(i))); % ID-N
        else
            Title{i} = strcat(ID, '+', num2str(Levels(i))); % ID+N
        end
    end

end

