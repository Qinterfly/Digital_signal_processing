function SettingsSave(SettingsOutput, Path, InputFileName)
%���������� �������� �������

if ~isempty(SettingsOutput) && size(SettingsOutput,2) ~= 2 %�������� ����� ������ ������
    error('������������ ����� ������ �������� ���������');
end
Path = strcat(Path, InputFileName);
if ~isdir(Path)
   mkdir(Path); %�������� ���������� ��� ������� ������� 
end
fileID = fopen(strcat(Path,'/','Settings.txt'),'w'); %�������� ����� ��� ������
for i = 1:length(SettingsOutput) %���� �� ���� �������
    if ischar(SettingsOutput{i,2}) %�������� ����������� ����
        if isempty(SettingsOutput{i,2}) %�������� ������� ������
            fprintf(fileID,'%s = %s\r\n',SettingsOutput{i,1},'null'); %������ �������� � ����            
        else
            fprintf(fileID,'%s = %s\r\n',SettingsOutput{i,1},SettingsOutput{i,2}); %������ �������� � ����
        end
    elseif SettingsOutput{i,2} < 1e-3 && SettingsOutput{i,2} ~= 0
        fprintf(fileID,'%s = %e\r\n',SettingsOutput{i,1},SettingsOutput{i,2}); %������ �������� � ����        
    else
        fprintf(fileID,'%s = %4.4f\r\n',SettingsOutput{i,1},SettingsOutput{i,2}); %������ �������� � ����
    end
end
fclose(fileID); %�������� �����
end

