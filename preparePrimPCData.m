%% STEP1: Loop through Data table,move same-case rows into separate tables, join the tables
CaseTable1 = cell2table(cell(0,size(DataTemp,2)));
CaseTable1.Properties.VariableNames = DataTemp.Properties.VariableNames;
CaseTable2 = cell2table(cell(0,61));
CaseTable2.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable3 = cell2table(cell(0,61));
CaseTable3.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable4 = cell2table(cell(0,61));
CaseTable4.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable5 = cell2table(cell(0,61));
CaseTable5.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable6 = cell2table(cell(0,61));
CaseTable6.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable7 = cell2table(cell(0,61));
CaseTable7.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable8 = cell2table(cell(0,61));
CaseTable8.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable9 = cell2table(cell(0,61));
CaseTable9.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
CaseTable10 = cell2table(cell(0,61));
CaseTable10.Properties.VariableNames = DataTemp.Properties.VariableNames([1,19:end]);
caseTableArray = {CaseTable1,CaseTable2,CaseTable3,CaseTable4,CaseTable5,CaseTable6,CaseTable7,CaseTable8,CaseTable9,CaseTable10};
clearvars CaseTable1 CaseTable2 CaseTable3 CaseTable4 CaseTable5 CaseTable6 CaseTable7 CaseTable8 CaseTable9 CaseTable10;

for row = 1:size(DataTemp,1)
    caseNo = DataTemp.case_no{row};
    for n = 1:size(caseTableArray,2)
        currentTable = caseTableArray{n};
        if any(ismember(currentTable.case_no, caseNo))
            continue
        elseif n == 1
            caseTableArray{n} = [caseTableArray{n}; DataTemp(row,:)];
            break
        else
            caseTableArray{n} = [caseTableArray{n}; DataTemp(row,[1,19:end])];
            break     
        end
    end
end

for t = 2:size(caseTableArray,2)
    if size(caseTableArray{t},1)>0
        caseTableArray{1} = outerjoin(caseTableArray{1},caseTableArray{t},'Keys',1);
    end
end

CaseTable = caseTableArray{1};

%% STEP2: Loop through cols & rows of CaseTable Table, add questions as cols of Feature Table and ans as values
FeaturesTable = CaseTable(:,[1 3 5:18]);
for c = 1:size(CaseTable,2)
    currentColName = CaseTable.Properties.VariableNames{c};
    if strfind(currentColName,'questxt')
        for r = 1:size(CaseTable,1)
           %Add the question as a feature
           if isempty(CaseTable{r,c}{1})
               continue
           elseif ~any(ismember(FeaturesTable.Properties.VariableNames, lower(regexprep(CaseTable{r,c},'[\W\d]',''))))
               tempCol = cell(size(FeaturesTable,1),1);
               tempCol(:,1) = {'Unsure'};
               eval(['FeaturesTable.' char(lower(regexprep(CaseTable{r,c},'[\W\d]',''))) '=tempCol;'])
           end
           %Add the answer as a value & replace with 'Unsure' if an unsuretiy
           ansVal = CaseTable{r,c+1}{1};
           if isempty(ansVal) || strcmp(ansVal,'Unsure')|| strcmp(ansVal,'#N/A') || strcmp(ansVal,'Not known') || strcmp(ansVal,'Not specific') || strcmp(ansVal,'Not assessed') || strcmp(ansVal,'Nil specific')
               eval(['FeaturesTable.' char(lower(regexprep(CaseTable{r,c},'[\W\d]',''))) '(' num2str(r) ')' '={''Unsure''};'])
           else
               eval(['FeaturesTable.' char(lower(regexprep(CaseTable{r,c},'[\W\d]',''))) '(' num2str(r) ')' '={ansVal};'])
           end
        end
    end
end

%% STEP3: Loop through columns in FeaturesTable, store % blanks overall & per pc in FeaturesAnalysis table
% Create struct for current pc with key for each question features
pcList = {'overall'}
FeaturesAnalysis = cell2table(cell(size(FeaturesTable,2),size(pcList,2)));
FeaturesAnalysis.Properties.VariableNames = pcList;
FeaturesAnalysis.Properties.RowNames = FeaturesTable.Properties.VariableNames;
for c = 17:size(FeaturesTable,2)
    %Set missing count variable =0
    pcMissing = 0;
    %Count missing values for given feature
    for r = 1:size(FeaturesTable,1)
        if strcmp(FeaturesTable{r,c}{1},'Unsure') 
            pcMissing = pcMissing+1;
        end         
    end
    % Add Cacluated Percentage for given feature to all pc structs
    pcOverall = size(FeaturesTable,1);
    FeaturesAnalysis.overall{c} = (pcOverall-pcMissing)/pcOverall;
end

%% STEP4: Create X (comprised of features with >50% comlete data) & Y inputs for top 10 PCs and overall
% Initialize X for given pc
XY_pc = FeaturesTable(:,[2 15:16]);

%Add features with >50% data within respective pcs
for c = 17:size(FeaturesTable,2)
    if FeaturesAnalysis.overall{c} >= .5
        XY_pc = [XY_pc FeaturesTable(:,c)];
    end
end

%% STEP5: Detect triageSVM performance on each X/Y
pcResults = triageSVM(XY_pc(:,2:end),XY_pc.(1));

