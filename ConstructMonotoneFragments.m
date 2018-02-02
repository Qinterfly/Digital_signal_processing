function [SignalIncrease SignalDecrease IndexIncrease IndexDecrease] = ConstructMonotoneFragments(Signal,SignalDerivative,Accel,ModeMonotone)
%��������� �������������� ���������� �� ������������

SignalIncrease = []; %��������� ������������ ����������
SignalDecrease = []; %��������� ��������� ����������
AccelIncrease = []; %��������� ������������ ���������� ���������
AccelDecrease = []; %��������� ��������� ����������
    %��������� ����������
LastIncrease = 1;
LastDecrease = 1;
for i = 1:length(Signal) - 1 %���� �� ���� ������ �������
    if SignalDerivative(i) >= 0 %���� ����������� �������������� - ������� � ������������ ����������
        SignalIncrease(LastIncrease,:) = [i, Signal(i,:), 0] ; %�������� ������� �����������
        AccelIncrease(LastIncrease,:) = [i, Accel(i,:), 0]; %�������� ������� ���������
        if LastIncrease > 1 
           if SignalIncrease(end,1) - SignalIncrease(end - 1,1) > 1
               SignalIncrease(end - 1,3) = 1;
               AccelIncrease(end - 1,3) = 1; 
           end
        end
        LastIncrease = LastIncrease + 1; %���������� ���������� �������
    end
    if SignalDerivative(i) <= 0 %���� ����������� �������������� - ������� � ��������� ����������
        SignalDecrease(LastDecrease,:) = [i, Signal(i,:), 0] ; %�������� ������� �����������
        AccelDecrease(LastDecrease,:) = [i, Accel(i,:), 0]; %�������� ������� ���������
        if LastDecrease > 1 
           if SignalDecrease(end,1) - SignalDecrease(end - 1,1) > 1
               SignalDecrease(end - 1,3) = 1;
               AccelDecrease(end - 1,3) = 1;               
           end
        end
        LastDecrease = LastDecrease + 1; %���������� ���������� �������
    end
end
    %�������� ������ ������ ������
switch ModeMonotone
    case 'Accel'
        SignalIncrease = AccelIncrease; %������� ���������� �� ���������
        SignalDecrease = AccelDecrease;
    case 'Displacement'
        SignalIncrease = SignalIncrease; %��������� �� ������������ (����������������� case)
        SignalDecrease = SignalDecrease;
end
    %�������� ���������� ����������
%���������
if isempty(SignalDecrease)
    SignalDecrease = zeros(size(SignalIncrease));
    SignalDecrease(:,1) = SignalIncrease(:,1); %������� ������� �����
end
%������������
if isempty(SignalIncrease)
    SignalIncrease = zeros(size(SignalDecrease));
    SignalIncrease(:,1) = SignalDecrease(:,1); %������� ������� �����
end
SignalDecrease(end,3) = 1; %������������ ���������� ������� ����� ���������
SignalIncrease(end,3) = 1; 
IndexIncrease = find(SignalIncrease(:,3) == 1); %��������� �������� ���� ����������
IndexDecrease = find(SignalDecrease(:,3) == 1); %��������� �������� ���� ����������
end



