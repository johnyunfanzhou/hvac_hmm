%% Initialization
clear;
clc;
O = 3*48*2*2;
Q = 2;

data_raw = importdata('sample_data_9.mat');
data = data_raw{1};% data from the first csv file

%% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1 = mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));

%% improve guess of parameters using EM
[LL, prior2, transmat2, obsmat2] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', 100);
LL
prior2
transmat2
obsmat2
% use model to compute log likelihood
loglik = dhmm_logprob(data, prior2, transmat2, obsmat2)
% log lik is slightly different than LL(end), since it is computed after the final M step
%% Forward Algorithm
% data = num2cell(data, 2);
index = 1;
obs = data_raw{index};
obslik = multinomial_prob(obs, obsmat2);
% plot(norm_seq(obslik))
[alpha, beta, gamma, loglik, xi, gamma2] = fwdback(prior2, transmat2, obslik, 'fwd_only', 1)
% result_seq = alpha
result_seq = zeros(1,size(alpha,2));
for i = 1:size(result_seq,2)
    if alpha(1,i) >= alpha(2,i)
        result_seq(i) = 1;
    else
        result_seq(i) = 2;
    end
end

% norm_result_seq = zeros(1,48);
% for i = 1:size(norm_result_seq,2)
%     j = i;
%     while j <= size(result_seq,2)
%         norm_result_seq(i) = norm_result_seq(i) + result_seq(j);
%         j = j + 48;
%     end
% end
% norm_result_seq = norm_result_seq ./ (size(result_seq,2)/48);
norm_result_seq = norm_seq(result_seq);
subplot(3,1,1)
plot(norm_result_seq)

%% Viterbi
path = viterbi_path(prior2, transmat2, obslik);
subplot(3,1,2)
plot(path(1:48))

normed_path = norm_seq(path);

subplot(3,1,3)
plot(normed_path)
ylim([1,2])

