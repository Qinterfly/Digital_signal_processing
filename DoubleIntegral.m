function [SignalSecondIntegralOutput] = DoubleIntegral(Time, Signal, CutOffFrequency, SampleRate)
%������� �������������� ��������� ������� c ���������� ������� ������

PolyDegree = 20; %������� ���������������� ������� ����� ��������
    %������ ��������
SignalFirstIntegral = cumsum(Signal); %���������� ������� ��������� �� ������ ��������
MeanLineCoeffs = polyfit(Time,SignalFirstIntegral,PolyDegree); %���������� ������������� ���������������� ��������
MeanLine = polyval(MeanLineCoeffs,Time); %���������� ������� ����� �� ������������� ��������
SignalFirstIntegralHighFreq = SignalFirstIntegral - MeanLine; %��������� �������������� ������������ ��� ������� ���������
SignalFirstIntegralHighFreq = SignalFirstIntegralHighFreq - SignalFirstIntegralHighFreq(1); %�������� ��������� � ������� �����
    %������ ��������
SignalSecondIntegral = cumtrapz(SignalFirstIntegralHighFreq); %������ �������������� �������
if isempty(CutOffFrequency) || CutOffFrequency == 0 %�������� ������� �������
    SignalSecondIntegralOutput = SignalSecondIntegral; %��������� ������� ��� �������
else
    CutOffFrequencyFilter = CutOffFrequency*200; %������� ������� ��� ����������
    [b, a] = butter(4,CutOffFrequencyFilter/(SampleRate/2),'high'); %��������� ���������� ��� �����������
    SignalSecondIntegralOutput = filter(b,a,SignalSecondIntegral); %���������� �������
end
end

