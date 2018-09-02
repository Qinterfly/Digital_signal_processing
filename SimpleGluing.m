function [SignalGlued] = SimpleGluing(Signal,Index)
%Простая склейка фрагментов по концам

if iscell(Signal) && iscell(Index)
    LevelsNumb = length(Signal); %Запись числа уровней
    for s = 1:LevelsNumb
        %Соединение фрагментов
        if ~isempty(Index{s})
            SaveIndex = Index{s}(1);
            for i = 2:length(Index{s})
                MarkValue = Signal{s}(SaveIndex,2); %Оценочное значение
                Different = Signal{s}(SaveIndex + 1,2) - MarkValue; %Разница концов
                for j = SaveIndex + 1:Index{s}(i)
                    Signal{s}(j,2) = Signal{s}(j,2) - Different; %Сдвиг фрагмента
                end
                SaveIndex = Index{s}(i);
            end
            %Удаление стыковых точек
            Delete = sort(Index{s},'descend');
            for i = 2:length(Delete)
                Signal{s}(Delete(i) + 1,:) = []; %Удаление стыковых точек с конца
            end
            IndexGlued{s} = find(Signal{s}(:,3) == 1); %Обновляем массив индексов фрагментов
            Signal{s}(:,2) = Signal{s}(:,2) - Signal{s}(1,2); %Отнулевой сигнал
            SignalGlued{s} = Signal{s}; %Склееный отнулевой сигнал
        else
            SignalGlued{s} = []; %Пустой сигнал
        end
    end
end

end

