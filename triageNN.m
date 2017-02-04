%% Load X & Y (where rows are cases and cols are features)
% nnData = table2cell(XY_NN);
% inputX = nnData(:,2:end);
% inputY = nnData(:,1);
% num_features = size(inputX,2);
% num_cases = size(inputX,1);
% dumX = [];
% features = [];
%     for c = 1:num_features
%         features = [features; unique(inputX(:,c))];
%         dumX = [dumX dummyvar(nominal(inputX(:,c)))];
%     end
% dumY = dummyvar(nominal(inputY));

Data = transpose(table2cell(XY_NN));
cellX = Data(2:end,:);
cellY = Data(1,:);
num_features = size(cellX,1);
num_cases = length(cellY);
node_names = XY_NN.Properties.VariableNames;

MatX = zeros(size(cellX,1),size(cellX,2));
MatY = tranpose(dummyvar(nominal(transpose(cellY))));
% Achieves the same thing as grp2idx(featureVector)
for r = 1:num_features
    this_node_choices = unique(cellX(r,:));
    eval(['node_choices.' node_names{r} ' = this_nodes_choices;'])
    node_sizes(r) = size(this_node_choices,2);
    this_node_vals = cellX(r,:);
    for choice = 1:size(this_node_choices,2)
        this_node_vals(strcmp(this_node_choices{choice}, this_node_vals)) = {choice};
    end
    MatX(r,:) = cell2mat(this_node_vals);
end
% %% Tranpose dumX & dumY (so rows are features and cols are cases)
% dumX = transpose(dumX);
% dumY = transpose(dumY);

%% Initiate & Train Network
net = patternnet(5);
[net,tr] = train(net,MatX,MatY);
nntraintool
plotperform(tr)

%Best VAl Performance is .18