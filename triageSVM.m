function resultsTable = triageSVM(X,Y)

    %Inistiates results tables; comment out if already created
    type = {};
    sensitivity = [];
    specificity = [];
    numObservations = [];
    numFeatures = [];
    errorRate = [];
    posPred = [];
    negPred = [];
    prevalence = [];
    genError = [];

    %Dummify X
    for c = 1:size(X,2)
        X.(c) = dummyvar(nominal(X.(c)));
    end

    for f = 7:size(X,2)
        %% Auto select best features
        % inmodel = sequentialfs(fun,X,Y);

        %% Train & Test SVM
        %Divide into train vs test data
        trainPrecentage = .7;
        trainCutoffIndex = fix(size(Y,1)*trainPrecentage);
        trainX = X(1:trainCutoffIndex,1:f);
        trainY = Y(1:trainCutoffIndex);
        testX = X((trainCutoffIndex+1):end,1:f;
        testY = Y((trainCutoffIndex+1):end);

        %Train Model on TrainData, Predict with test input data & Analyze Performance
        SVMModel = fitcsvm(trainX,trainY,'Standardize',true,'KernelFunction','linear','ClassNames',{'SELF','DR'});
        % 'Crossval','on','KFold',10,'PredictorNames',{'Breathing Problem','BreathingRate','ChestPain','Cold/flu-severity','CoughOnset','CoughSpasms','CoughType','Cough-severity','CurrentState','Inhaled/Ingest','Meds/Respiratory','OtherSymptoms','PMH/RespiratoryDis.','Precipfactors?','Sorethroat-severity','Sputum','Temperature','TreatmentTried','WorstTime'}
        [labelTest,scoreTest] = predict(SVMModel,testX);
        [labelTrain,scoreTrain] = predict(SVMModel,trainX);
        CP_Test = classperf(testY, labelTest,'Positive',{'DR'}, 'Negative', {'SELF'});
        CP_Train = classperf(trainY, labelTrain,'Positive',{'DR'}, 'Negative', {'SELF'});

        %Train Model on AllData with Cross Validation & Analyze Performance
        SVMModelCV = fitcsvm(X(:,1:f),Y,'Crossval','on','KFold',10,'Standardize',true,'KernelFunction','gaussian','ClassNames',{'SELF','DR'});
        [labelCV,scoreCV] = kfoldPredict(SVMModelCV);
        CP_CV = classperf(Y, labelCV,'Positive',{'DR'}, 'Negative', {'SELF'});
        %Error Rate
        error = CP_CV.ErrorRate;
        %F Score
        R = CP_CV.Sensitivity;
        P = CP_CV.PositivePredictiveValue;
        fScore = 2*R*P/(R+P);
        %Generalization Error
        genError_CV = kfoldLoss(SVMModelCV);


        %% Write to Results Table
        type(end+1,1) = {'CP_Train'};
        numFeatures(end+1,1) = countFeatures;
        numObservations(end+1,1) = CP_Train.NumberOfObservations;
        sensitivity(end+1,1) = CP_Train.Sensitivity;
        specificity(end+1,1) = CP_Train.Specificity;
        errorRate(end+1,1) = CP_Train.ErrorRate;
        posPred(end+1,1) = CP_Train.PositivePredictiveValue;
        negPred(end+1,1) = CP_Train.NegativePredictiveValue;
        prevalence(end+1,1) = CP_Train.Prevalence;
        genError(end+1,1) = 0;

        type(end+1,1) = {'CP_Test'};
        numFeatures(end+1,1) = countFeatures;
        numObservations(end+1,1) = CP_Test.NumberOfObservations;
        sensitivity(end+1,1) = CP_Test.Sensitivity;
        specificity(end+1,1) = CP_Test.Specificity;
        errorRate(end+1,1) = CP_Test.ErrorRate;
        posPred(end+1,1) = CP_Test.PositivePredictiveValue;
        negPred(end+1,1) = CP_Test.NegativePredictiveValue;
        prevalence(end+1,1) = CP_Test.Prevalence;
        genError(end+1,1) = 0;

        type(end+1,1) = {'CP_CV'};
        numFeatures(end+1,1) = countFeatures;
        numObservations(end+1,1) = CP_CV.NumberOfObservations;
        sensitivity(end+1,1) = CP_CV.Sensitivity;
        specificity(end+1,1) = CP_CV.Specificity;
        errorRate(end+1,1) = CP_CV.ErrorRate;
        posPred(end+1,1) = CP_CV.PositivePredictiveValue;
        negPred(end+1,1) = CP_CV.NegativePredictiveValue;
        prevalence(end+1,1) = CP_CV.Prevalence;
        genError(end+1,1) = genError_CV;

    % end

    resultsTable = table(type,numFeatures,numObservations,sensitivity,specificity,errorRate,posPred,negPred,prevalence,genError);
end