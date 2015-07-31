%% Diagnostic Tests

% Learning Curves
% For SVM w/o CV
m = size(trainY,1);
error_train = zeros(m-1, 1);
error_val   = zeros(m-1, 1);
for i = 2:m
   SVMModel = fitcsvm(trainX(1:i,:),trainY(1:i,:),'Standardize',true,'KernelFunction','linear','ClassNames',{'SELF','DR'});
   
   [labelTrain,scoreTrain] = predict(SVMModel,trainX(1:i,:));
   cpTrain = classperf(trainY(1:i,:), labelTrain);
   error_train(i-1) = cpTrain.ErrorRate;
   
   [labelTest,scoreTest] = predict(SVMModel,testX);
   cpTest = classperf(testY, labelTest);
   error_val(i-1) = cpTest.ErrorRate;
end
x=linspace(2,m,m-1);
plot(x,error_train,x,error_val);



