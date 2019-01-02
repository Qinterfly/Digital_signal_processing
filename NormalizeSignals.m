function Signals = NormalizeSignals(Signals, Option)
% Нормировка сигналов по параметру
% option = 
%       'Приведение к нулю'
%       'Линейная корректировка'
%       'Нормировка'

if ~iscell(Signals) % Проверка структуры входных данных
    tSignals = Signals; Signals = [];
    Signals{1} = tSignals; % Перзапись содержимого
end

nSignals = length(Signals); % Число выбранных сигналов
MinLengthSignals = Inf; % Начальное приближение длин сигналов
for i = 1:nSignals % Запись первой пары сигналов
    if length(Signals{i}) < MinLengthSignals % Запись минимальной длины сигнала
        MinLengthSignals = length(Signals{i});
    end
end

% Поиск максимума + срез по длине
for i = 1:nSignals
    Signals{i} = Signals{i}(1:MinLengthSignals); % Срез сигналов по длине наименьшего
    if strcmp(Option, 'Приведение к нулю') || strcmp(Option, 'Нормировка')
        Signals{i} = Signals{i} - mean(Signals{i}); % Вычитание среднего
    end
    if strcmp(Option, 'Линейная корректировка')
        Signals{i} = LineCorrect((1:length(Signals{i}))', Signals{i});
    end
end

% Нормировка к угловому коэффициенту по базовому сигналу
if strcmp(Option, 'Нормировка') 
    for i = 2:nSignals % Нормировка к базовому сигналу (первому выбранному)
        LinearRegressionCoeffs = polyfit(Signals{1}, Signals{i}, 1); % Коэффициенты линейной регресии
        Signals{i} = Signals{i} / abs(LinearRegressionCoeffs(1)); % К угловому коэффциенту
    end
end

end

