function OutputSaveInformation(Struct, FileName, Path, InputFileName)
%Cохранение табличной информации

%Чтение исходных данных из структуры
HeadersRows = Struct.HeadersRows;
HeadersCols = Struct.HeadersCols;
Values = Struct.Values;

Path = strcat(Path,'\Результаты\',InputFileName);
if ~isdir(Path) %Создание директории для данных значений
    mkdir(Path);
end
fileID = fopen(strcat(Path,'/',FileName,'.txt'),'w'); %Открытие файла для записи

%Формирование результирующей матрицы для вывода
HeadersRows = char(['Arguments',HeadersRows]);
HeadersCols = char([HeadersRows(1,:),HeadersCols]); %Добавляем столбец
Values = num2str(Values); 
%Запись информации
    %Заголовоки по столбцам
for i = 1:size(HeadersCols,1)
    fprintf(fileID,'%s ',HeadersCols(i,:));
end
    %Данные + заголовки по строкам
Table = [HeadersRows(2:end,:),Values];
for i = 1:size(Table,1) 
    fprintf(fileID,'\r\n'); %Переход на новую строку
    fprintf(fileID,'%s',Table(i,:));
end
fclose(fileID); %Закрытие файла

end

