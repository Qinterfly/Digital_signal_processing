function [InputData, TechnicalData, Signal] = ReadInput(FileName,StartReadNumb)
%���������� ����� c ��������� �������

fileID = fopen(FileName,'r'); %�������� ����� ��� ����������
InputData = textscan(fileID,'%s', 'delimiter', '\n', 'whitespace', ''); %���������� ������ �� �����
fclose(fileID); %�������� �����
Swap = InputData{1}; InputData = Swap; %���������� ��������� ������
InputDataClone = InputData; %����� ��������� �������
for i = 1:StartReadNumb - 1 %���� �� ������ �������
    TechnicalData{i,1} = InputData{i}; %���������� ����������� ��������
    InputDataClone{i} = {}; %��������� ����� � ������������ ����������
end
TempData = InputDataClone(~cellfun('isempty',InputDataClone)); %������� ����������� ��������
if ~isempty(i) %���� ������� ���������� �������� � �������
    PhysicalFactor = str2num(TechnicalData{7}); %���������� ��������� �������
    for i = 1:length(TempData)
        Signal(i,:) = PhysicalFactor*str2num(TempData{i}); %��������� ��������� ������
    end
else
    TechnicalData = []; Signal = []; %��������� ����������
end
end

