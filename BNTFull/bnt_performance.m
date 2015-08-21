function BNTResults = bnt_performance(bnet,test_data,threshold)
    %% Test Performance
    drProbs = []; selfProbs = [];
    num_cases_test = size(test_data,2);
    num_nodes = size(test_data,1);
    for c = 1:num_cases_test
        disp(c);
        evidence = {};
        for n = 2:num_nodes
            evidence{n} = test_data(n,c);
        end
        engine = jtree_inf_engine(bnet);
        [engine, loglik] = enter_evidence(engine, evidence);
        m = marginal_nodes(engine, 1);
        drProbs(end+1) = m.T(1); selfProbs(end+1) = m.T(2); 
    end
     %% Calculate Performance
%     % Using Threshold Decision Rule
%     predLabels = zeros(1,size(drProbs,2)); predLabels(:) = 2; predLabels(drProbs >= threshold) = 1;
    % Using MAP decision rule (whichever has higher probability)
    predLabels = zeros(1,size(drProbs,2)); predLabels(:) = 2; predLabels(drProbs >= selfProbs) = 1;
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
    
end