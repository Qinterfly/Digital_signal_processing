function Result = ProofAccel(FileNameDisplacement,... %��� ����� c �������������
                                FileNameAccel,... %��� ����� c �����������
                                StartReadNumbDisplacement,... %����� ��������� ������ ��� �����������
                                StartReadNumbAccel,... %����� ��������� ������ ��� ���������
                                LevelsStep,...%������ �������
                                Accuracy,... %�������� �������������
                                CutProcent,... %������� �������� ����������
                                CorrectDisplacement,... %������������� ��������� ������ ������������
                                CutOffFrequency,... %������� �����, ��
                                CorrectLengthMode,... %����� ���������� �� ����� 
                                AccuracyExp,... %�������� ��������� ���������������� ���������
                                LimExpAccelLevel,... %���������� �������� ��������� ��������� 
                                FreqDecrement,... %������� ��������� ���������� ���������
                                DepthGluing,... %������� �������                           
                                ModelApprox,... %������ ��������� ���������� ���������
                                OverlapFactor,... %����������� ���������� ������ �������
                                AccuracySpectrum,... %�������� ������������� ��������
                                NormalizeMode) %����� ���������� ������
                            
%% +==================== ���������� � ��������� ==========================+

%   �����: �.�. ������.
%   ������: 4.2
%   ���������:   
%   - ������ ���������
%  ����: 21.01.2019

%% +========================= ��������� ���� =============================+

TestMode = 0;
if TestMode %����� �������
    %������� ������� �������
    clc; clear variables; close all;
    %��������� ������� ����������
    addpath('Signals', 'Signals/������������� ������'); %�������� � �������� ������
    addpath('Export_fig'); %���������� ���������� �����������
    
    %% +========================= �������� ������ ============================+    
    
    FileNameDisplacement = '������  ��� ������1-1.txt'; %��� ����� c �������������
    FileNameAccel = '������  ��� ������1-1-���������.txt'; %��� ����� c �����������
    StartReadNumbDisplacement = 12; %����� ��������� ������ ��� �����������
    StartReadNumbAccel = 12; %����� ��������� ������ ��� ���������
    SaveMode = false; %����� ���������� ������
    
    LevelsStep = 14; %������ ������
    Accuracy = 1e-7; %�������� �������������
    ShowNumb = 2; %����� ����� ������ ��� �����������
    CutProcent = 0.2; %������� �������� ����������
    CorrectDisplacement = true; %������������� ��������� ������ ������������
    CutOffFrequency = 0.1; %������� �����, ��
    CorrectLengthMode = 'Input'; %����� ���������� �� ����� == (No, Maximum, Input)
    AccuracyExp = 1e-7; %�������� ��������� ���������������� ���������
    LimExpAccelLevel = 0.13; %���������� �������� ��������� ���������
    FreqDecrement = 5; %������� ��������� ���������� ���������
    DepthGluing = 0; %������� �������
    ModelApprox = 'B-Spline'; %������ ��������� ���������� ���������
    DeltaLevelsStepProcent = 0.1; %�������� ������� ������� � �����
    AccuracySpectrum = 0.95; %�������� ������������� ��������
    NormalizeMode = 0; %����� ���������� ������
    OverlapFactor = 0.2; %����������� ���������� �������
    
end

%% +======================= ���������� ������ ============================+

ReadMode = 'Complex'; %����� ���������� ������ � ����������� � ���������
if isempty(FileNameDisplacement) 
    ReadMode = 'Accel'; %����� ���������� ������ � ���������
end

switch ReadMode %���������� ������ � ����������� �� ������
    case 'Complex'
        %���������� ����� �����������
        [InputDataDisplacement, TechnicalDataDisplacement, Displacement] = ReadInput(FileNameDisplacement,StartReadNumbDisplacement);
        %���������� ����� ���������
        [InputDataAccel, TechnicalDataAccel, Accel] = ReadInput(FileNameAccel,StartReadNumbAccel);
        if length(Accel) ~= length(Displacement) %�������� ����������� ���� �������
            error('����� ������ ������� ����������� � ��������� �� ���������');
        end
    case 'Accel'
        %���������� ����� ���������
        [InputDataAccel TechnicalDataAccel Accel] = ReadInput(FileNameAccel,StartReadNumbAccel);
        [Accel,~] = PeakFilter(Accel, []); %�������� �������� ���������
end
Time = (1:length(Accel))'; %������ �������
SampleRate = str2num(TechnicalDataAccel{end - 2}); %������� �������������
clear InputDataAccel InputDataDisplacement; %������� ������������� ����������

