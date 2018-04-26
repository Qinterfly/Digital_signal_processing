function OutputSaveRegressionInform(RegressionTable, Title, FileName, TechnicalData, Path, InputFileName)
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
SpreadSheet = {'Технические сведения', 'Угловой коэффициент',... 
              'Дистанция рассеяния', 'Длина кривой', 'Амплитуда', 'Максимальная частота'}; %Название рабочей страницы страницы
%Создание заголовков колонок
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
%Запись шаблонов таблиц 
TitleMask{1,1} = '\'; %Placeholder
for i = 1:length(Title.Rows)
    TitleMask{1+i,1} = Title.Rows{i}; %По строкам
end
for j = 1:length(Title.Cols)
    TitleMask{1,1+j} = Title.Cols{j}; %По столбцам
end
BeginTitleInd = [2, 2]; %Индексы начала основных данных (строка, столбец)
ElementNumb = length(RegressionTable); %Число регрессионных параметров
%Формирование таблиц параметров регрессии к записи
for s = 1:length(RegressionTable)
    LevelsNumb{s} = size(RegressionTable{s}); %Число уровней по строкам и столбцам для каждого параметра
end
for p = 1:ElementNumb
    if ~isvector(RegressionTable{p})
        ResTable{p} = TitleMask; %Запись шаблона таблицы
    else
        ResTable{p} = TitleMask(:,1); %Запись шаблона вектора
    end
end
%Запись числовых значений
for s = 1:ElementNumb %Цикл по числу параметров
    for i = 1:LevelsNumb{s}(1) %Циклы по размерностям уровней
        for j = 1:LevelsNumb{s}(2)
            OriginalData = RegressionTable{s}(i,j); %Неформатированная строка с данными
            Pointer = [BeginTitleInd(1)+i-1, BeginTitleInd(2)+j-1]; %Указатель на позицию записи
            ResTable{s}{Pointer(1),Pointer(2)} = strrep(num2str(OriginalData),'.',','); %Запись значения
        end
    end
end
%Сохранение таблиц
xlswrite(FullFileName, TechnicalData, SpreadSheet{1}); %Таблица технических сведений
for s = 1:ElementNumb
    xlswrite(FullFileName, ResTable{s}, SpreadSheet{s+1}); %Запись результирующих таблиц
end

end


