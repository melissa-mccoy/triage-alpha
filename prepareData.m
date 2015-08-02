%% Loop through Data table,move same-case rows into separate tables, join the tables
CaseTable1 = table;
CaseTable1.case_no = {};
CaseTable2 = table;
CaseTable2.case_no = {};
CaseTable3 = table;
CaseTable3.case_no = {};
CaseTable4 = table;
CaseTable4.case_no = {};
CaseTable5 = table;
CaseTable5.case_no = {};
CaseTable6 = table;
CaseTable6.case_no = {};
CaseTable7 = table;
CaseTable7.case_no = {};
CaseTable8 = table;
CaseTable8.case_no = {};
CaseTable9 = table;
CaseTable9.case_no = {};
CaseTable10 = table;
CaseTable10.case_no = {};
caseTableArray = {CaseTabe1,CaseTabe2,CaseTabe3,CaseTabe4,CaseTabe5,CaseTabe6,CaseTabe7,CaseTabe8,CaseTabe9,CaseTabe10};

for row = 1:size(DataTemp,1)
    caseNo = DataTemp.case_no(row);
    for n = 1:size(caseTableArray)
        currentTable = caseTableArray(n);
        if any(ismember(currentTable.case_no, caseNo))
            continue
        elseif n == 1
            currentTable = DataTemp(row,2:end);
            break
        else
            currentTable = DataTemp(row,19:end);
            break     
        end
    end
end

for t = 2:size(caseTableArray,2)
    CaseTable1 = join(CaseTable1,caseTableArray(t),'Keys',1);
end

CaseTable = CaseTable1;
