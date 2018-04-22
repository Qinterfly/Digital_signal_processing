function [SpectrumSignalVisualize Frequency] = FindSpectrum(PartsSignalGlued, SampleRate, LengthFFT, Mode, Accuracy) 
%Выделение спектра и формирование массива для построения логорифмической поверхности поверхности

%Проверка валидности исходных данных
if ~iscell(PartsSignalGlued)
    error('Неверный формат данных');
end
clear Temp; %Очистка промежуточной переменной

LevelsNumb = length(PartsSignalGlued); %Находим число уровней
if LengthFFT == 0 %Поиск минимально возможной длины разложения
    %Преобразование Фурье для склееных уровней сигнала
    MinNFFT = 1e9; %Начальное оценочное значение
    for i = 1:LevelsNumb %Цикл по всем уровням
        L = size(PartsSignalGlued{i},1); %Длина уровня сигнала
        NFFT = 2^nextpow2(L); %Длина БПФ
        if NFFT < MinNFFT %Поиск минимальной длины БПФ в массиве
            MinNFFT = NFFT;
        end
    end
else
    MinNFFT = (LengthFFT - 1)*2; %Разложение в ряд Фурье по заданной длине
end
switch Mode
    case 'FFT' %ДПФ
        Frequency = SampleRate*(1:MinNFFT/2)/MinNFFT/100; %Физические частоты сигнала
        for i = 1:LevelsNumb %Цикл по всем уровням
            Y = fft(PartsSignalGlued{i}(:,2),MinNFFT); %Осуществляем БПФ
            Y = Y(1:MinNFFT/2); %Отсекаем симметричную часть
            P = abs(Y); %Находим амплитуду
            SpectrumSignal{i} = P; %Массив амплитуд спектра
        end
    case 'Welch' %Спектральная плотность мощности по Уэлчу
        for i = 1:LevelsNumb %Цикл по всем уровням
            [SpectrumSignal{i}, Frequency] = pwelch(PartsSignalGlued{i}(:,2), MinNFFT/2, MinNFFT/4, MinNFFT, 1/(SampleRate*1e-6));
        end
end
%Аппроксимирование спектра
for i = 1:LevelsNumb
    [SpectrumSignal{i},~] = ApproxSpline(Frequency, Frequency, SpectrumSignal{i}, Accuracy, 0);
end
%Создание матрицы для визуализации
SpectrumSignalVisualize = zeros(LevelsNumb, MinNFFT/2); %Выделяем память для таблицы визуализации
for i = 1:LevelsNumb
    for j = 1:length(SpectrumSignal{i})
        SpectrumSignalVisualize(i,j) = SpectrumSignal{i}(j); %Записываем показания по каждому уровню
    end
end
SpectrumSignalVisualize = SpectrumSignalVisualize'; %Транспонируем таблицу

end

