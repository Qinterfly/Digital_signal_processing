function [RegressionTable, Title] = CalculateRegression(InputAccel, Accel, MonotoneAccel, ExpAccel, FrequencyInputAccel, FrequencyAccel, FrequencyMonotoneAccel, FrequencyExpAccel, RegressionArg, CurrentLevels)
%�������� ������� ������������� ������������� �� �������� ����������.

ComplexTableSignal = []; Title.Rows = {}; Title.Cols = {}; %������� �������� � ���������� �� ���� �������
ParamsNumb.Full = 5; %����� ���������� ��� ���������� �������
ParamsNumb.Vec = 2; %����� ���������� ��� ���������� �������

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
            Title.Rows = [Title.Rows, CreateTitleNameByID([-1, 0], RegressionArg{i})]; %��������� �� �������
    end
end
catch %������������� ����� �����
    for s = 1:ParamsNumb.Full + ParamsNumb.Vec, RegressionTable{s} = 0; end
    Title.Rows = 'Empty'; Title.Cols = 'Empty';
    return
end
% ���������� ������ ��������
for i = size(ComplexTableSignal,2):-1:1
    if ~nnz(ComplexTableSignal(:, i))
        ComplexTableSignal(:,i) = []; % �������� �������� �������
        Title.Rows(i) = []; % �������� ���������
    end
end
Title.Cols = Title.Rows; %Placeholder
ColsNumb = size(ComplexTableSignal, 2); %����� �������

%������������� ����� ���������
    %���������
for s = 1:ParamsNumb.Full
    RegressionTable{s} = zeros(ColsNumb); %������� [������� �������������, ��������� ���������, ���� ������, ������������ �������� ���������, ������������ �������]
end
    %���������
for s = ParamsNumb.Full + 1:ParamsNumb.Full + ParamsNumb.Vec
    RegressionTable{s} = zeros(ColsNumb, 1); %������� [���������, ������������ �������]
end
%���������� ������������ ���������� �� ��������
for i = 1:ColsNumb 
    BaseSignal = ComplexTableSignal(:, i); %�������� ������
    %���������� ���������� ���������
    [MaxBaseSignal MaxBaseSignalInd] = max(BaseSignal);  %��������� ���������
    FreqMaxBaseSignal = FrequencyInputAccel(MaxBaseSignalInd);  %�������
    %������ ����������� �������
    RegressionTable{5}(i) = MaxBaseSignal; %��������� �������
    RegressionTable{6}(i) = FreqMaxBaseSignal; %������� �������
    for j = 1:ColsNumb
        ShowSignal = ComplexTableSignal(:, j); %������ ��� ���������
        %���������� �������� ���������
        LinearRegressionCoeffs = polyfit(BaseSignal, ShowSignal, 1); % ������������ ��� �������� ���������
        LinearRegressionFun = polyval(LinearRegressionCoeffs, BaseSignal); % ���������� �������� �������� ���������
        alpha = atan(LinearRegressionCoeffs(1)); % ���� ������� ������
        % ������ ��������� ��������
        DistanceScatter = 1 / length(ShowSignal) * sum(abs(ShowSignal - LinearRegressionFun)) * cos(alpha); % C��������
        tShowSignal = sum(abs(ShowSignal - mean(ShowSignal)));
        tBaseSignal = sum(abs(BaseSignal - mean(BaseSignal)));
        CoeffScatter = DistanceScatter * length(ShowSignal) / sqrt(tBaseSignal ^ 2 + tShowSignal ^ 2); % ����������� ���������
        % ����� ������
        LengthCurve = 0; %������������� ����� ������
        for p = 1:length(BaseSignal) - 1
            LengthCurve = LengthCurve + sqrt((BaseSignal(p + 1) - BaseSignal(p)) ^ 2 + (ShowSignal(p + 1) - ShowSignal(p)) ^ 2); %����� ������
        end
        %������ ����������� �������
        RegressionTable{1}(i, j) = LinearRegressionCoeffs(1); % ������� �����������
        RegressionTable{2}(i, j) = DistanceScatter; % ��������� ��������� ���������
        RegressionTable{3}(i, j) = LengthCurve; % ����� ���������
        RegressionTable{4}(i, j) = CoeffScatter; % ����������� ������� ���������
    end
end
% ���������� ������������� �������
for i = 1:ColsNumb
    for j = 1:ColsNumb
        RegressionTable{5}(i, j) = sqrt(RegressionTable{1}(i, j) * RegressionTable{1}(j, i));
    end
end

end

function Title = CreateTitleNameByID(Levels, ID)
    % �������� ��������� ������� ������������� ������ ������ � ��������������
    for i = 1:length(Levels)
        if Levels(i) <= 0
            Title{i} = strcat(ID, num2str(Levels(i))); % ID-N
        else
            Title{i} = strcat(ID, '+', num2str(Levels(i))); % ID+N
        end
    end

end

