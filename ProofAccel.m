function Result = ProofAccel(FileNameDisplacement,... %Имя файла c перемещениями
                                FileNameAccel,... %Имя файла c ускорениями
                                StartReadNumbDisplacement,... %Номер отсчётной строки для перемещений
                                StartReadNumbAccel,... %Номер отсчётной строки для ускорений
                                LevelsStep,...%Высота уровней
                                Accuracy,... %Точность аппроксимации
                                CutProcent,... %Процент усечения фрагментов
                                CorrectDisplacement,... %Корректировка линейного дрейфа оборудования
                                CutOffFrequency,... %Частота среза, Гц
                                CorrectLengthMode,... %Режим приведения по длине 
                                AccuracyExp,... %Точность выделения экспонециального затухания
                                LimExpAccelLevel,... %Предельное значение диапазона ускорений 
                                FreqDecrement,... %Частота выделения декремента затуханий
                                DepthGluing,... %Глубина склейки                           
                                ModelApprox,... %Модель выделения декремента затуханий
                                OverlapFactor,... %Коэффициент перекрытия границ уровней
                                AccuracySpectrum,... %Точность аппроксимации спектров
                                NormalizeMode) %Режим нормировки склеек
                            
%% +==================== Информация о программе ==========================+

%   Автор: П.А. Лакиза.
%   Версия: 3.9
%   Изменения:   
%   - Дополнен режим построения линейной регрессии выбранных сигналов
%   - Убраны режимы нахождения ковариации сигналов по уровням
%   - Добавлена возможность построение поверхности коэффициентов подобия
%   для выбранных сигналов
%   - Добавлен режим автоматического выбора пределов построения графиков
%  Дата: 04.11.2018

%% +========================= Служебный блок =============================+

TestMode = 0;
if TestMode %Режим отладки
    %Очищаем рабочую область
    clc; clear variables; close all;
    %Добавляем рабочие директории
    addpath('Signals', 'Signals/Иммитационная модель'); %Исходные и выходные данные
    addpath('Export_fig'); %Библиотека сохранения изображений
    
    %% +========================= Исходные данные ============================+    
    
    FileNameDisplacement = 'Модель  ЛЭП запись1-1.txt'; %Имя файла c перемещениями
    FileNameAccel = 'Модель  ЛЭП запись1-1-Ускорения.txt'; %Имя файла c ускорениями
    StartReadNumbDisplacement = 12; %Номер отсчётной строки для перемещений
    StartReadNumbAccel = 12; %Номер отсчётной строки для ускорений
    SaveMode = false; %Режим сохранения файлов
    
    LevelsStep = 14; %Ширина уровня
    Accuracy = 1e-7; %Точность аппроксимации
    ShowNumb = 2; %Номер линий уровня для отображения
    CutProcent = 0.2; %Процент усечения фрагментов
    CorrectDisplacement = true; %Корректировка линейного дрейфа оборудования
    CutOffFrequency = 0.1; %Частота среза, Гц
    CorrectLengthMode = 'Input'; %Режим приведения по длине == (No, Maximum, Input)
    AccuracyExp = 1e-7; %Точность выделения экспонециального затухания
    LimExpAccelLevel = 0.13; %Предельное значение диапазона ускорений
    FreqDecrement = 5; %Частота выделения декремента затуханий
    DepthGluing = 0; %Глубина склейки
    ModelApprox = 'B-Spline'; %Модель выделения декремента затуханий
    DeltaLevelsStepProcent = 0.1; %Смещение границы уровней в долях
    AccuracySpectrum = 0.95; %Точность аппроксимации спектров
    NormalizeMode = 0; %Режим нормировки склеек
    OverlapFactor = 0.2; %Коэффициент перекрытия уровней
    
end

%% +======================= Считывание данных ============================+

ReadMode = 'Complex'; %Режим считывания данных с перемещений и ускорений
if isempty(FileNameDisplacement) 
    ReadMode = 'Accel'; %Режим считавания данных с ускорений
end

switch ReadMode %Считывание данных в зависимости от режима
    case 'Complex'
        %Считывание файла перемещений
        [InputDataDisplacement TechnicalDataDisplacement Displacement] = ReadInput(FileNameDisplacement,StartReadNumbDisplacement);
        %Считывание файла ускорений
        [InputDataAccel TechnicalDataAccel Accel] = ReadInput(FileNameAccel,StartReadNumbAccel);
        if length(Accel) ~= length(Displacement) %Проверка совпадаения длин записей
            error('Длины записи сигнала перемещений и ускорений не совпадают');
        end
    case 'Accel'
        %Считывание файла ускорений
        [InputDataAccel TechnicalDataAccel Accel] = ReadInput(FileNameAccel,StartReadNumbAccel);
        [Accel,~] = PeakFilter(Accel, []); %Удаление выбросов ускорений
