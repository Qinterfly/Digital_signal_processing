function [PartsSignalGlued Fail] = OptimalGluing(IndexPartsSignal,FixPartsSignal,PartsSignalDerivative,CutIntervalProcent,ShiftIntervalProcent)
%������� ������ ���������� �� �������� �������� �������� ����� �������� ��
%������� � ����������� �� �������
%ShiftIntervalProcent - �������� ����� ����������� ������� � ���������
%CutIntervalProcent - ������� ������� ��� �������

LevelsNumb = length(IndexPartsSignal);
for i = 1:LevelsNumb
    if isempty(IndexPartsSignal{i}) %��������� ������� ������
        PartsSignalGlued{i} = zeros(500,2); 
    else
        SaveIndex = IndexPartsSignal{i}(1); %����� ����� ����������� ���������
        PartsSignalGlued{i} = FixPartsSignal{i}(1:SaveIndex,:); %������ ��������� ������� ��� ����������� ���������
        PartsSignalDerivativeGlued{i} = PartsSignalDerivative{i}(1:SaveIndex,:); %������ ����������� ��� ����������� ���������
        Fail{i} = 0; %��������� �������� ������ ��� �������� ������
        for j = 2:length(IndexPartsSignal{i})
            LengthIntervalRight = IndexPartsSignal{i}(j) - SaveIndex; %����� �������� ���������
            IndexFrag = find(PartsSignalGlued{i}(:,3) == 1);
            if length(IndexFrag) ~= 1 %�������� ������� ���������
                LengthIntervalLeft = IndexFrag(end) - IndexFrag(end - 1); %����� ������ ���������
            else
                LengthIntervalLeft = IndexFrag;
            end
            CutValue = ceil(CutIntervalProcent*LengthIntervalRight); %����� ����� ��� ����� ������
            ShiftValue = ceil(ShiftIntervalProcent*LengthIntervalLeft); %����� ����� ��� ������ �����
            ErrorComplex = {}; %��������� ������� ������������
            MinErrorLocal = []; 
            for m = 0:ShiftValue
                MarkValueSignal = PartsSignalGlued{i}(end - m,2); %�������� ��������� ����� ����������� ���������
                MarkValueSignallDerivative = PartsSignalDerivativeGlued{i}(end - m,2); %�������� ����������� �� ��������� ����� ����������� ���������
                ErrorComplex{m + 1} = []; %���������� ��������� ������
                k = 1; %��������� ������� �����
                for s = SaveIndex + 1:IndexPartsSignal{i}(j) - CutValue %���� �� ���� ������ ���������� ��������� �� �����
                    if PartsSignalDerivative{i}(s,2)*MarkValueSignallDerivative >= 0
                        ErrorComplex{m + 1}(k,1) = s; %���������� ����� �����
                        ErrorComplex{m + 1}(k,2) = abs(FixPartsSignal{i}(s,2) - MarkValueSignal); %������� ���������
                        ErrorComplex{m + 1}(k,3) = abs(PartsSignalDerivative{i}(s,2) - MarkValueSignallDerivative); %������� ����������� �� ���������
                        ErrorComplex{m + 1}(k,4) = (ErrorComplex{m + 1}(k,2) + ErrorComplex{m + 1}(k,3))/2; %������� ����� �������� ��������� � ����������� �� ��������� (������� mean)
                        k = k + 1; %���������� �������� �����
                    end
                end
                if ~isempty(ErrorComplex{m + 1}) %�������� ������� ����������� �����
                    [MinErrorLocal(m + 1) NumbErrorRowLocal(m + 1)] = min(ErrorComplex{m + 1}(1:end,4)); %���������� ���������� ������ ����� ������ ���������� ���������
                else
                    MinErrorLocal(m + 1) = Inf; %��� ��������� ������ ������� (��������)
                    NumbErrorRowLocal(m + 1) = Inf;
                    Fail{i} = Fail{i} + 1; %���������� �������� ������
                end
            end
            if ~min(MinErrorLocal == Inf) %���� ���� ������� �������
                %����� ������� ��������
                [MinErrorGlobal IndexErrorGlobal] = min(MinErrorLocal); %������� �� �������� �������
                NumbErrorRowGlobal = NumbErrorRowLocal(IndexErrorGlobal); %������ � ������ ����������� ������
                RightIndex = ErrorComplex{IndexErrorGlobal}(NumbErrorRowGlobal,1) + 1; %����� ��������� �� �����������
                LeftIndex = size(PartsSignalGlued{i},1) - IndexErrorGlobal + 1; %������ ����� ������ ���������
                %�������� ���������� ��������� �� ������� ��������
                PartsSignalGlued{i} = PartsSignalGlued{i}(1:LeftIndex,:); %���������
                PartsSignalGlued{i}(LeftIndex,3) = 1; %������������ ����� ���������
                PartsSignalDerivativeGlued{i} = PartsSignalDerivativeGlued{i}(1:LeftIndex,:); %�����������
                PartsSignalDerivativeGlued{i}(LeftIndex,3) = 1; %������������ ����� ���������
                %������������� ����� ������
                PartsSignalGlued{i} = [PartsSignalGlued{i}; FixPartsSignal{i}(RightIndex:IndexPartsSignal{i}(j),:)]; %������� ���������� ���������
                PartsSignalDerivativeGlued{i} = [PartsSignalDerivativeGlued{i}; PartsSignalDerivative{i}(RightIndex:IndexPartsSignal{i}(j),:)]; %������� ���������� ����������� �� ���������
            end
            SaveIndex = IndexPartsSignal{i}(j); %������ ������� ����� ���������
        end
    end
%PartsSignalGlued{i}(:,2) = PartsSignalGlued{i}(:,2) - PartsSignalGlued{i}(1,2); %��������� �������� ����� �������
end

end

