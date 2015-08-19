function [ criterion ] = my_fun_lib(trainX,trainY,testX,testY)

    bestc = '1';
    model = svmtrain(trainY, trainX,['-s 0 -t 0 -c ' bestc]);
    criterion = sum(svmpredict(testY, testX, model) ~= testY);

%     SVMModel = svmtrain(trainY, trainX,['-s 0 -t 0 -c ' bestc]);
%     [labelTest,accuracyTest,probEstimatesTest] = svmpredict(testY,testX,SVMModel);
%     criterion = (100-accuracyTest(1));
%     disp(['trainY: ' num2str(size(trainY,1))]);
%     disp(['trainX: ' num2str(size(trainX,1)) ' x ' num2str(size(trainX,2))]);
%     disp(['testY: ' num2str(size(testY,1))]);
%     disp(['testX: ' num2str(size(testX,1)) ' x ' num2str(size(testX,2))]);
%     disp(['labelTest: ' num2str(size(labelTest,1))]);
%    
end

