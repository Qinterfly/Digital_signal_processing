function OutputSaveXls(OutputSignal, TitleLevels, FileName, TechnicalData, Path, InputFileName)
%���������� ����������� ������������� ������� � ���� ������ � .xls �������
%����� ������� COM ������� Excel

%������ ���� ����������
Path = strcat(Path,'\����������\',InputFileName);
if ~isdir(Path) %�������� ���������� ��� ������� �������
   mkdir(Path);  
end
FullFileName = strcat(Path,'/',FileName,'.xls'); %������ ��� �����
if exist(FullFileName) == 2 %�������� ������������� �����
   delete(FullFileName); %��������
end
SpreadSheet = '����1'; %�������� ������� �������� ��������
%�������� ������������� �������
    %����������� ��������
for i = 1:length(TechnicalData)
    ResultTable{i,1} = (TechnicalData{i});
end
ResultTable{i + 1,1} = ''; %������ ����� ��������� �������
BeginBaseInd = i + 2; %������ ������ �������� ������
    %�������� ������
EndColInd = 1;
for i = 1:length(OutputSignal)
    TempArrayToCell = '';
    ResultTable{BeginBaseInd, EndColInd} = TitleLevels(i); %����� �������
    if ~isempty(OutputSignal{i})
        for m = 1:size(OutputSignal{i}, 1) %���� �� ������� ������� ������
            for n = 1:size(OutputSignal{i}, 2) %���� �� �������� ������� ������,
                ResultTable{BeginBaseInd + m, EndColInd + n-1} = strrep(num2str(OutputSignal{i}(m, n)), '.', ','); %������ ������� ������ �� �������� � ��������� � ������� .xls
            end
        end
        EndColInd = EndColInd + size(OutputSignal{i}, 2) + 1; %���������� ������� ���������� �������
    else
        EndColInd = EndColInd + 2;
    end
end
xlswrite(FullFileName, ResultTable, SpreadSheet); %���������� �������

end

