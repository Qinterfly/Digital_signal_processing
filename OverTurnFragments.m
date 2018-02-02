function [FixPartsSignalTurn, FixPartsSignalDerivativeTurn] = OverTurnFragments(FixPartsSignal,IndexPartsSignal,FixPartsSignalDerivative)
%Переворот фрагментов перед склейкой

LevelsNumb = length(IndexPartsSignal); %Число уровней
for i = 1:LevelsNumb %Цикл по числу уровней
    SaveIndex = 0; %Номер конца предыдущего фрагмента
    for j = 1:length(IndexPartsSignal{i})
        if rem(j,2) %Если индекс четный
            for s = SaveIndex + 1:IndexPartsSignal{i}(j)
                FixPartsSignalTurn{i}(s,:) = [FixPartsSignal{i}(s,1), -FixPartsSignal{i}(IndexPartsSignal{i}(j) - s + 1,2), FixPartsSignal{i}(s,3)]; %Поворачиваем фрагменты (X-Y) с сохранением номеров
                FixPartsSignalDerivativeTurn{i}(s,:) = [FixPartsSignalDerivative{i}(s,1), FixPartsSignalDerivative{i}(IndexPartsSignal{i}(j) - s + 1,2), FixPartsSignalDerivative{i}(s,3)]; %Поворот производной
            end
        else
            for s = SaveIndex + 1:IndexPartsSignal{i}(j)
                FixPartsSignalTurn{i}(s,:) = [FixPartsSignal{i}(s,1), FixPartsSignal{i}(s,2), FixPartsSignal{i}(s,3)]; %Простая перезапись фрагмента
                FixPartsSignalDerivativeTurn{i}(s,:) = [FixPartsSignalDerivative{i}(s,1), FixPartsSignalDerivative{i}(s,2), FixPartsSignalDerivative{i}(s,3)]; %Простая перезапись производной
            end
        end
        SaveIndex = IndexPartsSignal{i}(j); %Приращение индекса конца предыдущего фрагмента
    end
end
end

