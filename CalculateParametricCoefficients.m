function Result = CalculateParametricCoefficients(Signals, Param)
% ������ ������������� �������, ������� ������������� � ��������� ���������
% ��� ��������� ������ ��������
% Param:
%       == {'Angle', 
%           'Sim',
%           'Distance'}

% ��������� ���� ����������
if ~iscell(Param)
    tParam = Param; Param = {};
    Param{1} = tParam;
end 

nParam = length(Param); % ����� ����������
% ��������� ������ �������
isParam.Angle = FindEntry(Param, 'Angle'); 
isParam.Sim = FindEntry(Param, 'Sim');
isParam.Distance = FindEntry(Param, 'Distance');

% ��������� ����������
if ~(isParam.Angle || isParam.Sim || isParam.Distance)
    error('�������� �������� �������');
end

nSignals = length(Signals); % ����� ��������
MinLengthSignals = Inf; % ��������� ����������� ���� ��������
for i = 1:nSignals
    if length(Signals{i}) < MinLengthSignals % ������ ����������� ����� �������
        MinLengthSignals = length(Signals{i});
    end
end

% ���� �������� �� ����� �����������
for i = 1:nSignals
    Signals{i} = Signals{i}(1:MinLengthSignals);
end

% ��������� ������ ��� �������
if isParam.Angle, DataAngleCoeff = zeros(nSignals); end % ����
if isParam.Sim, DataSimilarityCoeff = zeros(nSignals); end % �������    
if isParam.Distance, DistanceScatter = zeros(nSignals); end % ���������

% ����������� ��������
for i = 1:nSignals
    for j = 1:nSignals
        LinearRegressionCoeffs = polyfit(Signals{i}, Signals{j}, 1); % ������������ �������� ��������
        if isParam.Distance % ��� ����������� ��������� ���������
            LinearRegressionFun = polyval(LinearRegressionCoeffs, Signals{i}); % ���������� �������� ������� ���������
            DistanceScatter(i, j) = sum(abs(Signals{j} - LinearRegressionFun)); % ��������� ���������
        end
        if isParam.Sim || isParam.Angle % 'Sim' || 'Angle'
            DataAngleCoeff(i, j) = LinearRegressionCoeffs(1); % ������ �������� ������������
        end
    end
end

if isParam.Sim % ������������ �������
    for i = 1:nSignals
        for j = 1:nSignals
            DataSimilarityCoeff(i, j) = sqrt(DataAngleCoeff(i, j) * DataAngleCoeff(j, i));
        end
    end
end

% �������� ������� �����������
itr = 1;
for i = 1:length(Param)
    switch Param{i}
        case 'Angle'
            Result{itr} = DataAngleCoeff;
        case 'Sim'
            Result{itr} = DataSimilarityCoeff;
        case 'Distance'
            Result{itr} = DistanceScatter;
    end
    itr = itr + 1; %  ���������� ��������
end
if nParam == 1
    Result = Result{1}; % ����� ������ ����������
end

end

function isEntry = FindEntry(ArrayString, StringCompare)
% �������� ������� ��������� ������ � ������

isEntry = false;
for i = 1:size(ArrayString, 1)
    for j = 1:size(ArrayString, 2)
        if strcmp(ArrayString{i, j}, StringCompare)
           isEntry = true;
           break;
        end   
    end
end

end

