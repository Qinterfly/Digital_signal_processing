function  [PartsSignal IndexPartsSignal] = AssignLevels(Time, Signal, LineLevels)
%��������� ������ ������� �� ��������

LevelsNumb = size(LineLevels, 1); %����� �������
for i = 1:LevelsNumb %���� �� ����� �������
    k = 1; %�������� ���������� 
    for j = 1:length(Signal) %���� �� ��������� �������
        if Signal(j) >= LineLevels(i,1) && Signal(j) <= LineLevels(i,2) %������ ��������� � �������
            PartsSignal{i}(k,1) = Time(j); %������ ������� 
            PartsSignal{i}(k,2) = Signal(j); %������ �������
            if j ~= length(Signal) %���� ����� �� ���������
               if ~(Signal(j+1) >= LineLevels(i,1) && Signal(j+1) <= LineLevels(i,2)) %�������� ����� ���������
                   PartsSignal{i}(k,3) = 1; %������������� ����� ���������
               end
            end
            k = k + 1; %���������� ���������� ������ ������
        end
    end
    PartsSignal{i}(end,3) = 1; %������������ ������� ����� ���������� ��������� 
    IndexPartsSignal{i} = find(PartsSignal{i}(:,3) == 1); %��������� �������� ������ ����������
end
    
end