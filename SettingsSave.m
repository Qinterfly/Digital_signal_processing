function SettingsSave(SettingsOutput, Path, InputFileName)
%Сохранение настроек расчёта

if ~isempty(SettingsOutput) && size(SettingsOutput,2) ~= 2 %Проверка формы вывода данных
    error('Некорректная форма вывода настроек программы');
end
Path = strcat(Path,'/Результаты/',InputFileName);
if ~isdir(Path)
   mkdir(Path); %Создание директории для данного сигнала 
end
fileID = fopen(strcat(Path,'/','Settings.txt'),'w'); %Открытие файла для записи
for i = 1:length(SettingsOutput) %Цикл по всем строкам
    if ischar(SettingsOutput{i,2}) %Проверка символьного типа
        if isempty(SettingsOutput{i,2}) %Проверка пустоты строки
            fprintf(fileID,'%s = %s\r\n',SettingsOutput{i,1},'null'); %Запись настроек в файл            
        else
            fprintf(fileID,'%s = %s\r\n',SettingsOutput{i,1},SettingsOutput{i,2}); %Запись настроек в файл
        end
    elseif SettingsOutput{i,2} < 1e-3 && SettingsOutput{i,2} ~= 0
        fprintf(fileID,'%s = %e\r\n',SettingsOutput{i,1},SettingsOutput{i,2}); %Запись настроек в файл        
    else
        fprintf(fileID,'%s = %4.4f\r\n',SettingsOutput{i,1},SettingsOutput{i,2}); %Запись настроек в файл
    end
end
fclose(fileID); %Закрытие файла
end

