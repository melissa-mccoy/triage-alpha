function [ criterion ] = maxrel_fs(trainX,trainY,testX,testY)

    %% Feature Selection
    % Calculate T-Test & Rank
    drCases = trainX(trainY==1,:); selfCases = trainX(trainY==0,:);
    [h,p,ci,stat] = ttest2(drCases,selfCases,'Vartype','unequal');
    ecdf(p);
    xlabel('P value'); ylabel('CDF value'); 
    title('Feature P-Value CDF');
    
    % Determine which features to include by plotting classfication error rate of svm with leave-out-1 cross validation against num of features (added in their p order)
%     [~,featureIdxSortbyP] = sort(p,2); 
%     testMCE = zeros(1,6); resubMCE = zeros(1,6); nfs = 5:10;
%     fivefoldCVP = cvpartition(trainY,'KFold',5); resubCVP = cvpartition(length(trainY),'resubstitution');
%     for i = 1:6
%        fs = featureIdxSortbyP(1:nfs(i));
%        testMCE(i) = transpose(crossval(@my_fun_lib,trainX(:,fs),trainY,'partition',fivefoldCVP))/fivefoldCVP.TestSize;
%        resubMCE(i) = crossval(@my_fun_lib,trainX(:,fs),trainY,'partition',resubCVP)/resubCVP.TestSize;
%     end
%     plot(nfs, testMCE,'o',nfs,resubMCE,'r^');
%     xlabel('Number of Added Features'); ylabel('MCE');
%     legend({'Test Set MCE' 'Resubstitution MCE'},'location','NW');
%     title('Max Relevance Feature Selection');
    
%     [minVal minIndex] = min(testMCE);
%     maxrelFeatures = featureIdxSortbyP(1:nfs(minIndex));
%     fprintf('(MinIndex=%g)\n', minIndex);
    % ADDITIONAL WRAPPER: Apply Sequential Features Selection to Above
%     fs1 = featureIdxSortbyP(1:110);
%     fsLocal = sequentialfs(@my_fun_lib,trainX(:,fs1),trainY,'cv',leaveoutCVP);
%     testMCELocal = transpose(crossval(@my_fun_lib,trainX(:,fs1(fsLocal)),trainY,'partition',leaveoutCVP))/leaveoutCVP.TestSize; %Result: 0.1205 & 16 Features
%     % Make sure it didn't stop prematurely and make it go to 50
%     [fsCVfor50,historyCV] = sequentialfs(@my_fun_lib,trainX(:,fs1),trainY,'cv',leaveoutCVP,'Nf',50);
%     [fsResubfor50,historyResub] = sequentialfs(@my_fun_lib,trainX(:,fs1),trainY,'cv','resubstitution','Nf',50);
%     plot(1:50, historyCV.Crit,'bo',1:50, historyResub.Crit,'r^');
%     xlabel('Number of Features'); ylabel('MCE');
%     legend({'Leave-1-Out CV MCE' 'Resubstitution MCE'},'location','NE');
%     %   If find in plot a better error, calculate fcount performance below
%     %     fsCVfor38 = fs1(historyCV.In(38,:))
%     %     [orderlist,ignore] = find( [historyCV.In(1,:); diff(historyCV.In(1:38,:) )]' );
%     %     testMCECVfor38 = transpose(crossval(@my_fun_lib,trainX(:,fsCVfor38),trainY,'partition',leaveoutCVP))/leaveoutCVP.TestSize
    
      %% Parameter Selection
%    bestcv = 0;
%     for c = .01:1000
%       for g = .00001:.001:100
%         cmd = ['-v 3 -s 0 -t 2 -c ', num2str(c), ' -g ', num2str(g)];
%         cv = svmtrain(trainY, trainX(:,maxrelFeatures), cmd);
%         if (cv >= bestcv),
%           bestcv = cv; bestc = c; bestg = g;
%         end
%         fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', bestc, bestg, bestcv);
%       end
%     end
    bestc = 120;
    bestg = .002;
    
    %% Test Model
    model = svmtrain(trainY, trainX,['-s 0 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg)]);
    criterion = sum(svmpredict(testY, testX, model) ~= testY);

end
