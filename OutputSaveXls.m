function OutputSaveXls(OutputSignal, TitleLevels, FileName, TechnicalData, Path, InputFileName)
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
%Создание результрующей таблицы
    %Технические сведения
for i = 1:length(TechnicalData)
    ResultTable{i,1} = (TechnicalData{i});
end
ResultTable{i + 1,1} = ''; %Отступ перед основными данными
BeginBaseInd = i + 2; %Индекс начала основных данных
    %Основные данные
EndColInd = 1;
for i = 1:length(OutputSignal)
    TempArrayToCell = '';
    ResultTable{BeginBaseInd, EndColInd} = TitleLevels(i); %Номер столбца
    if ~isempty(OutputSignal{i})
        for m = 1:size(OutputSignal{i}, 1) %Цикл по строкам матрицы вывода
            for n = 1:size(OutputSignal{i}, 2) %Цикл по столбцам матрицы вывода,
                ResultTable{BeginBaseInd + m, EndColInd + n-1} = strrep(num2str(OutputSignal{i}(m, n)), '.', ','); %Запись сигнала уровня по столбцам с отступами в формате .xls
            end
        end
        EndColInd = EndColInd + size(OutputSignal{i}, 2) + 1; %Приращение индекса последнего столбца
    else
        EndColInd = EndColInd + 2;
    end
end
xlswrite(FullFileName, ResultTable, SpreadSheet); %Сохранение таблицы

end

