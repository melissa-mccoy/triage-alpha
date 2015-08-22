% function [resultsTable,labelTest, labelTrain] = triageSVMLib(inputX,Y,cParam)

    %% Prep Data
%     % Turn X and Y into numbers
%     numXY_pc = table;
%     for c=1:size(XY_pc,2)
%         numXY_pc.(c) = grp2idx(XY_pc.(c));
%     end
%     
%     inputX = numXY_pc(:,2:end);
%     Y = numXY_pc.(1);
%     dumY = dummyvar(nominal(Y));
%     YMat = dumY(:,1);
%     XMat = cell2mat(table2cell(numXY_pc(:,2:end)));
    
    % Dummify X and Y
    inputX = XY_pc(:,2:end);
    Y = XY_pc.(1);
    dumX = table;
    features = [];
    for c = 1:size(inputX,2)
        features = [features; unique(inputX.(c))];
        dumX.(c) = dummyvar(nominal(inputX.(c)));
    end
    dumY = dummyvar(nominal(Y));
   
    XMat = cell2mat(table2cell(dumX));
    YMat = dumY(:,1);
    

    %% Feature Selection
    
    % FILTER: Relief
    relieff(XMat,YMat,10,'method','classification');
    
    % FILTER: mRMR
    % MID
    feaMID = mrmr_mid_d(XMat,YMat,50);
    % MIQ
    feaMIO = mrmr_miq_d(XMat,YMat,50);
    
    for m=1:4:size(1,feaMID)
        xMIVals(end+1) = m;
        midErrVals(end+1) = transpose(crossval(@my_fun_lib,XMat(feaMID(1:m)),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize;
        mioErrVals(end+1) = transpose(crossval(@my_fun_lib,XMat(feaMIO(1:m)),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize;
    end
    
    plot(xMIVals, midErrVals,'o',xMIVals,mioErrVals,'r^');
    xlabel('Number of Features');
    ylabel('MCE');
    legend({'MCE for MID scheme' 'MCE for MIO scheme'},'location','NW');
    title('mRMR Feature Selection with LOO SVM MCE');
    
    % FILTER+WRAPPER: Remove Most Correlated Features Until Reach Model Error Minimum
    featuresIdxSortbyC = zeros(1,size(XMat,2));
    XMatCorr = XMat;
    leaveoutCVP = cvpartition(YMat,'LeaveOut');
    errVals = [];
    xVals = [];
    for f=1:size(XMat,2)
        [~,idx] = max(mean(abs(corr(XMatCorr))));
        featuresIdxSortbyC(f) = idx;
        XMatCorr(:,idx) = [];
        if mod(f,4) == 0 
            xVals(end+1) = f;
            errVals(end+1) = transpose(crossval(@my_fun_lib,XMatCorr,YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize;
        end
    end 
    plot(xVals, errVals,'o');
    xlabel('Number of Features');
    ylabel('MCE');
    title('Correlation-based Remove Features vs LOO MCE'); % Removing 104 gives lowest error
    %% ADDITIONAL WRAPPER: Apply Sequential Features Selection to Above
    fs2 = featuresIdxSortbyC(105:end);
    fsLocalCorr = sequentialfs(@my_fun_lib,XMat(:,fs2),YMat,'cv',leaveoutCVP,'Nf',50);
    testMCECorr = transpose(crossval(@my_fun_lib,XMat(:,fs2(fsLocalCorr)),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize; %Result: 0.1205
    
    %% FILTER+WRAPPER: Add Most Predictive Features Until Reach Model Error Minimum
    drCases = XMat(YMat==1,:);
    selfCases = XMat(YMat==0,:);
    [h,p,ci,stat] = ttest2(drCases,selfCases,'Vartype','unequal');
    ecdf(p);
    xlabel('P value'); ylabel('CDF value'); % Shows ~80% of features have p-val<.5 and ~20% have pval ~= 0
    % Determine which features to include by plotting classfication error rate of svm with leave-out-1 cross validation against num of features (added in their p order)
    [~,featureIdxSortbyP] = sort(p,2); % sort the features
    testMCE = zeros(1,10);
    resubMCE = zeros(1,10);
    nfs = 80:5:125;
    leaveoutCVP = cvpartition(YMat,'LeaveOut'); 
    resubCVP = cvpartition(length(YMat),'resubstitution');
    for i = 1:10
       fs = featureIdxSortbyP(1:nfs(i));
       testMCE(i) = transpose(crossval(@my_fun_lib,XMat(:,fs),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize;
       resubMCE(i) = crossval(@my_fun_lib,XMat(:,fs),YMat,'partition',resubCVP)/resubCVP.TestSize;
    end
    plot(nfs, testMCE,'o',nfs,resubMCE,'r^');
    xlabel('Number of Features Removed');
    ylabel('MCE');
    legend({'MCE on the test set' 'Resubstitution MCE'},'location','NW');
    title('Simple Filter Feature Selection Method');
    % Plot shows that 110 features gives 12.05% testMCE which are
    featureIdxSortbyP(1:110)
    % ADDITIONAL WRAPPER: Apply Sequential Features Selection to Above
    fs1 = featureIdxSortbyP(1:110);
    fsLocal = sequentialfs(@my_fun_lib,XMat(:,fs1),YMat,'cv',leaveoutCVP);
    testMCELocal = transpose(crossval(@my_fun_lib,XMat(:,fs1(fsLocal)),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize; %Result: 0.1205 & 16 Features
    % Make sure it didn't stop prematurely and make it go to 50
    [fsCVfor50,historyCV] = sequentialfs(@my_fun_lib,XMat(:,fs1),YMat,'cv',leaveoutCVP,'Nf',50);
    [fsResubfor50,historyResub] = sequentialfs(@my_fun_lib,XMat(:,fs1),YMat,'cv','resubstitution','Nf',50);
    plot(1:50, historyCV.Crit,'bo',1:50, historyResub.Crit,'r^');
    xlabel('Number of Features'); ylabel('MCE');
    legend({'Leave-1-Out CV MCE' 'Resubstitution MCE'},'location','NE');
    %   If find in plot a better error, calculate fcount performance below
    %     fsCVfor38 = fs1(historyCV.In(38,:))
    %     [orderlist,ignore] = find( [historyCV.In(1,:); diff(historyCV.In(1:38,:) )]' );
    %     testMCECVfor38 = transpose(crossval(@my_fun_lib,XMat(:,fsCVfor38),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize
    
    % WRAPPER: Sequential Features Selection
    % Apply SFS Across all 345 Features Using Leaveout One CV
    inmodel = sequentialfs(@my_fun_lib,XMat,YMat,'cv',leaveoutCVP);
    fullSFSError = transpose(crossval(@my_fun_lib,XMat(:,inmodel),YMat,'partition',leaveoutCVP))/leaveoutCVP.TestSize; %Result: 0.1205 & 16 Features
    
    %% Select Best Hyperparameters (C & Gamma) with Cross Validation
    bestcv = 0;
    for log2c = -1:3
      for log2g = -4:1
        cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
        cv = svmtrain(YMat, XMat, cmd);
        if (cv >= bestcv),
          bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
        end
        fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
      end
    end

    
%% Train & Test Model
    %Train Model on TrainData, Predict with test input data & Analyze Performance
    leaveoutCVP = cvpartition(YMat,'LeaveOut');
    tenfoldCVP = cvpartition(YMat,'k',10);
    cvLeaveout = crossval(@my_fun_lib,XMat,YMat,'partition',leaveoutCVP);
    leaveoutError = transpose(cvLeaveout)/leaveoutCVP.TestSize;
    predictLabels = zeros(length(cvLeaveout),1);
    truePos = 0; trueNeg = 0; falsePos = 0; falseNeg = 0;
    for t=1:length(cvLeaveout)
        if cvLeaveout(t) == 1
            if YMat(t) == 1
                falseNeg = falseNeg + 1;
                predictLabels(t) = 0;
            else
                falsePos = falsePos + 1;
                predictLabels(t) = 1;
            end
        else
            predictLabels(t) = YMat(t);
            if YMat(t) == 1
                truePos = truePos + 1;
            else
                trueNeg = trueNeg + 1;
            end
        end
    end
    sensLeaveout = truePos/(truePos+falseNeg);
    specLeaveout = trueNeg/(trueNeg+falsePos);
    leaveoutResults = [leaveoutError, sensLeaveout, specLeaveout]; 
	[X,Y,T,leavoutAUC] = perfcurve(YMat,predictLabels,1);
    plot(X,Y)
    xlabel('False positive rate')
    ylabel('True positive rate')
    title('ROC for Classification by SVM LOO')