end
Time = (1:length(Accel))'; %Массив времени
SampleRate = str2num(TechnicalDataAccel{end - 2}); %Частота дискретизации
clear InputDataAccel InputDataDisplacement; %Очищаем промежуточные переменные

%% +============================ Расчёт ==================================+

switch ReadMode %Работа с данными в зависимости от режима
    case 'Complex'
        Accel = Accel - Accel(1); %Приведение ускорений к нулевой линии
        Displacement = Displacement - Displacement(1); %Приведение перемещений к нулевой линии
    case 'Accel'
        %Считывание файла ускорений
        Accel = Accel - Accel(1); %Приведение ускорений к нулевой линии
        Displacement = DoubleIntegral(Time, Accel, CutOffFrequency, SampleRate); %Получение перемещений двойным интегрированием ускорений
end  
if CorrectDisplacement %Проверка режима коррекции линейного дрейфа
    Displacement = LineCorrect(Time, Displacement); %Отсечение низкочастотной части сигнала перемещений
end
    %Аппроксимация функции перемещений
[DisplacementApprox DisplacementApproxDerivative] = ApproxSpline(Time, Time, Displacement,Accuracy,1); %Аппроксимация B-сплайнами
    %Выделение уровней
LineLevels = CreateLevels(DisplacementApprox, LevelsStep, OverlapFactor); 
LevelsNumb = size(LineLevels, 1); %Число уровней сигнала
[PartsDisplacement IndexPartsDisplacement] = AssignLevels(Time, Displacement, LineLevels); %Выделение частей перемещений по уровнями
    %Фрагментация временного сигнала с датчиков ускорений
for i = 1:LevelsNumb
    PartsAccel{i} = zeros(size(PartsDisplacement{i})); %Выделение памети под фрагменты ускорений
    for j = 1:size(PartsDisplacement{i},1) %Массив по числу фрагментов 
        %Запись фрагментов ускорений по номерам фрагментов перемещений
        PartsAccel{i}(j,1) = PartsDisplacement{i}(j,1);
        PartsAccel{i}(j,2) = Accel(PartsAccel{i}(j,1));
        PartsAccel{i}(j,3) = PartsDisplacement{i}(j,3);      
    end
end
    %Фрагментация сигнала с датчика ускорений по экспонециальному затуханию
[PartsAccelApproxSpline,TableDecrementVisualize,PartsExpAccel,IndexPartsExpAccel,LimitsExpAccel] = FindExpDecrease(Accel,LimExpAccelLevel,AccuracyExp,FreqDecrement,SampleRate,ModelApprox);

    %Отсечение коротких фрагментов и нахождение производных для ускорений
[FixPartsAccel,PartsAccelDerivative, IndexPartsAccel,...
    ~, ~] = FixNormalizeDerivative(PartsAccel, IndexPartsDisplacement, CutProcent, NormalizeMode);
    %Отсечение коротких фрагментов и нахождение производных для пермещений
[FixPartsDisplacement PartsDisplacementDerivative IndexPartsDisplacement,...
    ~, ~] = FixNormalizeDerivative(PartsDisplacement, IndexPartsDisplacement, CutProcent, NormalizeMode);  
    %Отсечение коротких фрагментов для экспонециального затухания с ускорений
[FixPartsExpAccel, PartsExpAccelDerivative, IndexPartsExpAccel,...
    ~,~] = FixNormalizeDerivative(PartsExpAccel, IndexPartsExpAccel, CutProcent, NormalizeMode);  

    %Выделение одномонотонных фрагментов по перемещениям
[PartsMonotoneAccel, IndexMonotoneAccel] = ConstructMonotoneLevels(FixPartsAccel, FixPartsDisplacement, LineLevels);
    %Отсечение коротких фрагментов и нахождение производных для сигнала
for s = 1:length(PartsMonotoneAccel) %Цикл по Increase, Neutral, Decrease
   [FixPartsMonotoneAccel{s},PartsMonotoneAccelDerivative{s},IndexPartsMonotoneAccel{s}...
       ,~,~] = FixNormalizeDerivative(PartsMonotoneAccel{s}, IndexMonotoneAccel{s}, CutProcent, NormalizeMode); %Усечение и нормализация
end

