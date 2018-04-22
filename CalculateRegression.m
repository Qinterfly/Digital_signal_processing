function [RegressionTable, Title] = CalculateRegression(InputAccel, Accel, MonotoneAccel, ExpAccel, FrequencyInputAccel, FrequencyAccel, FrequencyMonotoneAccel, FrequencyExpAccel, RegressionArg, CurrentLevels)
%�������� ������� ������������� ������������� �� �������� ����������.

ComplexTableSignal = []; Title.Rows = {}; Title.Cols = {}; %������� �������� � ���������� �� ���� �������

%����������� ������� �������� �� �����
try
for i = 1:length(RegressionArg)
    switch RegressionArg{i}
        case '��' %��������� ��������
            ComplexTableSignal = [ComplexTableSignal, InputAccel]; %���������� ��������� �� �������
            Title.Rows = [Title.Rows, CreateTitleNameByID(0, RegressionArg{i})]; %��������� �� �������
        case '�' %��������� �� �������
            for j = 1:size(MonotoneAccel{1},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyAccel, FrequencyInputAccel, Accel(:,j), 1, 0)]; %������������� �������� �� ����� ���������
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %��������� �� �������
        case '��' %��������� ������������
            for j = 1:size(MonotoneAccel{1},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyMonotoneAccel{1}, FrequencyInputAccel, MonotoneAccel{1}(:,j), 1, 0)]; %������������� �������� �� ����� ���������
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %��������� �� �������
        case '��' %��������� �����������
            for j = 1:size(MonotoneAccel{2},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyMonotoneAccel{2}, FrequencyInputAccel, MonotoneAccel{2}(:,j), 1, 0)]; %������������� �������� �� ����� ���������
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %��������� �� �������
        case '��' %��������� ���������
            for j = 1:size(MonotoneAccel{3},2)
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyMonotoneAccel{3}, FrequencyInputAccel, MonotoneAccel{3}(:,j), 1, 0)]; %������������� �������� �� ����� ���������
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID(CurrentLevels, RegressionArg{i})]; %��������� �� �������
        case '��'
            for j = 1:2
                ComplexTableSignal = [ComplexTableSignal, ApproxSpline(FrequencyExpAccel, FrequencyInputAccel, ExpAccel(:,j), 1, 0)]; %������������� �������� �� ����� ���������
            end
            Title.Rows = [Title.Rows, CreateTitleNameByID([-1 0], RegressionArg{i})]; %��������� �� �������
    end
end
catch %������������� ����� �����
    for s = 1:3, RegressionTable{s} = 0; end
    Title.Rows = 'Empty'; Title.Cols = 'Empty';
    return
end
%���������� ������ ��������
for i = size(ComplexTableSignal,2):-1:1
    if ~nnz(ComplexTableSignal(:,i))
        ComplexTableSignal(:,i) = []; %�������� �������� �������
        Title.Rows(i) = []; %�������� ���������
    end
end
Title.Cols = Title.Rows; %Placeholder
ColsNumb = size(ComplexTableSignal, 2); %����� �������

%������������� ����� ���������
for s = 1:3
    RegressionTable{s} = zeros(ColsNumb); %������� [������� �������������, ��������� ���������, ���� ������]
end
%���������� ������������ ���������� �� ��������
for i = 1:ColsNumb 
   BaseSignal = ComplexTableSignal(:,i); %�������� ������
   for j = 1:ColsNumb 
       ShowSignal = ComplexTableSignal(:,j); %������ ��� ���������
       %���������� �������� ���������
       LinearRegressionCoeffs = polyfit(BaseSignal, ShowSignal, 1); %������������ ��� �������� ���������
       LinearRegressionFun = polyval(LinearRegressionCoeffs, BaseSignal); %���������� �������� �������� ���������
       DistanceScatter = sum(abs(ShowSignal - LinearRegressionFun)); %��������� ���������
       %[MaxBaseSignal MaxBaseSignalInd] = max(BaseSignal); [MaxShowSignal MaxShowSignalInd] = max(ShowSignal); %��������� ���������
       %FreqMaxBaseSignal = Frequency(MaxBaseSignalInd); FreqMaxShowSignal = Frequency(MaxShowSignalInd); %�������
       LengthCurve = 0; %������������� ����� ������
       for p = 1:length(BaseSignal) - 1
           LengthCurve = LengthCurve + sqrt((BaseSignal(p+1) - BaseSignal(p))^2 + (ShowSignal(p+1) - ShowSignal(p))^2); %����� ������
       end
       %������ ����������� �������
       RegressionTable{1}(i,j) = LinearRegressionCoeffs(1); %������� �����������
       RegressionTable{2}(i,j) = DistanceScatter; %��������� ���������
       RegressionTable{3}(i,j) = LengthCurve; %����� ���������
   end
end
   
end

function Title = CreateTitleNameByID(Levels, ID)
    % �������� ��������� ������� ������������� ������ ������ � ��������������
    for i = 1:length(Levels)
        if Levels(i) <= 0
            Title{i} = strcat(ID, num2str(Levels(i))); %ID-N
        else
            Title{i} = strcat(ID, '+', num2str(Levels(i))); %ID+N
        end
    end

end

