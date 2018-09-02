function [SignalApprox, SignalApproxDerivative] = ApproxSpline(TimeInput, TimeInterpolate, Signal, Accuracy, DerivativeDegree)
%������������� ������� B-��������� � �������� �������� �����������

SignalApproxCoeffs = csaps(TimeInput, Signal, Accuracy); %������������ ����������������� B - �������
SignalApprox = fnval(SignalApproxCoeffs, TimeInterpolate); %���������� �������� ������� ��� ��������� ����������� ������ �����
if DerivativeDegree ~= 0 %������������� ���������� �����������
    SignalApproxDerivativeCoeffs = fnder(SignalApproxCoeffs, DerivativeDegree); %���������� ����������� B - �������
    SignalApproxDerivative = fnval(SignalApproxDerivativeCoeffs, TimeInterpolate); %���������� �������� ������� ��� �������� ����������� ������ �����
else
    SignalApproxDerivative = 0;    
end

end

