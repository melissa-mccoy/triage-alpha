function [ criterion ] = my_fun_lib(trainX,trainY,testX,testY)

    cParam = 1;
    SVMModel = svmtrain(trainY, trainX,['-s 0 -t 0 -c ' num2str(cParam)]);
    [labelTest,accuracyTest,probEstimatesTest] = svmpredict(testY,testX,SVMModel);
    disp(['trainY: ' num2str(size(trainY,1))]);
    disp(['trainX: ' num2str(size(trainX,1)) ' x ' num2str(size(trainX,2))]);
    disp(['testY: ' num2str(size(testY,1))]);
    disp(['testX: ' num2str(size(testX,1)) ' x ' num2str(size(testX,2))]);
    disp(['labelTest: ' num2str(size(labelTest,1))]);
    criterion = (100-accuracyTest(1));
    
%     Use CrossValidation Accuracy As Criterion
%     bestc = '8';
%     criterion = svmtrain(labels, features_sparse, ['-v 5 -s 0 -t 0 -w-1 -c ' bestc]);
end

