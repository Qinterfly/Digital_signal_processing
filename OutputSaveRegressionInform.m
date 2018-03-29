function OutputSaveRegressionInform(RegressionParams, Title, FileName, Path, InputFileName, TechnicalData)
%Сохранение результатов спектрального расчёта в виде таблиц в .xls формате
%одним вызовом COM сервера Excel

%Запись пути сохранения
Path = strcat(Path,'\Результаты\',InputFileName);
if ~isdir(Path) %Создание директории для данного сигнала
   mkdir(Path);  
end
FullFileName = strcat(Path,'/',FileName,'.xls'); %Полное имя файла
if exist(FullFileName) == 2 %Проверка существования файла
   delete(FullFileName); %Удаление
end
SpreadSheet = 'Лист1'; %Название рабочей страницы страницы
%Создание заголовок колонок
k = 1; %Начальное значение итератора
for i = double('A'):double('Z')
    XlRangeBase{k} = char(i); % A - Z алфавит
    k = k + 1; %Приращение итератора
end
TempLen = length(XlRangeBase);
    %Вариации названий колонок
for i = 1:TempLen
   for j = 1:TempLen
       XlRangeBase{end + 1} = strcat(XlRangeBase{i}, XlRangeBase{j}); %AA - ZZ вариации
   end
end
%Подготовка параметров регрессии к записи
ElementNumb = length(RegressionParams{1,1}); %Число элементов в структуре
LevelsNumb = size(RegressionParams); %Число уровней по строкам и столбцам 
for i = 1:LevelsNumb(1)    
    for j = 1:LevelsNumb(2)
        for s = 1:ElementNumb
            OriginalData = RegressionParams{i,j}{s}; %Неформатированная строка с данными
            switch s
                case 1 %Параметры прямой
                    if OriginalData(2) < 0 %Знак коэффициента
                        Sign = '';
                    else
                        Sign = '+';
                    end
                    FormatData = [num2str(OriginalData(1)) 'x' Sign num2str(OriginalData(2))];
                case 2
                    FormatData = num2str(OriginalData); %Дистанция рассеяния
                case 3
                    FormatData = [num2str(OriginalData(1),'%.2e') '/' num2str(OriginalData(2),'%.2e')...
                        ' (' num2str(OriginalData(3),'%.2f') '/' num2str(OriginalData(4),'%.2f') ' Гц)']; %Соотношение максимумов
                case 4
                    FormatData = num2str(OriginalData, '%.2e'); %Длина кривой рассеяния
            end
            RegressionParams{i,j}{s} = FormatData; %Запись форматированных данных
        end
    end
end

%Запись технических сведений
for i = 1:length(TechnicalData)
    ResultTable{i,1} = (TechnicalData{i});
end
ResultTable{i + 1,1} = ''; %Отступ перед основными данными
BeginTitleInd = i + 2; %Индекс начала основных данных
%Запись заголовков 
ShiftCol = 4; ShiftRow = ElementNumb + 1; %Величины смещения строк и столбцов

for i = 1:LevelsNumb(1) %По строкам
    ResultTable{BeginTitleInd + 1 + (i-1)*ShiftRow, 1} = Title{2}(i);
end
for i = 1:LevelsNumb(2) %По столбцам
    ResultTable{BeginTitleInd, 2 + (i-1)*ShiftCol} = Title{1}(i);
end

%Запись данных
Pointer = [BeginTitleInd+1, 2]; %Приращение ячейки для записи (1 == 'A', N ==..)
for i = 1:LevelsNumb(1)
    %Запись сведений о рассеянии
    for j = 1:LevelsNumb(2)
        TempCell = RegressionParams{i, j}; %Срез cell данных
        for k = 1:length(TempCell)
            ResultTable{Pointer(1)+k-1, Pointer(2)+(j-1)*ShiftCol} = TempCell{k};
        end
    end 
    Pointer(1) = Pointer(1) + ShiftRow; %Приращение строки записи   
end
xlswrite(FullFileName, ResultTable, SpreadSheet); %Сохранение таблицы

end

