%% Create BNET & specify its structure
X = 1;
Q = 2;
Y = 3;
dag = zeros(3,3);
dag(X,[Q Y]) = 1;
dag(Q,Y) = 1;
ns = [1 2 1]; % make X and Y scalars, and have 2 experts
onodes = [1 3];
bnet = mk_bnet(dag, ns, 'discrete', 2, 'observed', onodes);

rand('state', 0);
randn('state', 0);
bnet.CPD{1} = root_CPD(bnet, 1);
bnet.CPD{2} = softmax_CPD(bnet, 2);
bnet.CPD{3} = gaussian_CPD(bnet, 3);

data = load('/BNT/examples/static/Misc/mixexp_data.txt', '-ascii');        
plot(data(:,1), data(:,2), '.');

%% Train the Bnet
ncases = size(data, 1); % each row of data is a training case
cases = cell(3, ncases);
cases([1 3], :) = num2cell(data'); % each column of cases is a training case
engine = jtree_inf_engine(bnet);
max_iter = 20;
[bnet2, LLtrace] = learn_params_em(engine, cases, max_iter);