switch CorrectLengthMode %Режим приведения фрагментов к длине
    case 'Maximum' %К максимальной
        MaxLength = 0; %Начальное оценочное значение
        for i = 1:LevelsNumb %Перемещения и ускорения
            if length(FixPartsAccel{i}) > MaxLength %Нахождения максимума среди ускорений
                MaxLength = length(FixPartsAccel{i});
            end
            if length(FixPartsDisplacement{i}) > MaxLength
                MaxLength = length(FixPartsDisplacement{i}); %Нахождения максимума среди перемещений
            end           
            for j = 1:length(PartsMonotoneAccel) %Цикл по монотонным фрагментам
                if length(PartsMonotoneAccel{j}{i}) > MaxLength
                    MaxLength = length(PartsMonotoneAccel{j}{i}); %Нахождения максимума среди [возрастающих; нейтральных; убывающих] фрагментов
                end
            end
        end
        LengthCorrect = MaxLength; %Общий масимум
        clear MaxLength;
    case 'Input'
        LengthCorrect = length(Accel); %Длина ускорений
    case 'No'
        LengthCorrect = 0;   
end
    %Склейка фрагментов для каждого уровня ускорений
[PartsAccelGlued, FailAccelGlued] = OptimalGluing(IndexPartsAccel,FixPartsAccel,PartsAccelDerivative,0.01,DepthGluing); %Ускорения

[FixPartsExpAccelTurn, PartsExpAccelDerivativeTurn] = OverTurnFragments(FixPartsExpAccel,IndexPartsExpAccel,PartsExpAccelDerivative); %Поворот затухания
[PartsExpAccelGlued, FailExpAccelGlued] = OptimalGluing(IndexPartsExpAccel,FixPartsExpAccelTurn,PartsExpAccelDerivativeTurn,0.01,DepthGluing); %Экспонециальное затухание
    %Склейка фрагментов монотонных сигналов
for s = 1:length(FixPartsMonotoneAccel) %Цикл по Increase, Neutral, Decrease
    [PartsMonotoneAccelGlued{s}, FailPartsMonotoneAccelGlued{s}] = OptimalGluing(IndexPartsMonotoneAccel{s}, FixPartsMonotoneAccel{s}, PartsMonotoneAccelDerivative{s}, 0.01, DepthGluing);
end
    %Окончательное приведение фрагментов по длине
PartsAccelGlued = CorrectLength(PartsAccelGlued, LengthCorrect, 0, DepthGluing); 
PartsExpAccelGlued = CorrectLength(PartsExpAccelGlued, LengthCorrect, 0, DepthGluing);
for s = 1:length(PartsMonotoneAccelGlued) %Цикл по Increase, Neutral, Decrease
    PartsMonotoneAccelGlued{s} = CorrectLength(PartsMonotoneAccelGlued{s}, LengthCorrect, 0, DepthGluing);
end

    %Преобразование Фурье для склееных уровней сигнала
[SpectrumAccelGluedVisualize, FrequencyAccelGlued] = FindSpectrum(PartsAccelGlued, SampleRate, 0, 'Welch', AccuracySpectrum); %Спектр уровней
for s = 1:length(PartsMonotoneAccelGlued) %Цикл по Increase, Neutral, Decrease
    [SpectrumMonotoneAccelGluedVisualize{s}, FrequencyMonotoneAccelGlued{s}] = FindSpectrum(PartsMonotoneAccelGlued{s}, SampleRate, 0, 'Welch', AccuracySpectrum); %Спектр монотонных фрагментов
end
[SpectrumExpAccelGluedVisualize, FrequencyExpAccelGlued] = FindSpectrum(PartsExpAccelGlued, SampleRate, 0, 'Welch', AccuracySpectrum); %Спектр экспонецильно затухающих и нулевых фрагментов

    %Передача данных в вызывающую программу
Result{1} = Accel; %Ускорения
Result{2} = Displacement; %Перемещения
Result{3} = PartsDisplacement; %Фрагментированные перемещения
Result{4} = PartsAccelGlued; %Склееные по уровням ускорения
Result{5} = FrequencyAccelGlued; %Частоты склееных ускорений
Result{6} = SpectrumAccelGluedVisualize; %Поверхность спектра ускорений
Result{7} = PartsMonotoneAccelGlued; %Склейка монотонных фрагментов
Result{8} = FrequencyMonotoneAccelGlued; %Частоты скленных монотонных фрагментов
Result{9} = SpectrumMonotoneAccelGluedVisualize; %Поверхность спектра монотонных фрагментов
Result{10} = Time; %Время
Result{11} = LevelsNumb; %Число уровней
Result{12} = LineLevels; %Линии уровней
Result{13} = DisplacementApprox; %Аппроксимированные перемещения
Result{14} = DisplacementApproxDerivative; %Аппроксимированные производные от перемещений
Result{15} = PartsExpAccel; %Экспонециально затухающие фрагменты сигнала
Result{16} = PartsExpAccelGlued; %Склейка экспонециально затухающих фрагментов сигнала  
Result{17} = LimitsExpAccel; %Лимитирующие пределы затухания
Result{18} = SpectrumExpAccelGluedVisualize; %Поверхность спектра экспонециально затухающего сигнала 
Result{19} = FrequencyExpAccelGlued; %Частоты для поверхности спектра экспонециального затухающего сигнала
Result{20} = TableDecrementVisualize; %Таблица декрементов затухания по пикам
Result{21} = PartsAccelApproxSpline; %Аппроксимирующие сплайны для каждого пика

