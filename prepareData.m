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
               eval(['FeaturesTable.' char(regexprep(CaseTable{r,c},'\W','')) '=tempCol;'])
           end
           %Add the answer as a value & replace with blank if an unsuretiy
           ansVal = CaseTable{r,c+1}{1};
           if isempty(ansVal) || strcmp(ansVal,'Unsure')|| strcmp(ansVal,'#N/A') || strcmp(ansVal,'Not known') || strcmp(ansVal,'Not specific') || strcmp(ansVal,'Not assessed') || strcmp(ansVal,'Nil specific')
               eval(['FeaturesTable.' char(regexprep(CaseTable{r,c},'\W','')) '(' num2str(r) ')' '={''''};'])
           else
               eval(['FeaturesTable.' char(regexprep(CaseTable{r,c},'\W','')) '(' num2str(r) ')' '={ansVal};'])
           end
        end
    end
end

%% Loop through columns in FeaturesTable, store % blanks overall & per pc in FeaturesAnalysis table
% FeaturesAnalysis = cell2table(cell(12,size(FeaturesTable,2)));
% FeaturesAnalysis.Properties.VariableNames = FeaturesTable.Properties.VariableNames;
% FeaturesAnalysis.Properties.RowNames = {'overall','pc_chest','pc_throat','pc_abd','pc_dig','pc_ear','pc_temp','pc_skin','pc_eye','pc_head','pc_nose','pc_other'};
pcList = {'overall','pc_chest','pc_throat','pc_abd','pc_dig','pc_ear','pc_temp','pc_skin','pc_eye','pc_head','pc_nose','pc_other'};
% Create struct for current pc with key for each question features
for pc = 1:size(pcList,2)
    eval([pcList{pc} '=struct;'])
%     eval([pcList{pc} '.' FeaturesTable.Properties.VariableNames{f} '={};'])
end
% Calculate % present data for each feature fitered to each pc & add to struct
for c = 17:size(FeaturesTable,2)
    overallMissing = 0; chestMissing = 0; throatMissing = 0; abdMissing = 0; digMissing = 0; earMissing = 0; tempMissing = 0; skinMissing = 0; eyeMissing = 0; headMissing = 0; noseMissing = 0; otherMissing = 0;
    for r = 1:size(FeaturesTable,1)
        if isempty(FeaturesTable{r,c}{1}) 
            overallMissing = overallMissing+1;
            if strcmp(char(FeaturesTable.pc_chest(r)),'No')
                chestMissing = chestMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_throat(r)),'No')
                throatMissing = throatMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_abd(r)),'No')
                abdMissing = abdMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_dig(r)),'No')
                digMissing = digMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_ear(r)),'No')
                earMissing = earMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_temp(r)),'No')
                tempMissing = tempMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_skin(r)),'No')
                skinMissing = skinMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_eye(r)),'No')
                eyeMissing = eyeMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_head(r)),'No')
                headMissing = headMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_nose(r)),'No')
                noseMissing = noseMissing+1;
            end
            if strcmp(char(FeaturesTable.pc_other(r)),'No')
                otherMissing = otherMissing+1;
            end
        end         
    end
    % Add Cacluated Percentage for given feature to all pc structs
    rows = size(FeaturesTable,1);
    eval(['overall.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-overallMissing)/rows) ';'])
    eval(['pc_chest.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-chestMissing)/rows) ';'])
    eval(['pc_throat.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-throatMissing)/rows) ';'])
    eval(['pc_abd.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-abdMissing)/rows) ';'])
    eval(['pc_dig.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-digMissing)/rows) ';'])
    eval(['pc_ear.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-earMissing)/rows) ';'])
    eval(['pc_temp.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-tempMissing)/rows) ';'])
    eval(['pc_skin.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-skinMissing)/rows) ';'])
    eval(['pc_eye.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-eyeMissing)/rows) ';'])
    eval(['pc_head.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-headMissing)/rows) ';'])
    eval(['pc_nose.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-noseMissing)/rows) ';'])
    eval(['pc_other.' FeaturesTable.Properties.VariableNames{c} '=' num2str((rows-otherMissing)/rows) ';'])
    
end
%% Create X (comprised of features with >50% comlete data) & Y inputs for top 10 PCs and overall
% Create X_overall
% X_overall = table;
% for c = 1:size(FeaturesTable,2)
%     if FeaturesAnalysis({'overall'},c){1} >= .5
%         FeaturesTables.Properties.VariableNames(c)
% end
% Create X_chest
