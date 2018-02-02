function NewSignal = CorrectLength(Signal,LengthCorrect,MonotoneFragmentIndent,DepthGluing)
    %���������� ������ �� �����

if LengthCorrect == 0 %���� ���������� �� ����� �� ��������
    NewSignal = Signal; %���������� �������� ������
    return;
end
    %�������� ������� �����
if iscell(Signal) 
    LevelsNumb = length(Signal); %����� �������
else
    error('������ ������� ������: cell');
end
    %���������� � ������� ���������
for i = 1:LevelsNumb
    TempIndex = find(Signal{i}(:,3) == 1); %������� ���� ����������
    TempIndex(end) = []; %�� ����������� �����
    Signal{i}(TempIndex,3) = 0; 
end
    %���������� �����������
for i = 1:LevelsNumb
    for j = 1:size(Signal{i},1) - 1
        SignalDerivative{i}(j,2) = Signal{i}(j + 1,2) - Signal{i}(j,2);        
    end
    SignalDerivative{i}(end + 1,2) = Signal{i}(end,2) - Signal{i}(end - 1,2); %����� �������� ��������
    SignalDerivative{i}(:,1) = Signal{i}(:,1); %���������� �������
    SignalDerivative{i}(:,3) = Signal{i}(:,3); %������� ����� ����������
    %�������� ��� ��������
    TempSignal{i} = [Signal{i}; Signal{i}]; %������
    TempSignalDerivative{i} = [SignalDerivative{i}; SignalDerivative{i}]; %�����������
    %��������� ��������
    IndexTempSignal{i} = find(TempSignal{i}(:,3) == 1);
end
    %����� ����������� �������
if ~MonotoneFragmentIndent %��� ������ � ����������� �����������
    [SignalGlued FailSignalGlued] = OptimalGluing(IndexTempSignal,TempSignal,TempSignalDerivative,0.4,DepthGluing); %��� ������ � ��������, ������� �� ������
    %��������� �������� ��� ������������
    for i = 1:LevelsNumb %���� �� ����� �������
        IndexSignalGlued{i} = find(SignalGlued{i}(:,3) == 1); %��������� �������� ���� ����������
        Pattern{i} = SignalGlued{i}(IndexSignalGlued{i}(1) + 1:end,:); %�������� �������
    end
else
    for i = 1:LevelsNumb %���� �� ����� �������
        Pattern{i} = Signal{i}; %�������� �������
        SignalGlued{i} = Signal{i}; 
    end
end
    %���������� � �����
for i = 1:LevelsNumb %���� �� ���� �������
    CopyNumb = ceil(LengthCorrect/length(Pattern{i})); %����� ����������� �� �����
    if CopyNumb > 1 %���� ������� ������ �������� �����
        NewSignal{i} = [Signal{i};Pattern{i}];
        for j = 1:CopyNumb %�������� CopyNumb ���
            NewSignal{i} = [NewSignal{i}; Pattern{i}];
        end
    else
        NewSignal{i} = Signal{i}(1:LengthCorrect,:);
        NewSignal{i}(end,3) = 1; %����� �����
    end
    IndexNewSignal{i} = find(NewSignal{i}(:,3) == 1);
end
    %��� ������ � ����������� ����������� �������� ��������� �������
if MonotoneFragmentIndent  
    NewSignal = SimpleGluing(NewSignal, IndexNewSignal);
end
    %�������� �� �����
for i = 1:LevelsNumb
    if length(NewSignal{i}) > LengthCorrect %������������� �� �����
        NewSignal{i} = NewSignal{i}(1:LengthCorrect,:);
        NewSignal{i}(end,3) = 1;
    end
end

end