%% +============================ ������ ==================================+

switch ReadMode %������ � ������� � ����������� �� ������
    case 'Complex'
        Accel = Accel - Accel(1); %���������� ��������� � ������� �����
        Displacement = Displacement - Displacement(1); %���������� ����������� � ������� �����
    case 'Accel'
        %���������� ����� ���������
        Accel = Accel - Accel(1); %���������� ��������� � ������� �����
        Displacement = DoubleIntegral(Time, Accel, CutOffFrequency, SampleRate); %��������� ����������� ������� ��������������� ���������
end  
if CorrectDisplacement %�������� ������ ��������� ��������� ������
    Displacement = LineCorrect(Time, Displacement); %��������� �������������� ����� ������� �����������
end
    %������������� ������� �����������
[DisplacementApprox, DisplacementApproxDerivative] = ApproxSpline(Time, Time, Displacement, Accuracy,1); %������������� B-���������
    %��������� �������
LineLevels = CreateLevels(DisplacementApprox, LevelsStep, OverlapFactor); 
LevelsNumb = size(LineLevels, 1); %����� ������� �������
[PartsDisplacement, IndexPartsDisplacement] = AssignLevels(Time, Displacement, LineLevels); %��������� ������ ����������� �� ��������
    %������������ ���������� ������� � �������� ���������
for i = 1:LevelsNumb
    PartsAccel{i} = zeros(size(PartsDisplacement{i})); %��������� ������ ��� ��������� ���������
    for j = 1:size(PartsDisplacement{i},1) %������ �� ����� ���������� 
        %������ ���������� ��������� �� ������� ���������� �����������
        PartsAccel{i}(j,1) = PartsDisplacement{i}(j,1);
        PartsAccel{i}(j,2) = Accel(PartsAccel{i}(j,1));
        PartsAccel{i}(j,3) = PartsDisplacement{i}(j,3);      
    end
end
    %������������ ������� � ������� ��������� �� ���������������� ���������
[PartsAccelApproxSpline,TableDecrementVisualize,PartsExpAccel,IndexPartsExpAccel,LimitsExpAccel] = FindExpDecrease(Accel,LimExpAccelLevel,AccuracyExp,FreqDecrement,SampleRate,ModelApprox);

    %��������� �������� ���������� � ���������� ����������� ��� ���������
[FixPartsAccel, PartsAccelDerivative, IndexPartsAccel,...
    ~, ~] = FixNormalizeDerivative(PartsAccel, IndexPartsDisplacement, CutProcent, NormalizeMode);
    %��������� �������� ���������� � ���������� ����������� ��� ����������
[FixPartsDisplacement, PartsDisplacementDerivative, IndexPartsDisplacement,...
    ~, ~] = FixNormalizeDerivative(PartsDisplacement, IndexPartsDisplacement, CutProcent, NormalizeMode);  
    %��������� �������� ���������� ��� ���������������� ��������� � ���������
[FixPartsExpAccel, PartsExpAccelDerivative, IndexPartsExpAccel,...
    ~,~] = FixNormalizeDerivative(PartsExpAccel, IndexPartsExpAccel, CutProcent, NormalizeMode);  

    %��������� �������������� ���������� �� ������������
[PartsMonotoneAccel, IndexMonotoneAccel] = ConstructMonotoneLevels(FixPartsAccel, FixPartsDisplacement, LineLevels);
    %��������� �������� ���������� � ���������� ����������� ��� �������
for s = 1:length(PartsMonotoneAccel) %���� �� Increase, Neutral, Decrease
   [FixPartsMonotoneAccel{s}, PartsMonotoneAccelDerivative{s}, IndexPartsMonotoneAccel{s}...
       ,~,~] = FixNormalizeDerivative(PartsMonotoneAccel{s}, IndexMonotoneAccel{s}, CutProcent, NormalizeMode); %�������� � ������������
end

switch CorrectLengthMode %����� ���������� ���������� � �����
    case 'Maximum' %� ������������
        MaxLength = 0; %��������� ��������� ��������
        for i = 1:LevelsNumb %����������� � ���������
            if length(FixPartsAccel{i}) > MaxLength %���������� ��������� ����� ���������
                MaxLength = length(FixPartsAccel{i});
            end
            if length(FixPartsDisplacement{i}) > MaxLength
                MaxLength = length(FixPartsDisplacement{i}); %���������� ��������� ����� �����������
            end           
            for j = 1:length(PartsMonotoneAccel) %���� �� ���������� ����������
                if length(PartsMonotoneAccel{j}{i}) > MaxLength
                    MaxLength = length(PartsMonotoneAccel{j}{i}); %���������� ��������� ����� [������������; �����������; ���������] ����������
                end
            end
        end
        LengthCorrect = MaxLength; %����� �������
        clear MaxLength;
    case 'Input'
        LengthCorrect = length(Accel); %����� ���������
    case 'No'
        LengthCorrect = 0;   
