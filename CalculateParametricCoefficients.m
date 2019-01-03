function Result = CalculateParametricCoefficients(Signals, Param, Option)
% Расчет коэффициентов подобия, угловых коэффициентов и дистанции рассеяния
% для заданного набора сигналов
% Param:
%       == {'Angle', 
%           'Sim',
%           'Distance',
%           'CoeffScatter'}
% Option:
%       == {'Приведение к нулю',
%           'Линейная корректировка',
%           'Нормировка'

% Коррекция типа параметров
if ~iscell(Param)
    tParam = Param; Param = {};
    Param{1} = tParam;
end 

nParam = length(Param); % Число параметров
% Получение флагов расчета
isParam.Angle = FindEntry(Param, 'Angle'); 
isParam.Sim = FindEntry(Param, 'Sim');
isParam.Distance = FindEntry(Param, 'Distance');
isParam.CoeffScatter = FindEntry(Param, 'CoeffScatter');

% Обработка исключения
if ~(isParam.Angle || isParam.Sim || isParam.Distance || isParam.CoeffScatter)
    error('Неверный параметр расчета');
end

nSignals = length(Signals); % Число сигналов

% Выделение памяти под массивы
if isParam.Angle, DataAngleCoeff = zeros(nSignals); end % Углы
if isParam.Sim, DataSimilarityCoeff = zeros(nSignals); end % Подобия    
if isParam.Distance, DistanceScatter = zeros(nSignals); end % Дистанции
if isParam.CoeffScatter, CoeffScatter = zeros(nSignals); end % Коэффициент амплитуд рассеяния

% Вычислиение массивов
for i = 1:nSignals
    Signals = NormalizeSignals(Signals, i, Option); % Нормировка сигналов к базовому
    for j = 1:nSignals
        LinearRegressionCoeffs = polyfit(Signals{i}, Signals{j}, 1); % Коэффициенты линейной регресии
        if isParam.Distance || isParam.CoeffScatter
            LinearRegressionFun = polyval(LinearRegressionCoeffs, Signals{i}); % Вычисление значений функции регрессиий
        end
        if isParam.Distance || isParam.CoeffScatter % Для поверхности дистанций рассеяния
            alpha = atan(LinearRegressionCoeffs(1)); % Угол наклона прямой
            DistanceScatter(i, j) = 1 / length(Signals{j}) *  sum(abs(Signals{j} - LinearRegressionFun)) * cos(alpha); % Дистанция рассеяния
        end
        if isParam.CoeffScatter % Для коэффициента рассеяния                        
            tShowSignal = sum(abs(Signals{j} - mean(Signals{j})));
            tBaseSignal = sum(abs(Signals{i} - mean(Signals{i})));
            CoeffScatter(i, j) = DistanceScatter(i, j) * length(Signals{j}) / sqrt(tBaseSignal ^ 2 + tShowSignal ^ 2); % Коэффициент рассеяния
        end
        if isParam.Sim || isParam.Angle % 'Sim' || 'Angle'
            DataAngleCoeff(i, j) = LinearRegressionCoeffs(1); % Запись углового коэффициента
        end
    end
end

if isParam.Sim % Коэффициенты подобия
    for i = 1:nSignals
        for j = 1:nSignals
            DataSimilarityCoeff(i, j) = sqrt(DataAngleCoeff(i, j) * DataAngleCoeff(j, i));
        end
    end
end

% Передача массива результатов
itr = 1;
for i = 1:length(Param)
    switch Param{i}
        case 'Angle'
            Result{itr} = DataAngleCoeff;
        case 'Sim'
            Result{itr} = DataSimilarityCoeff;
        case 'Distance'
            Result{itr} = DistanceScatter;
        case 'CoeffScatter'
            Result{itr} = CoeffScatter;
    end
    itr = itr + 1; %  Приращение счетчика
end
if nParam == 1
    Result = Result{1}; % Вывод одного результата
end

end

function isEntry = FindEntry(ArrayString, StringCompare)
% Проверка первого вхождения строки в массив

isEntry = false;
for i = 1:size(ArrayString, 1)
    for j = 1:size(ArrayString, 2)
        if strcmp(ArrayString{i, j}, StringCompare)
           isEntry = true;
           break;
        end   
    end
end

end

