clear;
clc;
O = 3*48*2*2;
Q = 2;

% "true" parameters
% prior0 = normalise(rand(Q,1));
% transmat0 = mk_stochastic(rand(Q,Q));
% obsmat0 = mk_stochastic(rand(Q,O));

% training data
% T = 5;
% nex = 10;
data = importdata('sample_data_9.mat');

% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1 = mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));

% improve guess of parameters using EM
[LL, prior2, transmat2, obsmat2] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', 20);
LL
prior2
transmat2
obsmat2
% use model to compute log likelihood
loglik = dhmm_logprob(data, prior2, transmat2, obsmat2)
% log lik is slightly different than LL(end), since it is computed after the final M step

data = num2cell(data, 2);
index = 1;
obs = data{index};
obslik = multinomial_prob(obs, obsmat2);

[alpha, beta, gamma, loglik, xi, gamma2] = fwdback(prior2, transmat2, obslik, 'fwd_only', 1)
alpha
result_seq = zeros(1,size(alpha,2));
for i = 1:size(result_seq,2)
    if alpha(1,i) >= alpha(2,i)
        result_seq(i) = 1;
    else
        result_seq(i) = 2;
    end
end
plot(result_seq)