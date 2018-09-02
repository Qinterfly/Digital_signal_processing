function [SignalApprox, SignalApproxDerivative] = ApproxSpline(TimeInput, TimeInterpolate, Signal, Accuracy, DerivativeDegree)
%Аппроксимация функции B-сплайнами с заданной степенью сглаживания

SignalApproxCoeffs = csaps(TimeInput, Signal, Accuracy); %Коэффициенты аппроксимирующего B - сплайна
SignalApprox = fnval(SignalApproxCoeffs, TimeInterpolate); %Вычисление значений функции для заданного дискретного набора точек
if DerivativeDegree ~= 0 %Идентификатор вычисления производной
    SignalApproxDerivativeCoeffs = fnder(SignalApproxCoeffs, DerivativeDegree); %Вычисление производной B - сплайна
    SignalApproxDerivative = fnval(SignalApproxDerivativeCoeffs, TimeInterpolate); %Вычисление значений функции для заданног дискретного набора точек
else
    SignalApproxDerivative = 0;    
end

end

