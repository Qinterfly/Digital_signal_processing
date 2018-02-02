function [FixParts,PartsDerivative,IndexParts,OscillationParts,IndexOscillationParts] = FixNormalizeDerivative(Parts, IndexParts, CutProcent, NormalizeMode)
%��������� �������� ���������� � ������������ �������. ���������� ��������
%���������

LevelsNumb = length(Parts); %����� �������
    %��������� �������� ����������
for i = 1:LevelsNumb
    SaveIndex = 0; %����� ����� ����������� ���������    
    for j = 1:length(IndexParts{i}) %���� �� ���� �������
        LengthsFragment{i}(j,1) = length(Parts{i}(SaveIndex + 1:IndexParts{i}(j),2)); %������ ���� ���� ����������
        SaveIndex = IndexParts{i}(j); %������ ������� ����� ���������        
    end
    MaxLength(i) = max(LengthsFragment{i}); %���������� ������������ ������ ��� ��������� ������
    LimCut(i) = ceil(MaxLength(i)*CutProcent); %������ ����� ������� ��� ������� �� �������
end
    %��������� �������� ����������
for i = 1:LevelsNumb
    SaveIndex = 0;
    FixParts{i} = []; %��������� �������� ��������� �������
    OscillationParts{i} = []; %��������� �������� ����� ������ �������
    for j = 1:size(IndexParts{i},1)
        if LengthsFragment{i}(j,1) > LimCut(i) %������ ����� ���������
            FixParts{i} = [FixParts{i};Parts{i}(SaveIndex + 1:IndexParts{i}(j),:)]; %���������� ��������� � ����� ������
        elseif LengthsFragment{i}(j,1) > 1 %���������� ��������� �� ����� �����
            OscillationParts{i} = [OscillationParts{i}; Parts{i}(SaveIndex + 1:IndexParts{i}(j),:)]; %���������� ������������ ���������
        end
        SaveIndex = IndexParts{i}(j); %������ ������� ����� ���������
    end
    IndexParts{i} = find(FixParts{i}(:,3) == 1); %������ ������� ���������� � ��������� ����������
    if IndexParts{i}(end,1) < size(FixParts{i},1)
        IndexParts{i}(end + 1,1) = size(FixParts{i},1); %���������� ������� ����� ���������� ���������
        FixParts{i}(end,3) = 1;
    end
    if ~isempty(OscillationParts{i})
        IndexOscillationParts{i} = find(OscillationParts{i}(:,3) == 1); %������ ������� ���������� � ��������� ����������
        if IndexOscillationParts{i}(end,1) < size(OscillationParts{i},1)
            IndexOscillationParts{i}(end + 1,1) = size(OscillationParts{i},1); %���������� ������� ����� ���������� ���������
            OscillationParts{i}(end,3) = 1;
        end
    else
        IndexOscillationParts{i} = OscillationParts{i}; %�������� ������������ ����
    end
end
    %���������� ������� ��������� ������� 
for i = 1:LevelsNumb %���� �� ���� �������
    SaveIndex = 0; %����� ����� ����������� ���������
    for j = 1:length(IndexParts{i}) %���� �� ������� �������� ����������
        MeanTemp = mean(FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2)); %������� �������� ������� ���������
        FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2) = FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2) - MeanTemp;
        if NormalizeMode %���������� ������� ��������� �� ���������
            MaxTemp = max(abs(FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2))); %��������� �������� ���������
            if MaxTemp ~= 0 %������� ���������� ������� ����������
                FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2) = FixParts{i}(SaveIndex + 1:IndexParts{i}(j),2)./MaxTemp;
            end
        end
        SaveIndex = IndexParts{i}(j); %������ ������� ����� ���������
    end
end
    %���������� ����������� �� ������ ���������
for i = 1:LevelsNumb %���� �� ���� �������
    SaveIndex = 0; %����� ����� ����������� ���������
    for j = 1:length(IndexParts{i}) %���� �� ������� �������� ����������
        if LengthsFragment{i}(j) ~= 1 %�������� ��������� ����������
            PartsDerivative{i}(IndexParts{i}(j),1) = FixParts{i}(IndexParts{i}(j),2) - FixParts{i}(IndexParts{i}(j) - 1,2); %����� �������� ��������
            for s = SaveIndex + 1:IndexParts{i}(j) - 1 %���� �� ���� ������ ���������� ���������
                PartsDerivative{i}(s,1) = FixParts{i}(s + 1,2) - FixParts{i}(s,2);
            end
        else
            PartsDerivative{i}(IndexParts{i}(j),1) = 0; %�������� �����������, ���� �������� ���������
        end
        SaveIndex = IndexParts{i}(j); %������ ������� ����� ���������
    end 
    PartsDerivative{i} = [FixParts{i}(:,1),PartsDerivative{i}];
    PartsDerivative{i}(:,3) = FixParts{i}(:,3);
end 

end

