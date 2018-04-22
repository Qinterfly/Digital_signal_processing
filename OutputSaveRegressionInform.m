function OutputSaveRegressionInform(RegressionTable, Title, FileName, TechnicalData, Path, InputFileName)
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
SpreadSheet = {'����������� ��������', '������� �����������',... 
              '��������� ���������', '����� ������'}; %�������� ������� �������� ��������
%�������� ���������� �������
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
%������ �������� ������ 
TitleMask{1,1} = '\'; %Placeholder
for i = 1:length(Title.Rows)
    TitleMask{1+i,1} = Title.Rows{i}; %�� �������
end
for j = 1:length(Title.Cols)
    TitleMask{1,1+j} = Title.Cols{j}; %�� ��������
end
BeginTitleInd = [2, 2]; %������� ������ �������� ������ (������, �������)
%������������ ������ ���������� ��������� � ������
LevelsNumb = size(RegressionTable{1}); %����� ������� �� ������� � ��������
ElementNumb = length(RegressionTable); %����� ������������� ����������
for p = 1:ElementNumb
    ResTable{p} = TitleMask; %������ ������� �������
end
for i = 1:LevelsNumb(1)    
    for j = 1:LevelsNumb(2)
        for s = 1:ElementNumb
            OriginalData = RegressionTable{s}(i,j); %����������������� ������ � �������
            Pointer = [BeginTitleInd(1)+i-1, BeginTitleInd(2)+j-1]; %��������� �� ������� ������
            ResTable{s}{Pointer(1),Pointer(2)} = strrep(num2str(OriginalData),'.',','); %������ ��������
        end
    end
end
%���������� ������
xlswrite(FullFileName, TechnicalData, SpreadSheet{1}); %������� ����������� ��������
for s = 1:ElementNumb
    xlswrite(FullFileName, ResTable{s}, SpreadSheet{s+1}); %������ �������������� ������
end

end


