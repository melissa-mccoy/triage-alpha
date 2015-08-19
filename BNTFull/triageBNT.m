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

%% K2 + MWST
tMWST = learn_struct_mwst(DataNum, ones(num_nodes,1), node_sizes, 'tabular', 'mutual_info', 1);

% K2+T (Class Node is at Root - a Cause)
% Train

orderKTCause = topological_sort(full(tMWST));
dagKTCause = learn_struct_K2(DataNum, node_sizes, orderKTCause);
bnetKTCause = mk_bnet(dagKTCause, node_sizes);
%%
% rand('state', 0);
bnetKTCause.CPD{1} = root_CPD(bnetKTCause, 1);
for n = 2:num_nodes
%     psz = prod(node_sizes(parents(dagKTCause, n-1)));
%     CPT = dirichlet_sample(100*ones(1,node_sizes(n)), psz);
    bnetKTCause.CPD{n} = tabular_CPD(bnetKTCause, n, 'CPT', 'unif', 'dirichlet_weight', 1, 'dirichlet_type', 'unif');
%     bnetKTCause.CPD{n} = tabular_CPD(bnetKTCause, n,'prior_type', 'dirichlet', 'dirichlet_type', 'unif');
end
%%
bnetKTCause = bayes_update_params(bnetKTCause, DataNum);

% Test
engine = jtree_inf_engine(bnetKTCause);

% K2-T (Class Node is at End - a Consequence)
order = topological_sort(full(tMWST));
orderKTConseq = order(n:-1:1);
dagKTConseq = learn_struct_K2(Data, node_sizes, orderKTConseq);
bnetKTConseq = mk_bnet(dagdagKTConseq, node_sizes, 'names',node_names);
bnetKTConseq = bayes_update_params(bnetKTConseq, Data);

%% NB
% Naive Bayes (assumes all features are independent) 
dagNB = mk_naive_struct(num_nodes,1);
bnetNB = mk_bnet(dagNB, node_sizes, 'names',node_names);
bnetNB = bayes_update_params(bnetNB, Data);
% Augmented Naive Bayes (learns structure using MWST algorithm)
DataWithCC = [ones(num_cases,1) Data];
dagNBA = learn_struct_tan(DataWithCC, 2, 1, node_sizes,'mutual_info');
bnetNBA = mk_bnet(dagNBA, node_sizes, 'names',node_names);
bnetNBA = bayes_update_params(bnetNBA, Data);
% other options 'Bayesian' instead of 'mutual_info'?

%% MCMC
[sampled_graphs, accept_ratio, num_edges] = learn_struct_mcmc(Data, node,'Bayesian');
%other options: 'bic instead of Bayesian; ?noisy_or?, ?gaussian?, etc.
%instead of defult 'tabular'; can clamp certain nodes together meaning they
%share the same params; NOTE this method is not deterministic

%% PC
% Function to Compute Conditional Independence Tests
[CI Chi2] = cond_indep_chisquare(X, Y, S, Data, 'pearson', .01, nodes_sizes)
% PC
PDAG = learn_struct_pdag_pc('cond_indep_chisquare', num_nodes, num_nodes-2, Data);
dagPC = cpdag_to_dag(PDAG);
bnetPC = mk_bnet(dagPC, node_sizes, 'names',node_names);
bnetPC = bayes_update_params(bnetPC, Data);
% BNPC
dagBNPC = learn_struct_bnpc(Data);
bnetBNPC = mk_bnet(dagBNPC, node_sizes, 'names',node_names);
bnetBNPC = bayes_update_params(bnetBNPC, Data);
% IC
PDAG = learn_struct_pdag_ic_star('cond_indep_chisquare', num_nodes, num_nodes-2, Data);
dagIC = cpdag_to_dag(PDAG);
bnetIC = mk_bnet(dagIC, node_sizes, 'names',node_names);
bnetIC = bayes_update_params(bnetIC, Data);

%% GS
% Greedy Search
cache = [];
dagGS = learn_struct_gs2(Data, node_sizes, 'cache', cache);
bnetGS = mk_bnet(dagGS, node_sizes, 'names',node_names);
bnetGS = bayes_update_params(bnetGS, Data);
% Greedy Search in the Markove Equivalent Space
cache2 = [];
dagGSM = learn_struct_ges(Data, node_sizes,'cache',cache2);
bnetGSM = mk_bnet(dagGSM, node_sizes, 'names',node_names);
bnetGSM = bayes_update_params(bnetGSM, Data);
%scoring funciton can be 'bic' instead of default 'Bayessian'


%% Structural EM
DataNan = ;
dag = zeros(num_nodes,num_nodes);
bnet = mk_bnet(dag, node_sizes);
bnetEM = learn_struct_EM(bnet, DataNan, 10);
engine = jtree_inf_engine(bnetEM);
max_iter = 20;
bnetNBA = learn_params_em(engine, DataNan);



