function [PartsMonotoneAccel, IndexMonotoneAccel] = ConstructMonotoneLevels(PartsAccel, PartsDisplacement, LineLevels)
%��������� ���������� ������ � ������� 
%(Signal->Levels(Increase, Neutral, Decrease)

MaxLengthParts = [0, 0, 0]; %������������� ������� ���������� ���� �� ���� �������
for i = 1:size(LineLevels,1) %�� ���� �������
    IndexParts = find(PartsAccel{i}(:,3) == 1); %��������� �������� ������ ����������
    Boundary = abs(LineLevels(i,2) - LineLevels(i,1)) * 0.05; %������������ �������� ����������� ������ (5% �����)
    for s = 1:3 %��������� �������� : [Increase, Neutral, Decrease]
        PartsMonotoneAccel{s}{i} = [];
    end
    SaveIndex = 1; %������ ����� ���������
    for j = 1:length(IndexParts)
        Difference = PartsDisplacement{i}(IndexParts(j),2) - PartsDisplacement{i}(SaveIndex,2); %������ ������� ������
        FlagMonotone = 0; %���� ������������ ������ 
        if abs(Difference) > Boundary %�������� ���������� �����������
            %������������
            if Difference > 0
                FlagMonotone = 1;
            end
            %���������
            if Difference < 0
                FlagMonotone = 3;
            end
        %�����������
        else
            FlagMonotone = 2;
        end
            %������ ������� �� �����
        PartsMonotoneAccel{FlagMonotone}{i} = [PartsMonotoneAccel{FlagMonotone}{i}; PartsAccel{i}(SaveIndex:IndexParts(j),:)]; 
        SaveIndex = IndexParts(j) + 1; %���������� ������� ���������� �� ������ ���������   
    end
    %���������� ���� ���������� ���������� �� ������
    for s = 1:3 %[Increase, Neutral, Decrease]
        if MaxLengthParts(s) < length(PartsMonotoneAccel{s}{i})
            MaxLengthParts(s) = length(PartsMonotoneAccel{s}{i});
        end
    end
end
%�������� + ���������� 
for i = 1:size(LineLevels,1)
    for s = 1:3
        if isempty(PartsMonotoneAccel{s}{i})
            PartsMonotoneAccel{s}{i} = zeros(MaxLengthParts(s),3);
            PartsMonotoneAccel{s}{i}(end, 3) = 1;
        end %�������� ������
        IndexMonotoneAccel{s}{i} = find(PartsMonotoneAccel{s}{i}(:,3) == 1); %������ ��������
    end
    
end

end

