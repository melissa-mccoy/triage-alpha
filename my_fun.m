function [ criterion ] = my_fun(trainX,trainY,testX,testY)

%     SVMModel = fitcsvm(trainXMat,trainY,'Standardize',true,'KernelFunction','linear','ClassNames',{'SELF','DR'});
%     [labelTest,scoreTest] = predict(SVMModel,testX);
%     CP_Test = classperf(testY, labelTest,'Positive',{'DR'}, 'Negative', {'SELF'});

SVMModelCV = fitcsvm(trainX,trainY,'Crossval','on','KFold',10,'Standardize',true,'KernelFunction','linear','ClassNames',{'SELF','DR'});
criterion = kfoldLoss(SVMModelCV);
end

