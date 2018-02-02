function [SignalGlued] = SimpleGluing(Signal,Index)
%������� ������� ���������� �� ������

if iscell(Signal) && iscell(Index)
    LevelsNumb = length(Signal); %������ ����� �������
    for s = 1:LevelsNumb
        %���������� ����������
        if ~isempty(Index{s})
            SaveIndex = Index{s}(1);
            for i = 2:length(Index{s})
                MarkValue = Signal{s}(SaveIndex,2); %��������� ��������
                Different = Signal{s}(SaveIndex + 1,2) - MarkValue; %������� ������
                for j = SaveIndex + 1:Index{s}(i)
                    Signal{s}(j,2) = Signal{s}(j,2) - Different; %����� ���������
                end
                SaveIndex = Index{s}(i);
            end
            %�������� �������� �����
            Delete = sort(Index{s},'descend');
            for i = 2:length(Delete)
                Signal{s}(Delete(i) + 1,:) = []; %�������� �������� ����� � �����
            end
            IndexGlued{s} = find(Signal{s}(:,3) == 1); %��������� ������ �������� ����������
            Signal{s}(:,2) = Signal{s}(:,2) - Signal{s}(1,2); %��������� ������
            SignalGlued{s} = Signal{s}; %�������� ��������� ������
        else
            SignalGlued{s} = []; %������ ������
        end
    end
end

end

