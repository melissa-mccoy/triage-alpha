%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /Users/apprentice/Documents/MATLAB/Triage/OdysseyData10.xlsx
%    Worksheet: data
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2015/08/02 23:36:52

%% Import the data
[~, ~, raw] = xlsread('/Users/apprentice/Documents/MATLAB/Triage/OdysseyData10.xlsx','data');
raw = raw(2:end,1:78);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78]);

%% Create table
Data = table;

%% Allocate imported array to column variable names
Data.case_no = cellfun(@num2str,cellVectors(:,1),'UniformOutput',false);
Data.patient_no = cellVectors(:,2);
Data.self_vs_dr = cellVectors(:,3);
Data.tas_recommends = cellVectors(:,4);
Data.pres_compl = cellVectors(:,5);
Data.pc_chest = cellVectors(:,6);
Data.pc_throat = cellVectors(:,7);
Data.pc_abd = cellVectors(:,8);
Data.pc_dig = cellVectors(:,9);
Data.pc_ear = cellVectors(:,10);
Data.pc_temp = cellVectors(:,11);
Data.pc_skin = cellVectors(:,12);
Data.pc_eye = cellVectors(:,13);
Data.pc_head = cellVectors(:,14);
Data.pc_nose = cellVectors(:,15);
Data.pc_otherIFISERRORFINDYesCONCATENATEF2G2H2I2J2K2L2M2N2O2OtherNo = cellVectors(:,16);
Data.ageband = cellVectors(:,17);
Data.sex = cellVectors(:,18);
Data.oldq1 = cellVectors(:,19);
Data.questxt1 = cellVectors(:,20);
Data.ans1 = cellVectors(:,21);
Data.oldq2 = cellVectors(:,22);
Data.questxt2 = cellVectors(:,23);
Data.ans2 = cellVectors(:,24);
Data.oldq3 = cellVectors(:,25);
Data.questxt3 = cellVectors(:,26);
Data.ans3 = cellVectors(:,27);
Data.oldq4 = cellVectors(:,28);
Data.questxt4 = cellVectors(:,29);
Data.ans4 = cellVectors(:,30);
Data.oldq5 = cellVectors(:,31);
Data.questxt5 = cellVectors(:,32);
Data.ans5 = cellVectors(:,33);
Data.oldq6 = cellVectors(:,34);
Data.questxt6 = cellVectors(:,35);
Data.ans6 = cellVectors(:,36);
Data.oldq7 = cellVectors(:,37);
Data.questxt7 = cellVectors(:,38);
Data.ans7 = cellVectors(:,39);
Data.oldq8 = cellVectors(:,40);
Data.questxt8 = cellVectors(:,41);
Data.ans8 = cellVectors(:,42);
Data.oldq9 = cellVectors(:,43);
Data.questxt9 = cellVectors(:,44);
Data.ans9 = cellVectors(:,45);
Data.oldq10 = cellVectors(:,46);
Data.questxt10 = cellVectors(:,47);
Data.ans10 = cellVectors(:,48);
Data.oldq11 = cellVectors(:,49);
Data.questxt11 = cellVectors(:,50);
Data.ans11 = cellVectors(:,51);
Data.oldq12 = cellVectors(:,52);
Data.questxt12 = cellVectors(:,53);
Data.ans12 = cellVectors(:,54);
Data.oldq13 = cellVectors(:,55);
Data.questxt13 = cellVectors(:,56);
Data.ans13 = cellVectors(:,57);
Data.oldq14 = cellVectors(:,58);
Data.questxt14 = cellVectors(:,59);
Data.ans14 = cellVectors(:,60);
Data.oldq15 = cellVectors(:,61);
Data.questxt15 = cellVectors(:,62);
Data.ans15 = cellVectors(:,63);
Data.oldq16 = cellVectors(:,64);
Data.questxt16 = cellVectors(:,65);
Data.ans16 = cellVectors(:,66);
Data.oldq17 = cellVectors(:,67);
Data.questxt17 = cellVectors(:,68);
Data.ans17 = cellVectors(:,69);
Data.oldq18 = cellVectors(:,70);
Data.questxt18 = cellVectors(:,71);
Data.ans18 = cellVectors(:,72);
Data.oldq19 = cellVectors(:,73);
Data.questxt19 = cellVectors(:,74);
Data.ans19 = cellVectors(:,75);
Data.oldq20 = cellVectors(:,76);
Data.questxt20 = cellVectors(:,77);
Data.ans20 = cellVectors(:,78);

%% Clear temporary variables
clearvars data raw cellVectors;

%% Replace Answer Unsurities in Data Table with "Unsure"
CleanData = Data;
for c = 1:size(CleanData,2)
    colName = CleanData.Properties.VariableNames{c};
    if strfind('ans',colName)
        for r = 1:size(CleanData,1)
            if CleanData{r,c} == '' || CleanData{r,c} == '#N/A' || CleanData{r,c} == 'Not known' || CleanData{r,c} == 'Not specific' || CleanData{r,c} == 'Not assessed'
                CleanData{r,c} = 'Unsure';
            end
        end
    end
end