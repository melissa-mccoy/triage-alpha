%% Load X & Y (where rows are cases and cols are features)
nnData = table2cell(XY_NN);
inputX = nnData(:,2:end);
inputY = nnData(:,1);
num_features = size(inputX,2);
num_cases = size(inputX,1);
%%
dumX = [];
features = [];
    for c = 1:num_features
        features = [features; unique(inputX(:,c))];
        dumX = [dumX dummyvar(nominal(inputX(:,c)))];
    end
dumY = dummyvar(nominal(inputY));
% for r = 1:num_features
%     features = [features; unique(inputX(r,:))];
%     dumX = [dumX; transpose(dummyvar(nominal(transpose(inputX(r,:)))))];
% end
% dumY = transpose(dummyvar(nominal(transpose(inputY))));

%% Initiate Network
net = patternnet(10);

%% Train Network
[net,tr] = train(net,dumX,dumY);
nntraintool
plotperform(tr)