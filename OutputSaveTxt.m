function OutputSaveTxt(OutputSignal, FileName, TechnicalData, Path, InputFileName)
%Сохранение выходных файлов, датированных днём записи исходного сигнала

Path = strcat(Path, InputFileName);
if ~isdir(Path) %Создание директории для данного сигнала
    mkdir(Path);
end
fileID = fopen(strcat(Path,'/',FileName,'.txt'),'w'); %Открытие файла для записи
TechnicalData{end} = num2str(size(OutputSignal,1)); %Запись в технические сведения реальной длины выходного сигнала
for i = 1:length(TechnicalData)
    fprintf(fileID,'%s \r\n',TechnicalData{i}); %Запись технических сведений
end
formatSpec = '%f \r\n'; %Формат записи значений
if size(OutputSignal,2) > 1
    dlmwrite(strcat(Path,'/',FileName,'.txt'),OutputSignal,'-append','delimiter','\t','newline','pc');
else
    fprintf(fileID,formatSpec,OutputSignal); %Запись сигнала с уровня
end
fclose(fileID); %Закрытие файла
end

