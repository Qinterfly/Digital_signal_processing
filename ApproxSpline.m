function [SignalApprox, SignalApproxDerivative] = ApproxSpline(Time,Signal,Accuracy,DerivativeDegree)
%Аппроксимация функции B-сплайнами с заданной степенью сглаживания

SignalApproxCoeffs = csaps(Time, Signal, Accuracy); %Коэффициенты аппроксимирующего B - сплайна
SignalApprox = fnval(SignalApproxCoeffs,Time); %Вычисление значений функции для заданног дискретного набора точек
if DerivativeDegree ~= 0 %Идентификатор вычисления производной
    SignalApproxDerivativeCoeffs = fnder(SignalApproxCoeffs,DerivativeDegree); %Вычисление производной B - сплайна
    SignalApproxDerivative = fnval(SignalApproxDerivativeCoeffs,Time); %Вычисление значений функции для заданног дискретного набора точек
else
    SignalApproxDerivative = 0;    
end

end

