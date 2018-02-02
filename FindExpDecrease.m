function [PartsSignalApproxSpline,TableDecrementVisualize,PartsExpSignal,IndexPartsExpSignal,Limits] = FindExpDecrease(Signal,LimExpLevel,AccuracyExp,FreqDecrement,SampleRate,ModelApprox)
%����� ���������������� ��������� � �������
%Output: 1 - ���������; 2 - �������; 

%������� ������������ ��������
ExpLevel = max(abs(Signal))*LimExpLevel;
Limits = [mean(Signal) - ExpLevel, mean(Signal) + ExpLevel]; %������� � ������ ������� �����
%������� ������, ��������������� ������������� �������
PeriodDecrement = floor(1/FreqDecrement*SampleRate/200);
if PeriodDecrement == 0
   error('������� ������� �� ����� ���� ����������. ������� ������������� ������� ������������'); 
end
%���� ����� ������� �� �������
IndUp = 1; IndDown = 1; IndNeutral = 1; %�������� ��������� ����������
for i = 1:length(Signal)
    %��������� ��������� ���� ���
    if Signal(i) >= Limits(2)
       PartsExpSignalTemp{1}(IndUp,:) = [i Signal(i) 0];
       IndUp = IndUp + 1;
    end
    %��������� ��������� ���� ���
    if Signal(i) <= Limits(1)
        PartsExpSignalTemp{3}(IndDown,:) = [i Signal(i) 0];
        IndDown = IndDown + 1;
    end
    %����������� ��������� ���������
    if Signal(i) >= Limits(1) && Signal(i) <= Limits(2)
        PartsExpSignalTemp{2}(IndNeutral,:) = [i Signal(i) 0];
        IndNeutral = IndNeutral + 1;
    end
end
    %������� ����� ���������� 
for s = [1 3] %��������� ���� � ���� ���
    [ExpSignalApprox ExpSignalApproxDerivative] = ApproxSpline(PartsExpSignalTemp{s}(:,1),PartsExpSignalTemp{s}(:,2),AccuracyExp,2); %������������� B-���������
    k = 1;
    for i = 1:length(ExpSignalApproxDerivative) - 1
        if ExpSignalApproxDerivative(i+1)*ExpSignalApproxDerivative(i) < 0 %��������� �����
            IndexPartsExpSignalTemp{s}(k,1) = PartsExpSignalTemp{s}(i,1); %������ ����� � ������ ����� ���������
            k = k + 1; %���������� ��������
        end
    end
    IndexPartsExpSignalTemp{s}(1:2:length(IndexPartsExpSignalTemp{s})-1) = []; %�������� ����� ������ (���������� �������)
    %������������ �������� ������ ����������
    k = 1;
    for i = 1:length(IndexPartsExpSignalTemp{s})
        for j = 1:length(PartsExpSignalTemp{s})
            if PartsExpSignalTemp{s}(j,1) == IndexPartsExpSignalTemp{s}(i)
                PartsExpSignalTemp{s}(j,3) = 1; %����� ���������
                IndexPartsSignalApproxSpline{s}(k,1) = j;
                k = k + 1;
                break
            end
        end
    end
    %��������� ��������� �������� ��� ������� ����
    SaveIndex = 0; %��������� �������� ������� ����� ����������� ���������
    PartsSignalApproxSpline{s} = [];
    for i = 1:length(IndexPartsSignalApproxSpline{s}) %���������� ���� ��������� ��������
        Xdata = PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),1); %�������� ��� �������������
        Ydata = PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),2);
        try
            switch ModelApprox %������ ������������� ���������
                case 'B-Spline'
                    [ResultTemp, ~] = ApproxSpline(Xdata,Ydata,AccuracyExp,0); %������������� B-���������
                case 'Exponential'
                    FitModel = fittype('exp2');
                    FitFun = fit(Xdata,Ydata,FitModel); %���������� ������
                    ResultTemp = feval(FitFun,Xdata); %������ ����������� �� �������� �����
                case 'Rational'
                    FitModel = fittype('rat23');
                    FitFun = fit(Xdata,Ydata,FitModel); %���������� ������
                    ResultTemp = feval(FitFun,Xdata); %������ ����������� �� �������� �����
                case 'Power'
                    FitModel = fittype('power2');
                    FitFun = fit(Xdata,Ydata,FitModel); %���������� ������
                    ResultTemp = feval(FitFun,Xdata); %������ ����������� �� �������� �����
            end
        catch %���� ����� ��� ������������� ������������
            ResultTemp = zeros(length(Xdata),1);
        end
        ResultTemp = [PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),1),ResultTemp]; %����� ��� ��������� ��������
        ResultTemp(:,3) = PartsExpSignalTemp{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),3); %����� ���������� ��� ��������� ��������
        PartsSignalApproxSpline{s} = [PartsSignalApproxSpline{s}; ResultTemp];
        SaveIndex = IndexPartsSignalApproxSpline{s}(i);
    end
    SaveIndex = 0; %��������� �������� ������� ����� ����������� ���������
    for i = 1:length(IndexPartsSignalApproxSpline{s}) %��������� �����������
        LengthFragment = length(PartsSignalApproxSpline{s}(SaveIndex + 1:IndexPartsSignalApproxSpline{s}(i),1)); %����� �������� ���������
        NumbPeriodDecrement = floor((LengthFragment - 1)/PeriodDecrement); %����� ��������, ��������������� �������� ������� � ������ ���������
        Decrement{i} = []; %������������� ����������
        if NumbPeriodDecrement ~= 0
            TempIndexStart = SaveIndex + 1; %������ �������
            for j = 1:NumbPeriodDecrement
                TempIndexEnd = TempIndexStart + PeriodDecrement; %����� �������
                Decrement{i}(j) = abs(PartsSignalApproxSpline{s}(TempIndexStart,2)/PartsSignalApproxSpline{s}(TempIndexEnd,2)); %���������� ���������� ���������
                TempIndexStart = TempIndexEnd;
            end
        end
        if isempty(Decrement{i})
            Decrement{i} = 0; %��������� � ������ ��������� ���������
        end
        SaveIndex = IndexPartsSignalApproxSpline{s}(i);
    end 
    TableDecrementVisualize{s} = CreateTableVisualize(Decrement); %C������� ������� ��� ������������ ����������� �� ����� (1 - ����, 3 - ���)
