% function [resultsTable,labelTest, labelTrain] = triageSVMLib(inputX,Y,cParam)
%     XY_pc_sorted = sortrows(XY_pc,'self_vs_dr');
%     inputX = XY_pc_sorted(:,2:end);
%     Y = XY_pc_sorted.(1);

    XY_pc_SFS_sorted = sortrows(XY_pc_SFS,'self_vs_dr');
    inputX = XY_pc_SFS_sorted(:,2:end);
    Y = XY_pc_SFS_sorted.(1);

%     inputX = XY_pc_SFS(:,2:end);
%     Y = XY_pc_SFS.(1);
%     inputX = XY_pc(:,2:end);
%     Y = XY_pc.(1);

%     verifycvX = inputX(1:(size(dumY,1)*.25),:);
%     verifycvX = [verifycvX; inputX((size(dumY,1)*.5+1):(size(dumY,1)*.75),:)];
%     verifycvY = Y(1:(size(dumY,1)*.25),1);
%     verifycvY = [verifycvY; Y((size(dumY,1)*.5+1):(size(dumY,1)*.75),1)];
  
    %% Dummify X & Y
    dumX = table;
    for c = 1:size(inputX,2)
        features = [features; unique(inputX.(c))];
        dumX.(c) = dummyvar(nominal(inputX.(c)));
    end
    dumY = dummyvar(nominal(Y));
    
  
     %% Prep Data
     %Divide into cv,train,test dataset (ensure total is divisble by 8!)
     cvX = dumX(1:(size(dumY,1)*.25),:);
     cvX = [cvX; dumX((size(dumY,1)*.5+1):(size(dumY,1)*.75),:)];
     trainX = dumX((size(dumY,1)*.25+1):(size(dumY,1)*.375),:);
     trainX = [trainX; dumX((size(dumY,1)*.75+1):(size(dumY,1)*.875),:)];
     testX = dumX((size(dumY,1)*.375+1):(size(dumY,1)*.5),:);
     testX = [testX; dumX((size(dumY,1)*.875+1):end,:)];

     cvY = dumY(1:(size(dumY,1)*.25),1);
     cvY = [cvY; dumY((size(dumY,1)*.5+1):(size(dumY,1)*.75),1)];
     trainY = dumY((size(dumY,1)*.25+1):(size(dumY,1)*.375),1);
     trainY = [trainY; dumY((size(dumY,1)*.75+1):(size(dumY,1)*.875),1)];
     testY = dumY((size(dumY,1)*.375+1):(size(dumY,1)*.5),1);
     testY = [testY; dumY((size(dumY,1)*.875+1):end,1)];

    %Turn X's into matX's
    trainXMat = cell2mat(table2cell(trainX));
    testXMat = cell2mat(table2cell(testX));
    cvXMat = cell2mat(table2cell(cvX));
    XMat = cell2mat(table2cell(dumX));
      
%     %Divide into train vs test data
%     trainPercentage = .75;
%     trainCutoffIndex = fix(size(dumY,1)*trainPercentage);
%     trainX = dumX(1:trainCutoffIndex,:);
%     trainY = dumY(1:trainCutoffIndex,1);
%     testX = dumX((trainCutoffIndex+1):end,:);
%     testY = dumY((trainCutoffIndex+1):end,1);
% 
%     %Turn dumXs dumYs into matDumXs 
%     trainXMat = cell2mat(table2cell(trainX));
%     testXMat = cell2mat(table2cell(testX));
%     XMat = cell2mat(table2cell(dumX));
    
    %% Feature Selection with Matlab sequentialfs

    c = cvpartition(dumY(:,1),'k',5);
    stream = RandStream('mrg32k3a','Seed',5489);
    opts = statset('display','iter','Streams',stream);
    inmodel = sequentialfs(@my_fun_lib,XMat,dumY(:,1),'cv',c,'mcreps',5,'options',opts);

%     c = cvpartition(cvY,'k',5);
%     inmodel = sequentialfs(@my_fun_lib,cvXMat,cvY,'cv',c,'options',opts);
%  
    
    %% Build Optimized Feature Input X
    XMat_Opt = [];
    for f = 1:size(inmodel,2)
       if inmodel(f) == 1
        XMat_Opt = [XMat_Opt XMat(:,f)];
       end
    end
    
     cvXMat = XMat_Opt(1:(size(dumY,1)*.25),:);
     cvXMat = [cvXMat; XMat_Opt((size(dumY,1)*.5+1):(size(dumY,1)*.75),:)];
     trainXMat = XMat_Opt((size(dumY,1)*.25+1):(size(dumY,1)*.375),:);
     trainXMat = [trainXMat; XMat_Opt((size(dumY,1)*.75+1):(size(dumY,1)*.875),:)];
     testXMat = XMat_Opt((size(dumY,1)*.375+1):(size(dumY,1)*.5),:);
     testXMat = [testXMat; XMat_Opt((size(dumY,1)*.875+1):end,:)];
    