% return;
%% Отладка

% TimeInput = FrequencyExpAccelGlued;
% TimeInterpolate = FrequencyAccelGlued;
% Signal = SpectrumExpAccelGluedVisualize(:,1);
% [SignalApprox,~] = ApproxSpline(TimeInput, TimeInterpolate, Signal, 1, 0); %Вычисление значений функции для заданного дискретного набора точек
% plot(TimeInput, Signal);
% grid on; hold on;
% plot(TimeInterpolate, SignalApprox);
% 
% figure
% grid on;
% plot(Accel);
% 
% figure %Перемещения
% hold on; %Построение графиков в одних осях
% plot(Time, Displacement); %Построение графика сигнала
% grid on; %Отображение масштабной сетки
% title('Временной сигнал перемещений'); %Название графика
% xlabel('t'); ylabel('r'); %Название осей
% for i = 1:length(LineLevels) %Построение горизонтальных линий
%     for j = 1:2
%         X = [0 length(Signal)]; Y = LineLevels(i,j);
%         if ~mod(LineLevels(i,3),2)
%             plot(X,[Y Y],'--','Color','red'); 
%         else
%             plot(X,[Y Y],':','Color','black');            
%         end
%         
%     end
% end
% %Подпись уровней
% for i = 1:length(LineLevels)
%     text(X(2),mean(LineLevels(i,1:2)),num2str(LineLevels(i,3)),'FontSize',12); %Номера уровней
% end
% 
% figure %Фрагменты перемещений
% plot(PartsDisplacement{ShowNumb}(:,1),PartsDisplacement{ShowNumb}(:,2),'.'); %Построение графика
% grid on; %Отображение масштабной сетки
% title(['Фрагментированный по уровню №' num2str(ShowNumb) ' график перемещений']); %Название графика
% xlabel('t'); ylabel('r'); %Название осей
% 
% 
% figure %Склейка ускорений
% plot(PartsAccelGlued{ShowNumb}(:,2)); %Построение графика
% grid on; %Отображение масштабной сетки
% DotGluedShow = find(PartsAccelGlued{ShowNumb}(:,3) == 1);
% DotGluedShow(end) = []; %Обнудением последнего значения (конец сигнала
% hold on
% plot(DotGluedShow,PartsAccelGlued{ShowNumb}(DotGluedShow,2),'*','Color','Red');
% plot(DotGluedShow+1,PartsAccelGlued{ShowNumb}(DotGluedShow+1,2),'*','Color','black');
% title(['Склееный по уровню №' num2str(ShowNumb) ' график ускоерний']); %Название графика
% xlabel('t'); ylabel('r"'); %Название осей
% 
% figure %Построение экспонециально убывающих и нулевых фрагментов
% hold on; grid on
% plot(PartsExpAccel{1}(:,1),PartsExpAccel{1}(:,2),'*','Color','blue');
% plot(PartsExpAccel{2}(:,1),PartsExpAccel{2}(:,2),'*','Color','red');
% plot([0 length(Accel)],[LimitsExpAccel(1) LimitsExpAccel(1)],'--','Color','black','LineWidth',1.5);
% plot([0 length(Accel)],[LimitsExpAccel(2) LimitsExpAccel(2)],'--','Color','black','LineWidth',1.5);
% legend('Убывающие фрагменты','Нулевые фрагменты','Лимитирующая граница');
% figure
% plot(PartsExpAccelGlued{1}(:,2)); %Убывающие склееные
% DotGluedShow = find(PartsExpAccelGlued{1}(:,3) == 1);
% DotGluedShow(end) = []; %Обнудением последнего значения (конец сигнала
% hold on
% plot(DotGluedShow,PartsExpAccelGlued{1}(DotGluedShow,2),'*');
% plot(DotGluedShow+1,PartsExpAccelGlued{1}(DotGluedShow+1,2),'*','Color','black');
% figure
% plot(PartsExpAccelGlued{2}(:,2)); %Нулевые склееные

end