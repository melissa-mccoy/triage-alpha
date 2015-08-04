%% Loop through Data table,move same-case rows into separate tables, join the tables
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

%% Loop through cols & rows of CaseTable Table, add questions as cols of Feature Table and ans as values
FeaturesTable = CaseTable(:,[1 3 5:18]);
for c = 1:size(CaseTable,2)
    colName = CaseTable.Properties.VariableNames{c};
    if strfind(colName,'questxt')
        for r = 1:size(CaseTable,1)
           %Add the question as a feature
           if isempty(CaseTable{r,c}{1})
               continue
           elseif ~any(ismember(FeaturesTable.Properties.VariableNames, CaseTable{r,c}))
               tempCol = cell(size(FeaturesTable,1),1);
               tempCol(:,1) = {'Unsure'};
               eval(['FeaturesTable.' char(regexprep(CaseTable{r,c},'[\W\d]','')) '=tempCol;'])
           end
           %Add the answer as a value & replace with 'Unsure' if an unsuretiy
           ansVal = CaseTable{r,c+1}{1};
           if isempty(ansVal) || strcmp(ansVal,'Unsure')|| strcmp(ansVal,'#N/A') || strcmp(ansVal,'Not known') || strcmp(ansVal,'Not specific') || strcmp(ansVal,'Not assessed') || strcmp(ansVal,'Nil specific')
               eval(['FeaturesTable.' char(regexprep(CaseTable{r,c},'[\W\d]','')) '(' num2str(r) ')' '={''Unsure''};'])
           else
               eval(['FeaturesTable.' char(regexprep(CaseTable{r,c},'[\W\d]','')) '(' num2str(r) ')' '={ansVal};'])
           end
        end
    end
end

%% Loop through columns in FeaturesTable, store % blanks overall & per pc in FeaturesAnalysis table
% Create struct for current pc with key for each question features
pcList = {'overall','pc_chest','pc_throat','pc_abd','pc_dig','pc_ear','pc_temp','pc_skin','pc_eye','pc_head','pc_nose','pc_other'};
FeaturesAnalysis = cell2table(cell(size(FeaturesTable,2),size(pcList,2)));
FeaturesAnalysis.Properties.VariableNames = pcList;
FeaturesAnalysis.Properties.RowNames = FeaturesTable.Properties.VariableNames;
for c = 17:size(FeaturesTable,2)
    %Set missing count variables for each pc =0
    for pc = 1:size(pcList,2)
        eval([pcList{pc} 'Missing = 0;'])
    end
    %Count missing values for given feature
    for r = 1:size(FeaturesTable,1)
        if isempty(FeaturesTable{r,c}{1}) 
            overallMissing = overallMissing+1;
            for pc = 2:size(pcList,2)
                
                if eval(['strcmp(FeaturesTable.' pcList{pc} '(r),''No'')'])
                    eval([pcList{pc} 'Missing = ' pcList{pc} 'Missing+1;'])
                end
            end
        end         
    end
    % Add Cacluated Percentage for given feature to all pc structs
    rows = size(FeaturesTable,1);
    for pc = 1:size(pcList,2)
        eval(['FeaturesAnalysis.' pcList{pc} '{c} = (rows-' pcList{pc} 'Missing)/rows;'])
    end
end

%% Create X (comprised of features with >50% comlete data) & Y inputs for top 10 PCs and overall
% Create X for all pcs (fyi only X_overall has pc Y/N cols as features)
Y = FeaturesTable(:,2);
X_overall = FeaturesTable(:,4:16);
for pc = 2:size(pcList,2)
    eval(['X_' pcList{pc} ' = FeaturesTable(:,15:16);'])
end
for pc = 1:size(pcList,2)
    for c = 17:size(FeaturesTable,2)
        eval(['currentPercentVal = FeaturesAnalysis.' pcList{pc} '{c};'])
        if currentPercentVal >= .5
            eval(['X_' pcList{pc} ' = [X_' pcList{pc} ' FeaturesTable(:,c)];'])
        end
    end
end

%% Detect triageSVM performance on each X/Y
for pc = 1:size(pcList,2)
    eval([pcList{pc} 'Results=triageSVM(X_' pcList{pc} ',Y);'])
end


