function Signals = NormalizeSignals(Signals, Option)
% ���������� �������� �� ���������
% option = 
%       '���������� � ����'
%       '�������� �������������'
%       '����������'

if ~iscell(Signals) % �������� ��������� ������� ������
    tSignals = Signals; Signals = [];
    Signals{1} = tSignals; % ��������� �����������
end

nSignals = length(Signals); % ����� ��������� ��������
MinLengthSignals = Inf; % ��������� ����������� ���� ��������
for i = 1:nSignals % ������ ������ ���� ��������
    if length(Signals{i}) < MinLengthSignals % ������ ����������� ����� �������
        MinLengthSignals = length(Signals{i});
    end
end

% ����� ��������� + ���� �� �����
for i = 1:nSignals
    Signals{i} = Signals{i}(1:MinLengthSignals); % ���� �������� �� ����� �����������
    if strcmp(Option, '���������� � ����') || strcmp(Option, '����������')
        Signals{i} = Signals{i} - mean(Signals{i}); % ��������� ��������
    end
    if strcmp(Option, '�������� �������������')
        Signals{i} = LineCorrect((1:length(Signals{i}))', Signals{i});
    end
end

% ���������� � �������� ������������ �� �������� �������
if strcmp(Option, '����������') 
    for i = 2:nSignals % ���������� � �������� ������� (������� ����������)
        LinearRegressionCoeffs = polyfit(Signals{1}, Signals{i}, 1); % ������������ �������� ��������
        Signals{i} = Signals{i} / abs(LinearRegressionCoeffs(1)); % � �������� �����������
    end
end

end

