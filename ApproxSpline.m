function [SignalApprox, SignalApproxDerivative] = ApproxSpline(Time,Signal,Accuracy,DerivativeDegree)
%������������� ������� B-��������� � �������� �������� �����������

SignalApproxCoeffs = csaps(Time, Signal, Accuracy); %������������ ����������������� B - �������
SignalApprox = fnval(SignalApproxCoeffs,Time); %���������� �������� ������� ��� �������� ����������� ������ �����
if DerivativeDegree ~= 0 %������������� ���������� �����������
    SignalApproxDerivativeCoeffs = fnder(SignalApproxCoeffs,DerivativeDegree); %���������� ����������� B - �������
    SignalApproxDerivative = fnval(SignalApproxDerivativeCoeffs,Time); %���������� �������� ������� ��� �������� ����������� ������ �����
else
    SignalApproxDerivative = 0;    
end

end

