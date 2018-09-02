function LineLevels = CreateLevels(Signal, LevelsStep, OverlapFactor)
%�������� ������� ��� ��������� ������� � ���� �������

if ~OverlapFactor %����������� ��������������� ��������� ��������������� �������
   OverlapFactor = 1; 
end
%��������� ��������
MaxSignal = max(Signal); %������������ �������� ������� ����������
MeanSignal = mean(Signal); %������� �������� ������� ����������
MinSignal = min(Signal); %����������� �������� ������� �����������

%���������� ������������� ������
if MaxSignal <= (mean(Signal) + LevelsStep/2) && MinSignal >= (mean(Signal) - LevelsStep/2)
    LineLevels(1,:) = [mean(Signal) - LevelsStep/2, mean(Signal) + LevelsStep/2, 0]; %��������� ��������� ����    
    return;
end

%�������� �� min �������
LineLevels(1,:) = [min(Signal), min(Signal) + LevelsStep, -1]; %��������� �������� ������ 
i = 1; %��������� �������� ����������
while 1 %��������� ������ ������
    if LineLevels(i,2) >= MaxSignal
        break;
    end
    i = i + 1; %���������� ����������
    LineLevels(i,:) = [LineLevels(i - 1, 1) + OverlapFactor*LevelsStep, LineLevels(i - 1, 2) + OverlapFactor*LevelsStep, -1]; %������ �������� ����� ������ ��� ������ �����
end
%��������� �������
IndexZeroLevel = floor(size(LineLevels,1)/2); %������ �������� ������
LineLevels(IndexZeroLevel,3) = 0; %������������ ������ ������
LineLevels(1:IndexZeroLevel - 1,3) = -(IndexZeroLevel - 1):-1; %������ ������
LineLevels(IndexZeroLevel + 1:end,3) = 1:(size(LineLevels,1) - IndexZeroLevel); %������ ������

end
