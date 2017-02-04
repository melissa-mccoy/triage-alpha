%% Prep Data

    
inputX = XY_pc_throat(:,2:end);
Y = XY_pc_throat.(1);
dumX = table;
features = [];
for c = 1:size(inputX,2)
    features = [features; unique(inputX.(c))];
    dumX.(c) = dummyvar(nominal(inputX.(c)));
end
dumY = dummyvar(nominal(Y));

XMat = cell2mat(table2cell(dumX));
YMat = dumY(:,1);

tenfoldCVP = cvpartition(YMat,'kfold',10);

%% None
noneCV = crossval(@none_fs,XMat,YMat,'partition',tenfoldCVP);
noneError = transpose(noneCV)/tenfoldCVP.TestSize;

%% ReliefF
relieffCV = crossval(@relieff_fs,XMat,YMat,'partition',tenfoldCVP);
relieffError = transpose(relieffCV)/tenfoldCVP.TestSize;

%% MaxRelevance+ Wrapper
maxrelCV = crossval(@maxrel_fs,XMat,YMat,'partition',tenfoldCVP);
maxrelError = transpose(maxrelCV)/tenfoldCVP.TestSize;

%% MinRedunancy+ Wrapper
minredCV = crossval(@minred_fs,XMat,YMat,'partition',tenfoldCVP);
minredError = transpose(minredCV)/tenfoldCVP.TestSize;

%% mRMR+ Wrapper
mrmrCV = crossval(@mrmr_fs,XMat,YMat,'partition',tenfoldCVP);
mrmrError = transpose(mrmrCV)/tenfoldCVP.TestSize;
%% mRMR_mio+ Wrapper
mrmrCV = crossval(@mrmr_mio_fs,XMat,YMat,'partition',tenfoldCVP);
mrmrMIOError = transpose(mrmrCV)/tenfoldCVP.TestSize;

%% Sequential Feature Selection
sequentialCV = crossval(@sequential_fs,XMat,YMat,'partition',tenfoldCVP);
sequentialError = transpose(sequentialCV)/tenfoldCVP.TestSize;





