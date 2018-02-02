function [Signal, DependentArray] = PeakFilter(Signal, DependentArray)
%������� ������ �����

DerivativeSignal = diff(Signal); %������� ������ ����������� �� �������
Deviation = std(DerivativeSignal); %����������� ���������� �����������
DelIndicies = find(abs(DerivativeSignal) > 3*Deviation); %������� ��������
Signal(DelIndicies) = []; %�������� ��������
if ~isempty(DependentArray) %������������� ��������� �������� �� ��������� �������
    DependentArray(DelIndicies,:) = [];
else
    DependentArray = 0;
end

end

