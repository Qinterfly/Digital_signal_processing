function OutputSaveRegressionInform(RegressionParams, Title, FileName, Path, InputFileName)
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
%���������� ���������� ��������� � ������
ElementNumb = length(RegressionParams{1,1}); %����� ��������� � ���������
LevelsNumb = size(RegressionParams); %����� ������� �� ������� � �������� 
for i = 1:LevelsNumb(1)    
    for j = 1:LevelsNumb(2)
        for s = 1:ElementNumb
            OriginalData = RegressionParams{i,j}{s}; %����������������� ������ � �������
            switch s
                case 1 %��������� ������
                    if OriginalData(2) < 0 %���� ������������
                        Sign = '';
                    else
                        Sign = '+';
                    end
                    FormatData = [num2str(OriginalData(1)) 'x' Sign num2str(OriginalData(2))];
                case 2
                    FormatData = num2str(OriginalData); %��������� ���������
                case 3
                    FormatData = [num2str(OriginalData(1),'%.2e') '/' num2str(OriginalData(2),'%.2e')...
                        ' (' num2str(OriginalData(3),'%.2f') '/' num2str(OriginalData(4),'%.2f') ' ��)']; %����������� ����������
                case 4
                    FormatData = num2str(OriginalData, '%.2e'); %����� ������ ���������
            end
            RegressionParams{i,j}{s} = FormatData; %������ ��������������� ������
        end
    end
end

%������ ���������� 
ShiftCol = 4; ShiftRow = ElementNumb + 1; %�������� �������� ����� � ��������
for i = 1:LevelsNumb(1) %�� �������
    xlswrite(FullFileName, Title{1}(i), SpreadSheet, strcat('A', num2str(2+(i-1)*ShiftRow))); 
end
for i = 1:LevelsNumb(2) %�� ��������
    xlswrite(FullFileName, Title{2}(i), SpreadSheet, strcat(XlRangeBase{2+ShiftCol*(i-1)}, '1')); 
end

%������ ������
Pointer = [2, 2]; %���������� ������ ��� ������ (1 == 'A', N ==..)
for i = 1:LevelsNumb(1)
    %������ �������� � ���������
    for j = 1:LevelsNumb(2)
       xlswrite(FullFileName, RegressionParams{i,j}, SpreadSheet, strcat(XlRangeBase{Pointer(2)+(j-1)*ShiftCol}, num2str(Pointer(1))));
    end 
    Pointer(1) = Pointer(1) + ShiftRow; %���������� ������ ������   
end

end

