function [FixPartsSignalTurn, FixPartsSignalDerivativeTurn] = OverTurnFragments(FixPartsSignal,IndexPartsSignal,FixPartsSignalDerivative)
%��������� ���������� ����� ��������

LevelsNumb = length(IndexPartsSignal); %����� �������
for i = 1:LevelsNumb %���� �� ����� �������
    SaveIndex = 0; %����� ����� ����������� ���������
    for j = 1:length(IndexPartsSignal{i})
        if rem(j,2) %���� ������ ������
            for s = SaveIndex + 1:IndexPartsSignal{i}(j)
                FixPartsSignalTurn{i}(s,:) = [FixPartsSignal{i}(s,1), -FixPartsSignal{i}(IndexPartsSignal{i}(j) - s + 1,2), FixPartsSignal{i}(s,3)]; %������������ ��������� (X-Y) � ����������� �������
                FixPartsSignalDerivativeTurn{i}(s,:) = [FixPartsSignalDerivative{i}(s,1), FixPartsSignalDerivative{i}(IndexPartsSignal{i}(j) - s + 1,2), FixPartsSignalDerivative{i}(s,3)]; %������� �����������
            end
        else
            for s = SaveIndex + 1:IndexPartsSignal{i}(j)
                FixPartsSignalTurn{i}(s,:) = [FixPartsSignal{i}(s,1), FixPartsSignal{i}(s,2), FixPartsSignal{i}(s,3)]; %������� ���������� ���������
                FixPartsSignalDerivativeTurn{i}(s,:) = [FixPartsSignalDerivative{i}(s,1), FixPartsSignalDerivative{i}(s,2), FixPartsSignalDerivative{i}(s,3)]; %������� ���������� �����������
            end
        end
        SaveIndex = IndexPartsSignal{i}(j); %���������� ������� ����� ����������� ���������
    end
end
end

