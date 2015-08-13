function [resultsTable,labelTest, labelTrain] = triageSVMLib(inputX,Y,cParam)
%     inputX = XY_pc(:,2:end);
%     Y = XY_pc.(1);
%     cParam = 1;
    %Inistiates results tables; comment out if already created
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

    %Dummify X & Y
    dumX = table;
    for c = 1:size(inputX,2)
        dumX.(c) = dummyvar(nominal(inputX.(c)));
    end
    dumY = dummyvar(nominal(Y));

    %% Prep Data
    %Divide into train vs test data
    trainPrecentage = .7;
    trainCutoffIndex = fix(size(dumY,1)*trainPrecentage);
    trainHalfIndex = fix(trainCutoffIndex/2);
    trainY = [];
    trainX = table;
    %Fill Train with Half 1's
    countOne = 0;
    countZero = 0;
    i = 0;
    while countOne < trainHalfIndex && countOne < trainHalfIndex
        if dumY(i,1) == 1
            trainY(end+1) = dumY(i,1);
            trainX = [trainX; dumX(i,:)];
            countOne = countOne + 1;
        else
            trainY(end+1) = dumY(i,1);
            trainX = [trainX; dumX(i,:)];
            countZero = countZero + 1;
        end
        i = i+1;
    end
    if countOne > countZero
        while countOne > countZero
        for n=1:missingZeros
            if dumY(i,1) == 1
                trainY(end+1) = dumY(i,1);
                trainX = [trainX; dumX(i,:)];
                countOne = countOne + 1;
            end
        end
    else
        missingOnes = countZero - countOne;
    end
    %Fill Train with Half 0's
    for i = (trainHalfIndex+1):end
        if dumY(i,1) == 1
            trainY(end+1) = dumY(i,1);
            trainX = dumX(i,:);
        end
    end
    trainX = dumX(1:trainCutoffIndex,:);
    trainY = dumY(1:trainCutoffIndex,1);
    testX = dumX((trainCutoffIndex+1):end,:);
    testY = dumY((trainCutoffIndex+1):end,1);

    %Turn dumXs dumYs into matDumXs 
    trainXMat = cell2mat(table2cell(trainX));
    testXMat = cell2mat(table2cell(testX));
    XMat = cell2mat(table2cell(dumX));
    
    %% Train & Test Model
    %Train Model on TrainData, Predict with test input data & Analyze Performance
    SVMModel = svmtrain(trainY, trainXMat,['-s 0 -t 0 -c ' num2str(cParam)]);
    [labelTest,accuracyTest,probEstimatesTest] = svmpredict(testY,testXMat,SVMModel);
    [labelTrain,accuracyTrain,probEstimatesTrain] = svmpredict(trainY,trainXMat,SVMModel);
    CP_Test = classperf(testY, labelTest);
    CP_Train = classperf(trainY, labelTrain);
    
    do_binary_cross_validation(dumY(:,1), XMat, ['-s 0 -t 0 -c ' num2str(cParam)], 10);
    model = svmtrain(trainY, trainXMat);
    [labelCV, eval_ret, dec] = do_binary_predict(testY, testXMat, model);
    CP_CV = classperf(testY, labelCV);
    
    %% Write to Results Table
    type(end+1,1) = {'CP_Train'};
    numFeatures(end+1,1) = size(inputX,2);
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
    numFeatures(end+1,1) = size(inputX,2);
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
    numFeatures(end+1,1) = size(inputX,2);
    numObservations(end+1,1) = size(testY,1);
    sensitivity(end+1,1) = CP_CV.Sensitivity;
    specificity(end+1,1) = CP_CV.Specificity;
    errorRate(end+1,1) = CP_CV.ErrorRate;
    genError(end+1,1) = (1-eval_ret);
    meanSquaredError(end+1,1) = 0;
    squaredCorrelation(end+1,1) = 0;
    correctlyClassifiedPos(end+1,1) = CP_CV.PositivePredictiveValue;
    correctlyClassifiedNeg(end+1,1) = CP_CV.NegativePredictiveValue;

    resultsTable = table(type,numFeatures,numObservations,errorRate,meanSquaredError,squaredCorrelation,sensitivity,specificity,correctlyClassifiedPos,correctlyClassifiedNeg,genError);
end

