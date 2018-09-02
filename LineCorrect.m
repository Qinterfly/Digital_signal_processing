function FunCorrect = LineCorrect(Arg, Fun)
%�������� ������������� �������

LowFrequencyLine = (Fun(end) - Fun(1)).*(Arg - Arg(1))./(Arg(end) - Arg(1)) + Fun(1); %������, ����������� ����� �������
FunCorrect = Fun - LowFrequencyLine; %��������� �������������� �����

end

