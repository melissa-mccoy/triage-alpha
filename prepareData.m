%% Loop through Data table and combine question & answer columns from the same cases
caseLog = [];
caseTableArray = {};
CaseTable = table;
CaseData.case_no = {};

for row = 1:size(DataTemp,1)
    caseNo = DataTemp.case_no(row);
    for n = 1:size(caseTableArray)
        caseTable = caseTableArray(n);
        if any(ismember(caseTable.case_no, caseNo))
            if n<>size(caseTablesArray)
                continue
            else
                eval([strcat('CaseTable',int2str(n+1)) '=table;'])
                eval([strcat('CaseTable',int2str(n+1)) '.case_no = {};'])
                eval(['caseTableArray(end+1) = {' strcat('CaseTable',int2str(n+1)) '};'])
            end
        elseif 
    end
        
        
    DataTemp(2:end)
    if any(ismember(CaseData.case_no, caseNo))
        
    if strfind(char(OdysseyData8.Properties.VariableNames(col)),'questxt') == 1
        
    end
    end

    