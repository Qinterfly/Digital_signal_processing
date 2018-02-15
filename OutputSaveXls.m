function OutputSaveXls(OutputSignal, TitleLevels, FileName, TechnicalData, Path, InputFileName)
%���������� ����������� ������������� ������� � ���� ������ � .xls �������

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
%�������� ��������� �������
k = 1; %��������� �������� ���������
for i = double('A'):double('Z')
    XlRangeBase{k} = char(i); % A - Z �������
    k = k + 1; %���������� ���������
end
TempLen = length(XlRangeBase);
    %�������� �������� �������
for i = 1:TempLen
   for j = 1:TempLen
       XlRangeBase{end + 1} = strcat(XlRangeBase{i}, XlRangeBase{j}); %AA - ZZ ��������
   end
end
%������ ���������� � ����
xlswrite(FullFileName, TechnicalData, SpreadSheet, 'A1'); %������ ����������� ��������
XlRange = {1, length(TechnicalData) + 1}; %���������� ������ ��� ������ (1 == 'A', N ==..)
for i = 1:length(OutputSignal)
    xlswrite(FullFileName, {strcat('#', num2str(TitleLevels(i)))}, SpreadSheet, strcat(XlRangeBase{XlRange{1}}, num2str(XlRange{2}))); %��� ������
    if ~isempty(OutputSignal{i}) %������� ������, � ������ ������� �������
        xlswrite(FullFileName, OutputSignal{i}, SpreadSheet, strcat(XlRangeBase{XlRange{1}}, num2str(XlRange{2} + 1))); %������ ������� ��� ������� ������
    else
        xlswrite(FullFileName, {'Empty'}, SpreadSheet, strcat(XlRangeBase{XlRange{1}}, num2str(XlRange{2} + 1))); %������ ������� ��� ������� ������
    end
    XlRange{1} = XlRange{1} + size(OutputSignal{i}, 2) + 1; %��������� �� ������� �������
end

end

