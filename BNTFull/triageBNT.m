%% Data Preparation
% Capture Metadata & Replace choices with integers)
Data = transpose(table2cell(XY_BNT));
num_nodes = size(Data,1);
num_cases = size(Data,2);
node_sizes = zeros(1,num_nodes);
node_names = XY_BNT.Properties.VariableNames;
node_choices = cell(1,num_nodes);
DataNum = zeros(size(Data,1),size(Data,2));

for r = 1:num_nodes
    this_node_choices = unique(Data(r,:));
    eval(['node_choices.' node_names{r} ' = this_nodes_choices;'])
    node_sizes(r) = size(this_node_choices,2);
    this_node_vals = Data(r,:);
    for choice = 1:size(this_node_choices,2)
        this_node_vals(strcmp(this_node_choices{choice}, this_node_vals)) = {choice};
    end
    DataNum(r,:) = cell2mat(this_node_vals);
end

% Break into test & train
train_index = fix(num_cases*.75);
train_data = DataNum(:,1:train_index);
num_cases_train = train_index;
test_index = train_index+1;
test_data = DataNum(:,test_index:end);
num_cases_test = (num_cases-test_index+1);


%% K2+T (Class Node is at Root - a Cause)
% Train
tMWST = learn_struct_mwst(train_data, ones(num_nodes,1), node_sizes, 'tabular', 'mutual_info', 1);
orderKTCause = topological_sort(full(tMWST));
dagKTCause = learn_struct_K2(train_data, node_sizes, orderKTCause);
bnetKTCause = mk_bnet(dagKTCause, node_sizes);
for n = 1:num_nodes
    bnetKTCause.CPD{n} = tabular_CPD(bnetKTCause, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
bnetKTCause = bayes_update_params(bnetKTCause, train_data);

% Test
posProbs = [];
for c = 1:num_cases_test
    disp(c);
    evidence = {};
    for n = 2:num_nodes
        evidence{n} = test_data(n,c);
    end
    engine = jtree_inf_engine(bnetKTCause);
    [engine, loglik] = enter_evidence(engine, evidence);
    m = marginal_nodes(engine, 1);
    posProbs(end+1) = m.T(1);
end

%% Calculate Performance
threshold = .2;
predLabels = zeros(1,size(posProbs,2)); predLabels(:) = 2; predLabels(posProbs >= threshold) = 1;
actLabels = test_data(1,:);
errRate = sum(predLabels ~= actLabels)/num_cases_test;
truPos = 0; truNeg = 0; falPos = 0; falNeg = 0; count = 0;
for l=1:num_cases_test
    if actLabels(l) == 1
        if predLabels(l) == actLabels(l)
            truPos = truPos + 1;
        else
           falNeg = falNeg + 1;
        end
    elseif actLabels(l) == 2
        if predLabels(l) == actLabels(l)
            truNeg = truNeg + 1;
        else
            falPos = falPos + 1;
        end
    end
end
sens = truPos/(truPos+falNeg);
spec = truNeg/(truNeg+falPos);
BNTResults = [errRate, sens, spec];
plot(actLabels, posProbs, 'X');

%% K2-T (Class Node is at End - a Consequence)
% Learn Structure
tMWST = learn_struct_mwst(train_data, ones(num_nodes,1), node_sizes, 'tabular', 'mutual_info', 1);
order = topological_sort(full(tMWST));
orderKTConseq = order(size(order,2):-1:1);
dagKTConseq = learn_struct_K2(train_data, node_sizes, orderKTConseq);
bnetKTConseq = mk_bnet(dagKTConseq, node_sizes);
for n = 1:num_nodes
    bnetKTConseq.CPD{n} = tabular_CPD(bnetKTConseq, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Parameters
bnetKTConseq = bayes_update_params(bnetKTConseq, train_data);

% Test Performance
posProbs = [];
for c = 1:num_cases_test
    disp(c);
    evidence = {};
    for n = 2:num_nodes
        evidence{n} = test_data(n,c);
    end
    engine = jtree_inf_engine(bnetKTConseq);
    [engine, loglik] = enter_evidence(engine, evidence);
    m = marginal_nodes(engine, 1);
    posProbs(end+1) = m.T(1);
end
% Calculate Performance
threshold = .25;
predLabels = zeros(1,size(posProbs,2)); predLabels(:) = 2; predLabels(posProbs >= threshold) = 1;
actLabels = test_data(1,:);
errRate = sum(predLabels ~= actLabels)/num_cases_test;
truPos = 0; truNeg = 0; falPos = 0; falNeg = 0; count = 0;
for l=1:num_cases_test
    if actLabels(l) == 1
        if predLabels(l) == actLabels(l)
            truPos = truPos + 1;
        else
           falNeg = falNeg + 1;
        end
    elseif actLabels(l) == 2
        if predLabels(l) == actLabels(l)
            truNeg = truNeg + 1;
        else
            falPos = falPos + 1;
        end
    end
end
sens = truPos/(truPos+falNeg);
spec = truNeg/(truNeg+falPos);
BNTResults = [errRate, sens, spec];

%% Naive Bayes (assumes all features are independent) 
% Creat Struct
dagNB = mk_naive_struct(num_nodes,1);
bnetNB = mk_bnet(dagNB, node_sizes);
for n = 1:num_nodes
    bnetNB.CPD{n} = tabular_CPD(bnetNB, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetNB = bayes_update_params(bnetNB, train_data);
% Test
threshold = .4;
BNTResults = bnt_performance(bnetNB,test_data,threshold);

%% Augmented Naive Bayes (learns structure using MWST algorithm)
% Learn Struct
train_data_cc = [train_data; ones(1,num_cases_train)];
node_sizes_cc = [node_sizes 1];
dagNBA = learn_struct_tan(train_data_cc, 1, (num_nodes+1), node_sizes_cc,'mutual_info');
bnetNBA = mk_bnet(dagNBA, node_sizes_cc);
for n = 1:(num_nodes+1)
    bnetNBA.CPD{n} = tabular_CPD(bnetNBA, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetNBA = bayes_update_params(bnetNBA, train_data_cc);
% other options 'Bayesian' instead of 'mutual_info'?
% Test
threshold = .3;
test_data_cc = [test_data; ones(1,num_cases_test)];
BNTResults = bnt_performance(bnetNBA,test_data_cc,threshold);

%% MCMC
[sampled_graphs, accept_ratio, num_edges] = learn_struct_mcmc(DataNum, node,'Bayesian');
mcmc_post = mcmc_sample_to_hist(sampled_graphs, dags);
%other options: 'bic instead of Bayesian; ?noisy_or?, ?gaussian?, etc.
%instead of defult 'tabular'; can clamp certain nodes together meaning they
%share the same params; NOTE this method is not deterministic

%% PC
% Function to Compute Conditional Independence Tests
% [CI Chi2] = cond_indep_chisquare(chiX, chiY, chiS, train_data, 'pearson', .01, node_sizes);
% Learn Structure
PDAG = learn_struct_pdag_pc('cond_indep_chisquare', num_nodes, num_nodes-2, train_data);
dagPC = cpdag_to_dag(PDAG);
bnetPC = mk_bnet(dagPC, node_sizes);
for n = 1:num_nodes
    bnetPC.CPD{n} = tabular_CPD(bnetPC, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetPC = bayes_update_params(bnetPC, train_data);
% Test
threshold = .4;
BNTResults = bnt_performance(bnetPC,test_data,threshold);
%% BNPC
dagBNPC = learn_struct_bnpc(train_data);
bnetBNPC = mk_bnet(dagBNPC, node_sizes);
for n = 1:num_nodes
    bnetBNPC.CPD{n} = tabular_CPD(bnetBNPC, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetBNPC = bayes_update_params(bnetBNPC, train_data);
% Test
threshold = .4;
BNTResults = bnt_performance(bnetBNPC,test_data,threshold);
%% IC
PDAG = learn_struct_pdag_ic_star('cond_indep_chisquare', num_nodes, num_nodes-2, Data);
dagIC = cpdag_to_dag(PDAG);
bnetIC = mk_bnet(dagIC, node_sizes);
for n = 1:num_nodes
    bnetIC.CPD{n} = tabular_CPD(bnetIC, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetIC = bayes_update_params(bnetIC, train_data);
% Test
threshold = .4;
BNTResults = bnt_performance(bnetIC,test_data,threshold);

%% GS (Greedy Search)
cache = [];
dagGS = learn_struct_gs2(Data, node_sizes, 'cache', cache);
bnetGS = mk_bnet(dagGS, node_sizes, 'names',node_names);
for n = 1:num_nodes
    bnetGS.CPD{n} = tabular_CPD(bnetGS, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetGS = bayes_update_params(bnetGS, train_data);
% Test
threshold = .4;
BNTResults = bnt_performance(bnetGS,test_data,threshold);
%% GSM (Greedy Search in the Markove Equivalent Space)
cache2 = [];
dagGSM = learn_struct_ges(Data, node_sizes,'cache',cache2);
bnetGSM = mk_bnet(dagGSM, node_sizes, 'names',node_names);
for n = 1:num_nodes
    bnetGSM.CPD{n} = tabular_CPD(bnetGSM, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
% Learn Params
bnetGSM = bayes_update_params(bnetGSM, train_data);
% Test
threshold = .4;
BNTResults = bnt_performance(bnetGSM,test_data,threshold);
%scoring funciton can be 'bic' instead of default 'Bayessian'


%% Structural EM
DataNan = ;
dagSEM = zeros(num_nodes,num_nodes);
bnetSEM = mk_bnet(dagSEM, node_sizes);
bnetSEM = learn_struct_EM(bnetSEM, DataNan, 10);
for n = 1:num_nodes
    bnetSEM.CPD{n} = tabular_CPD(bnetSEM, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
end
bnetNBA = learn_params_em(engine, DataNan);
engine = jtree_inf_engine(bnetSEM);
max_iter = 20;




