function OutputSaveInformation(Struct, FileName, Path, InputFileName)
%C��������� ��������� ����������

%������ �������� ������ �� ���������
HeadersRows = Struct.HeadersRows;
HeadersCols = Struct.HeadersCols;
Values = Struct.Values;

Path = strcat(Path,'\����������\',InputFileName);
if ~isdir(Path) %�������� ���������� ��� ������ ��������
    mkdir(Path);
end
fileID = fopen(strcat(Path,'/',FileName,'.txt'),'w'); %�������� ����� ��� ������

%������������ �������������� ������� ��� ������
HeadersRows = char(['Arguments',HeadersRows]);
HeadersCols = char([HeadersRows(1,:),HeadersCols]); %��������� �������
Values = num2str(Values); 
%������ ����������
    %���������� �� ��������
for i = 1:size(HeadersCols,1)
    fprintf(fileID,'%s ',HeadersCols(i,:));
end
    %������ + ��������� �� �������
Table = [HeadersRows(2:end,:),Values];
for i = 1:size(Table,1) 
    fprintf(fileID,'\r\n'); %������� �� ����� ������
    fprintf(fileID,'%s',Table(i,:));
end
fclose(fileID); %�������� �����

end

