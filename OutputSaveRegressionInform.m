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
              '��������� ���������', '����� ������', '���������', '������������ �������'}; %�������� ������� �������� ��������
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
ElementNumb = length(RegressionTable); %����� ������������� ����������
%������������ ������ ���������� ��������� � ������
for s = 1:length(RegressionTable)
    LevelsNumb{s} = size(RegressionTable{s}); %����� ������� �� ������� � �������� ��� ������� ���������
end
for p = 1:ElementNumb
    if ~isvector(RegressionTable{p})
        ResTable{p} = TitleMask; %������ ������� �������
    else
        ResTable{p} = TitleMask(:,1); %������ ������� �������
    end
end
%������ �������� ��������
for s = 1:ElementNumb %���� �� ����� ����������
    for i = 1:LevelsNumb{s}(1) %����� �� ������������ �������
        for j = 1:LevelsNumb{s}(2)
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