end

%������������� ����������� ������
if length(IndexPartsExpSignalTemp{1}) <= length(IndexPartsExpSignalTemp{3})
    IndexPartsExpSignalFull = IndexPartsExpSignalTemp{1};
else
    IndexPartsExpSignalFull = IndexPartsExpSignalTemp{3};
end
%��������� ����� ������
IndexPartsExpSignalFull = [PartsExpSignalTemp{1}(1,1);IndexPartsExpSignalFull];
k = 1; j = 1;
for i = 1:length(IndexPartsExpSignalFull) %���� �� ������ ��������
    while 1
        if PartsExpSignalTemp{1}(j,1) > IndexPartsExpSignalFull(i) %��������� � ������� ������ ��������
            LeftExpIndexTemp(k,1) = PartsExpSignalTemp{1}(j,1); %������ ����� �������
            k = k + 1; 
            break
        end
        j = j + 1;
    end
end
LeftExpIndexTemp(1) = []; %�������� ������ �����������
IndexPartsExpSignalFull = sort([LeftExpIndexTemp;IndexPartsExpSignalFull]); %����� + ������ �������
IndexPartsExpSignalFull(end + 1) = PartsExpSignalTemp{1}(end,1); %��������� ������ ������� ���������� ���������
%������������ ������� ��������
IndexPartsExpSignalFull(end + 1) = length(Signal); %������ ������� ���������
IndexPartsExpSignalFull = [1;IndexPartsExpSignalFull]; %����� ������� ���������
    %��������� ����������� ����������
k = 1;
for i = 1:2:length(IndexPartsExpSignalFull) - 1 %���� �� �������� �������
    for j = 1:length(Signal)
        if j >= IndexPartsExpSignalFull(i) && j < IndexPartsExpSignalFull(i + 1) %�������� ��������� � �������
            PartsExpSignal{2}(k,:) = [j Signal(j) 0]; 
            if j == IndexPartsExpSignalFull(i + 1)-1 %��� ������ �������
                PartsExpSignal{2}(k,3) = 1; %������������� ����� ���������
            end
            k = k + 1;
        end
    end
end
    %��������� ��������� ����������
k = 1;
for i = 2:2:length(IndexPartsExpSignalFull) - 2 %���� �� ������ �������
    for j = 1:length(Signal)
        if j >= IndexPartsExpSignalFull(i) && j <= IndexPartsExpSignalFull(i + 1) %�������� ��������� � �������
            PartsExpSignal{1}(k,:) = [j Signal(j) 0];
            if j == IndexPartsExpSignalFull(i + 1) %��� ������ �������
                PartsExpSignal{1}(k,3) = 1; %������������� ����� ���������
            end
            k = k + 1; %���������� ��������
        end
    end
end
    %��������� �������� ���������� ��� ������� ������
IndexPartsExpSignal{1} = find(PartsExpSignal{1}(:,3) == 1); %��������� ������ ��������� ����������
IndexPartsExpSignal{2} = find(PartsExpSignal{2}(:,3) == 1); %��������� ������ ������� ����������
end

function TableVisualize = CreateTableVisualize(Signal) %�������� ������ ������� ��� ���������  
    if ~iscell(Signal), error('�������� ������ �����'), end %������� �������� ���������
    RowsTable = length(Signal); %����� ����� � �������
    MaxLength = 0; %��������� �������� ������� ���������
    for i = 1:RowsTable
        if length(Signal{i}) > MaxLength %����� ������������ ����� ���������
            MaxLength =  length(Signal{i});
        end
    end
    ColsTable = MaxLength;
    TableVisualize = zeros(RowsTable,ColsTable); %��������� ������ ��� ������� ��� �����������
    %��������� ������ � �������
    for i = 1:RowsTable %�� ������� ����
        for j = 1:length(Signal{i})
            TableVisualize(i,j) = Signal{i}(j); %������������ ������ ������� � ������
        end
    end
end