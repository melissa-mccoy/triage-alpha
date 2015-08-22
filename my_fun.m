function [ criterion ] = my_fun(trainX,trainY,testX,testY)

    SVMModel = fitcsvm(trainX,trainY,'Standardize',true,'KernelFunction','linear');
    [labelTest,scoreTest] = predict(SVMModel,testX);
    CP_Test = classperf(testY, labelTest,'Positive',1, 'Negative', 0);
    criterion = CP_Test.ErrorRate;

% SVMModelCV = fitcsvm(trainX,trainY,'Crossval','on','KFold',10,'Standardize',true,'KernelFunction','linear','ClassNames',{'SELF','DR'});
% criterion = kfoldLoss(SVMModelCV);
 
end

