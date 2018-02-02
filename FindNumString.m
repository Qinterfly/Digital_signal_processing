function Numbers = FindNumString(String)
%����� ����� � �������� ������

if ~ischar(String)
   error('�������� ������ ������� ������'); 
end

k = 1; %������� ��������� �����
StrNumbers{k} = ' '; %��������� ������ ��� �����
for i = 1:length(String)
    if ~isempty(str2num(String(i)))
        StrNumbers{k} = strcat(StrNumbers{k}, String(i)); %���������� ����� � �����
        if i ~= length(String)
           if isempty(str2num(String(i+1)))
                k = k + 1; %���������� �������� ��������� �����
                StrNumbers{k} = ' '; %��������� ������ ��� ��������� �����
           end
        end
    end
end
%�������� ����������� ������
if isempty(StrNumbers)
   Numbers = 0;
   return;
end
%���������� ���������� ����� � ������
for i = 1:length(StrNumbers)
    if StrNumbers{i} ~= ' '
        Numbers(i) = str2num(StrNumbers{i});
    end
end

end

