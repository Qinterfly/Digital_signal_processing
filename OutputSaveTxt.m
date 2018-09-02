function OutputSaveTxt(OutputSignal, FileName, TechnicalData, Path, InputFileName)
%���������� �������� ������, ������������ ��� ������ ��������� �������

Path = strcat(Path, InputFileName);
if ~isdir(Path) %�������� ���������� ��� ������� �������
    mkdir(Path);
end
fileID = fopen(strcat(Path,'/',FileName,'.txt'),'w'); %�������� ����� ��� ������
TechnicalData{end} = num2str(size(OutputSignal,1)); %������ � ����������� �������� �������� ����� ��������� �������
for i = 1:length(TechnicalData)
    fprintf(fileID,'%s \r\n',TechnicalData{i}); %������ ����������� ��������
end
formatSpec = '%f \r\n'; %������ ������ ��������
if size(OutputSignal,2) > 1
    dlmwrite(strcat(Path,'/',FileName,'.txt'),OutputSignal,'-append','delimiter','\t','newline','pc');
else
    fprintf(fileID,formatSpec,OutputSignal); %������ ������� � ������
end
fclose(fileID); %�������� �����
end

