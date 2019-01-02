function [InputData, TechnicalData, Signal] = ReadInput(FileName,StartReadNumb)
%Считывание файла c исходными данными

fileID = fopen(FileName,'r'); %Открытие файла для считывания
InputData = textscan(fileID,'%s', 'delimiter', '\n', 'whitespace', ''); %Считывание данных из файла
fclose(fileID); %Закрытие файла
Swap = InputData{1}; InputData = Swap; %Перезапись считанных данных
InputDataClone = InputData; %Копия исходного сигнала
for i = 1:StartReadNumb - 1 %Цикл до начала сигнала
    TechnicalData{i,1} = InputData{i}; %Сохранение технических сведений
    InputDataClone{i} = {}; %Обнуление строк с техническими сведениями
end
TempData = InputDataClone(~cellfun('isempty',InputDataClone)); %Удаляем технические сведения
if ~isempty(i) %Если имеются техническе сведения о сигнале
    PhysicalFactor = str2num(TechnicalData{7}); %Физический множитель сигнала
    for i = 1:length(TempData)
        Signal(i,:) = PhysicalFactor*str2num(TempData{i}); %Формируем временной сигнал
    end
else
    TechnicalData = []; Signal = []; %Обнуление переменных
end
end

