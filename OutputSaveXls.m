function OutputSaveXls(OutputSignal, TitleLevels, FileName, TechnicalData, Path, InputFileName)
%Сохранение результатов спектрального расчёта в виде таблиц в .xls формате

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
%Запись информации в файл
xlswrite(FullFileName, TechnicalData, SpreadSheet, 'A1'); %Запись технических сведений
XlRange = {1, length(TechnicalData) + 1}; %Приращение ячейки для записи (1 == 'A', N ==..)
for i = 1:length(OutputSignal)
    xlswrite(FullFileName, {strcat('#', num2str(TitleLevels(i)))}, SpreadSheet, strcat(XlRangeBase{XlRange{1}}, num2str(XlRange{2}))); %Имя уровня
    if ~isempty(OutputSignal{i}) %Пропуск уровня, в случае пустого сигнала
        xlswrite(FullFileName, OutputSignal{i}, SpreadSheet, strcat(XlRangeBase{XlRange{1}}, num2str(XlRange{2} + 1))); %Запись таблицы для данного уровня
    else
        xlswrite(FullFileName, {'Empty'}, SpreadSheet, strcat(XlRangeBase{XlRange{1}}, num2str(XlRange{2} + 1))); %Запись таблицы для данного уровня
    end
    XlRange{1} = XlRange{1} + size(OutputSignal{i}, 2) + 1; %Следующий за записью столбец
end

end

