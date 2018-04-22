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
              'Дистанция рассеяния', 'Длина кривой'}; %Название рабочей страницы страницы
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
%Формирование таблиц параметров регрессии к записи
LevelsNumb = size(RegressionTable{1}); %Число уровней по строкам и столбцам
ElementNumb = length(RegressionTable); %Число регрессионных параметров
for p = 1:ElementNumb
    ResTable{p} = TitleMask; %Запись шаблона таблицы
end
for i = 1:LevelsNumb(1)    
    for j = 1:LevelsNumb(2)
        for s = 1:ElementNumb
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