end
    %������� ���������� ��� ������� ������ ���������
[PartsAccelGlued, FailAccelGlued] = OptimalGluing(IndexPartsAccel,FixPartsAccel,PartsAccelDerivative,0.01,DepthGluing); %���������

[FixPartsExpAccelTurn, PartsExpAccelDerivativeTurn] = OverTurnFragments(FixPartsExpAccel,IndexPartsExpAccel,PartsExpAccelDerivative); %������� ���������
[PartsExpAccelGlued, FailExpAccelGlued] = OptimalGluing(IndexPartsExpAccel,FixPartsExpAccelTurn,PartsExpAccelDerivativeTurn,0.01,DepthGluing); %��������������� ���������
    %������� ���������� ���������� ��������
for s = 1:length(FixPartsMonotoneAccel) %���� �� Increase, Neutral, Decrease
    [PartsMonotoneAccelGlued{s}, FailPartsMonotoneAccelGlued{s}] = OptimalGluing(IndexPartsMonotoneAccel{s}, FixPartsMonotoneAccel{s}, PartsMonotoneAccelDerivative{s}, 0.01, DepthGluing);
end
    %������������� ���������� ���������� �� �����
PartsAccelGlued = CorrectLength(PartsAccelGlued, LengthCorrect, 0, DepthGluing); 
PartsExpAccelGlued = CorrectLength(PartsExpAccelGlued, LengthCorrect, 0, DepthGluing);
for s = 1:length(PartsMonotoneAccelGlued) %���� �� Increase, Neutral, Decrease
    PartsMonotoneAccelGlued{s} = CorrectLength(PartsMonotoneAccelGlued{s}, LengthCorrect, 0, DepthGluing);
end

    %�������������� ����� ��� �������� ������� �������
[SpectrumAccelGluedVisualize, FrequencyAccelGlued] = FindSpectrum(PartsAccelGlued, SampleRate, 0, 'Welch', AccuracySpectrum); %������ �������
for s = 1:length(PartsMonotoneAccelGlued) %���� �� Increase, Neutral, Decrease
    [SpectrumMonotoneAccelGluedVisualize{s}, FrequencyMonotoneAccelGlued{s}] = FindSpectrum(PartsMonotoneAccelGlued{s}, SampleRate, 0, 'Welch', AccuracySpectrum); %������ ���������� ����������
end
[SpectrumExpAccelGluedVisualize, FrequencyExpAccelGlued] = FindSpectrum(PartsExpAccelGlued, SampleRate, 0, 'Welch', AccuracySpectrum); %������ ������������� ���������� � ������� ����������

    %�������� ������ � ���������� ���������
Result{1} = Accel; %���������
Result{2} = Displacement; %�����������
Result{3} = PartsDisplacement; %����������������� �����������
Result{4} = PartsAccelGlued; %�������� �� ������� ���������
Result{5} = FrequencyAccelGlued; %������� �������� ���������
Result{6} = SpectrumAccelGluedVisualize; %����������� ������� ���������
Result{7} = PartsMonotoneAccelGlued; %������� ���������� ����������
Result{8} = FrequencyMonotoneAccelGlued; %������� �������� ���������� ����������
Result{9} = SpectrumMonotoneAccelGluedVisualize; %����������� ������� ���������� ����������
Result{10} = Time; %�����
Result{11} = LevelsNumb; %����� �������
Result{12} = LineLevels; %����� �������
Result{13} = DisplacementApprox; %������������������ �����������
Result{14} = DisplacementApproxDerivative; %������������������ ����������� �� �����������
Result{15} = PartsExpAccel; %�������������� ���������� ��������� �������
Result{16} = PartsExpAccelGlued; %������� �������������� ���������� ���������� �������  
Result{17} = LimitsExpAccel; %������������ ������� ���������
Result{18} = SpectrumExpAccelGluedVisualize; %����������� ������� �������������� ����������� ������� 
Result{19} = FrequencyExpAccelGlued; %������� ��� ����������� ������� ���������������� ����������� �������
Result{20} = TableDecrementVisualize; %������� ����������� ��������� �� �����
Result{21} = PartsAccelApproxSpline; %���������������� ������� ��� ������� ����

end