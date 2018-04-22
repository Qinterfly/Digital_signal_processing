function [SpectrumSignalVisualize Frequency] = FindSpectrum(PartsSignalGlued, SampleRate, LengthFFT, Mode, Accuracy) 
%��������� ������� � ������������ ������� ��� ���������� ��������������� ����������� �����������

%�������� ���������� �������� ������
if ~iscell(PartsSignalGlued)
    error('�������� ������ ������');
end
clear Temp; %������� ������������� ����������

LevelsNumb = length(PartsSignalGlued); %������� ����� �������
if LengthFFT == 0 %����� ���������� ��������� ����� ����������
    %�������������� ����� ��� �������� ������� �������
    MinNFFT = 1e9; %��������� ��������� ��������
    for i = 1:LevelsNumb %���� �� ���� �������
        L = size(PartsSignalGlued{i},1); %����� ������ �������
        NFFT = 2^nextpow2(L); %����� ���
        if NFFT < MinNFFT %����� ����������� ����� ��� � �������
            MinNFFT = NFFT;
        end
    end
else
    MinNFFT = (LengthFFT - 1)*2; %���������� � ��� ����� �� �������� �����
end
switch Mode
    case 'FFT' %���
        Frequency = SampleRate*(1:MinNFFT/2)/MinNFFT/100; %���������� ������� �������
        for i = 1:LevelsNumb %���� �� ���� �������
            Y = fft(PartsSignalGlued{i}(:,2),MinNFFT); %������������ ���
            Y = Y(1:MinNFFT/2); %�������� ������������ �����
            P = abs(Y); %������� ���������
            SpectrumSignal{i} = P; %������ �������� �������
        end
    case 'Welch' %������������ ��������� �������� �� �����
        for i = 1:LevelsNumb %���� �� ���� �������
            [SpectrumSignal{i}, Frequency] = pwelch(PartsSignalGlued{i}(:,2), MinNFFT/2, MinNFFT/4, MinNFFT, 1/(SampleRate*1e-6));
        end
end
%����������������� �������
for i = 1:LevelsNumb
    [SpectrumSignal{i},~] = ApproxSpline(Frequency, Frequency, SpectrumSignal{i}, Accuracy, 0);
end
%�������� ������� ��� ������������
SpectrumSignalVisualize = zeros(LevelsNumb, MinNFFT/2); %�������� ������ ��� ������� ������������
for i = 1:LevelsNumb
    for j = 1:length(SpectrumSignal{i})
        SpectrumSignalVisualize(i,j) = SpectrumSignal{i}(j); %���������� ��������� �� ������� ������
    end
end
SpectrumSignalVisualize = SpectrumSignalVisualize'; %������������� �������

end

