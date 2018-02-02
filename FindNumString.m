function Numbers = FindNumString(String)
%Поиск чисел в заданной строке

if ~ischar(String)
   error('Неверный формат входной строки'); 
end

k = 1; %Счетчик вхождения чисел
StrNumbers{k} = ' '; %Выделение памяти под число
for i = 1:length(String)
    if ~isempty(str2num(String(i)))
        StrNumbers{k} = strcat(StrNumbers{k}, String(i)); %Добавление цифры к числу
        if i ~= length(String)
           if isempty(str2num(String(i+1)))
                k = k + 1; %Приращение счетчика найденных чисел
                StrNumbers{k} = ' '; %Выделение памяти под следующее число
           end
        end
    end
end
%Проверка результатов поиска
if isempty(StrNumbers)
   Numbers = 0;
   return;
end
%Перезапись полученных чисел в массив
for i = 1:length(StrNumbers)
    if StrNumbers{i} ~= ' '
        Numbers(i) = str2num(StrNumbers{i});
    end
end

end

