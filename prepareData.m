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
        %Denote current table and current case numbers in table
        currentTable = caseTableArray{n};
        if isempty(currentTable.case_no)
            currentCases = {};
        else
            currentCases = cellfun(@num2str,currentTable.case_no,'UniformOutput',false);
        end
        %Add row to a table without the case yet
        if any(ismember(currentCases,num2str(caseNo)))
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
FeaturesTable = cell2table(cell(size(CaseTable,1),0));
% FeaturesTable.Properties.RowNames = CaseTable{:,1};
% FeaturesTable = table;
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
% FeaturesAnalysis = cell2table(cell(0,size(FeaturesTable,2)));
% FeaturesAnalysis.Properties.VariableNames = FeaturesTable.Properties.VariableNames;
% FeaturesAnalysis.Properties.RowValues = {'overall','pc_chest','pc_throat','pc_abd','pc_dig','pc_ear','pc_temp','pc_skin','pc_eye','pc_head','pc_nose','pc_other'};
% for c = 1:size(FeaturesTable,2)
%     overallMissing = 0; chestMissing = 0; throatMissing = 0; abdMissing = 0; digMissing = 0; earMissing = 0; tempMissing = 0; skinMissing = 0; eyeMissing = 0; headMissing = 0; noseMissing = 0; otherMissing = 0;
%     for r = 1:size(FeaturesTable,1)
%         currentVal = FeaturesTable{r,c}{1};
%         if isempty(currentVal)
%             overallMissing = overallMissing+1;
%             if FeaturesTable.pc_chest(r){1} == 1
%                 chestMissing = chestMissing+1;
%             end
%             %if statements for all
%         end         
%     end
%     FeaturesAnalysis({'overall'},c){1} = overallMissing/size(FeaturesTable,1);
%     %cell assignment for all
% end
%% Create X (comprised of features with >50% comlete data) & Y inputs for top 10 PCs and overall
% Create X_overall
% X_overall = table;
% for c = 1:size(FeaturesTable,2)
%     if FeaturesAnalysis({'overall'},c){1} >= .5
%         FeaturesTables.Properties.VariableNames(c)
% end
% Create X_chest
