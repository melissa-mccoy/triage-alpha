%% Create BNET
N = 4; 
dag = zeros(N,N);
C = 1; S = 2; R = 3; W = 4;
dag(C,[R S]) = 1;
dag(R,W) = 1;
dag(S,W)=1;
node_sizes = [4 2 3 5];
bnet = mk_bnet(dag, node_sizes, 'names', {'C','S','R','W'});
% Not Working because of Reshape Issue 
% bnet.CPD{C} = tabular_CPD(bnet, C, [0.5 0.5]);
% bnet.CPD{R} = tabular_CPD(bnet, R, [0.8 0.2 0.2 0.8]);
% bnet.CPD{S} = tabular_CPD(bnet, S, [0.5 0.9 0.5 0.1]);
% bnet.CPD{W} = tabular_CPD(bnet, W, [1 0.1 0.1 0.01 0 0.9 0.9 0.99]);


%% Fill with random probabiltiy tables
for i=1:size(node_sizes,2)
    k = node_sizes(i);
    ps = parents(dag, i);
    psz = prod(node_sizes(ps));
    CPT = dirichlet_sample(1000*ones(1,k), psz);
    bnet.CPD{i} = tabular_CPD(bnet, i, 'CPT', CPT);
end

%% Infer
engine = jtree_inf_engine(bnet);
% Probability that sprinkler was on given the grass was wet
evidence = cell(1,N);
evidence{W} = 2;
[engine, loglik] = enter_evidence(engine, evidence);
marg = marginal_nodes(engine, S);
p = marg.T(2);