%     trainXMat = XMat_Opt(1:trainCutoffIndex,:);
%     testXMat = XMat_Opt((trainCutoffIndex+1):end,:);
   
    %% Select Best Hyperparameters (C & Gamma) with Cross Validation
    bestcv = 0;
    for log2c = -1:3,
      for log2g = -4:1,
        cmd = ['-v 5 -t 0 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
        cv = svmtrain(dumY(:,1), XMat, cmd);
        if (cv >= bestcv),
          bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
        end
        fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
      end
    end

    
%% Train & Test Model
    %Train Model on TrainData, Predict with test input data & Analyze Performance
    SVMModel = svmtrain(trainY, trainXMat,['-s 0 -t 0 -b 1 -c ' num2str(bestc) ]);
    [labelTest,accuracyTest,probEstimatesTest] = svmpredict(testY,testXMat,SVMModel,'-b 1');
    [labelTrain,accuracyTrain,probEstimatesTrain] = svmpredict(trainY,trainXMat,SVMModel,'-b 1');
    CP_Test = classperf(testY, labelTest);
    CP_Train = classperf(trainY, labelTrain);
    %Correct Way to Evaluate Performance as described here
    %(http://www.mathworks.com/examples/statistics/2229-selecting-features-for-classifying-high-dimensional-data#6)
%     c = cvpartition(dumY(:,1),'k',5);
%     cv = transpose(crossval(@my_fun_lib,XMat,dumY(:,1),'partition',c))/c.TestSize;
    c = cvpartition(cvY,'k',5);    
    cv = transpose(crossval(@my_fun_lib,cvXMat,cvY,'partition',c))/c.TestSize;

    
    %     cv = svmtrain(dumY(:,1), XMat_Opt, ['-v 5 -s 0 -t 0 -c ' num2str(bestc) ]);
%   cv = svmtrain(dumY(:,1), XMat, ['-v 5 -s 0 -t 0 -c ' num2str(bestc) ]);
%     cv = svmtrain(cvY, cvXMat, ['-v 5 -s 0 -t 0 -c ' num2str(bestc) ]);
    
    %% Write to Results Table
    type = {};
    sensitivity = [];
    specificity = [];
    numObservations = [];
    numFeatures = [];
    errorRate = [];
    meanSquaredError = [];
    squaredCorrelation = []; 
    correctlyClassifiedPos = [];
    correctlyClassifiedNeg = [];
    genError = [];
    features = {};
    
    type(end+1,1) = {'CP_Train'};
    numFeatures(end+1,1) = size(trainXMat,2);
    numObservations(end+1,1) = size(trainY,1);
    sensitivity(end+1,1) = CP_Train.Sensitivity;
    specificity(end+1,1) = CP_Train.Specificity;
    errorRate(end+1,1) = (100-accuracyTrain(1));
    meanSquaredError(end+1,1) = accuracyTrain(2);
    squaredCorrelation(end+1,1) = accuracyTrain(3);
    correctlyClassifiedPos(end+1,1) = CP_Train.PositivePredictiveValue;
    correctlyClassifiedNeg(end+1,1) = CP_Train.NegativePredictiveValue;
    genError(end+1,1) = 0;

    type(end+1,1) = {'CP_Test'};
    numFeatures(end+1,1) = size(testXMat,2);
    numObservations(end+1,1) = size(testY,1);
    sensitivity(end+1,1) = CP_Test.Sensitivity;
    specificity(end+1,1) = CP_Test.Specificity;
    errorRate(end+1,1) = (100-accuracyTest(1));
    meanSquaredError(end+1,1) = accuracyTest(2);
    squaredCorrelation(end+1,1) = accuracyTest(3);
    correctlyClassifiedPos(end+1,1) = CP_Test.PositivePredictiveValue;
    correctlyClassifiedNeg(end+1,1) = CP_Test.NegativePredictiveValue;
    genError(end+1,1) = 0;
    
    type(end+1,1) = {'CP_CV'};
    numFeatures(end+1,1) = size(XMat,2);
    numObservations(end+1,1) = size(dumY,1);
    sensitivity(end+1,1) = 0;
    specificity(end+1,1) = 0;
    errorRate(end+1,1) = 0;
    genError(end+1,1) = cv;
    meanSquaredError(end+1,1) = 0;
    squaredCorrelation(end+1,1) = 0;
    correctlyClassifiedPos(end+1,1) = 0;
    correctlyClassifiedNeg(end+1,1) = 0;

    resultsTable = table(type,numFeatures,numObservations,errorRate,meanSquaredError,squaredCorrelation,sensitivity,specificity,correctlyClassifiedPos,correctlyClassifiedNeg,genError);

    %% Give Average of Classification
%     SVMModel = svmtrain(trainY, trainXMat,['-s 0 -t 0 -c ' num2str(bestc) ]);
%     [labelTrain,accuracyTrain,probEstimatesTrain] = svmpredict(trainY,trainXMat,SVMModel);
%     
% end

