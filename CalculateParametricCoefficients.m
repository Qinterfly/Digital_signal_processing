function Result = CalculateParametricCoefficients(Signals, Param, Option)
% ������ ������������� �������, ������� ������������� � ��������� ���������
% ��� ��������� ������ ��������
% Param:
%       == {'Angle', 
%           'Sim',
%           'Distance',
%           'CoeffScatter'}
% Option:
%       == {'���������� � ����',
%           '�������� �������������',
%           '����������'

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
isParam.CoeffScatter = FindEntry(Param, 'CoeffScatter');

% ��������� ����������
if ~(isParam.Angle || isParam.Sim || isParam.Distance || isParam.CoeffScatter)
    error('�������� �������� �������');
end

nSignals = length(Signals); % ����� ��������
Signals = NormalizeSignals(Signals, Option); % ���������� ��������

% ��������� ������ ��� �������
if isParam.Angle, DataAngleCoeff = zeros(nSignals); end % ����
if isParam.Sim, DataSimilarityCoeff = zeros(nSignals); end % �������    
if isParam.Distance, DistanceScatter = zeros(nSignals); end % ���������
if isParam.CoeffScatter, CoeffScatter = zeros(nSignals); end % ����������� �������� ���������

% ����������� ��������
for i = 1:nSignals
    for j = 1:nSignals
        LinearRegressionCoeffs = polyfit(Signals{i}, Signals{j}, 1); % ������������ �������� ��������
        if isParam.Distance || isParam.CoeffScatter
            LinearRegressionFun = polyval(LinearRegressionCoeffs, Signals{i}); % ���������� �������� ������� ����������
        end
        if isParam.Distance % ��� ����������� ��������� ���������
            alpha = atan(LinearRegressionCoeffs(1)); % ���� ������� ������
            DistanceScatter(i, j) = sum(abs(Signals{j} - LinearRegressionFun)) * cos(alpha); % ��������� ���������
        end
        if isParam.CoeffScatter % ��� ������������ ���������            
            CentY = mean(LinearRegressionFun);
            CentX = (CentY - LinearRegressionCoeffs(2)) / LinearRegressionCoeffs(1);
            DistanceScatterAlong = sum(abs(Signals{i} - CentX)); % ����������
            DistanceScatterNormal = sum(abs(Signals{j} - CentY)); % ����������   
            CoeffScatter(i, j) = DistanceScatterNormal / DistanceScatterAlong; % cos(alpha) �����������
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
        case 'CoeffScatter'
            Result{itr} = CoeffScatter;
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

