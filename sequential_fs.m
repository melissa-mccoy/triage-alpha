function [ criterion ] = sequential_fs(trainX,trainY,testX,testY)
    fivefoldCVP = cvpartition(trainY,'KFold',5);
    inmodel = sequentialfs(@my_fun_lib,trainX,trainY,'cv',fivefoldCVP);
    bestc = 120;
    bestg = .002;
    model = svmtrain(trainY, trainX,['-s 0 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg)]);
    criterion = sum(svmpredict(testY, testX(:,inmodel), model) ~= testY);
end    