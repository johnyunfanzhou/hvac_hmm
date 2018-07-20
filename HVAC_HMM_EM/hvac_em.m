%% Initialization
clear;
clc;
O = 3*48*2*2;
Q = 2;

train_data_raw = importdata('sample_train_data.mat');
file_index = 25;
train_data = train_data_raw{file_index};% data from the first/ 25th csv file

result_seq_total = zeros(1,size(train_data,2));
norm_result_seq_total = norm_seq(result_seq_total);
path_total =  zeros(1,size(train_data,2));
normed_path_total = norm_seq(path_total);

num_trial = 30;
for trial = 1:num_trial
%% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1 = mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));

%% improve guess of parameters using EM
[LL, prior2, transmat2, obsmat2] = dhmm_em(train_data, prior1, transmat1, obsmat1, 'max_iter', 50);
LL

% use model to compute log likelihood
loglik = dhmm_logprob(train_data, prior2, transmat2, obsmat2)
% log lik is slightly different than LL(end), since it is computed after the final M step
%% Forward Algorithm
% data = num2cell(data, 2);

% obs = train_data_raw{file_index};
obslik = multinomial_prob(train_data, obsmat2);
% plot(norm_seq(obslik))
[alpha, beta, gamma, loglik, xi, gamma2] = fwdback(prior2, transmat2, obslik, 'fwd_only', 1);
% result_seq = alpha
result_seq = zeros(1,size(alpha,2));
for i = 1:size(result_seq,2)
    if alpha(1,i) >= alpha(2,i)
        result_seq(i) = 1;
    else
        result_seq(i) = 2;
    end
end
norm_result_seq = norm_seq(result_seq);

figure(1);
% subplot(4,1,1)
% plot(alpha(1,14000:15400))
subplot(4,1,1)
% plot(norm_result_seq)
plot(result_seq(1:48))
title('First Day Sequence in Forward Algorithm');

subplot(4,1,2)
plot(norm_result_seq)
title('Average Day in Forward Algorithm');

result_seq_total = result_seq_total + result_seq;
norm_result_seq_total = norm_result_seq_total + norm_result_seq;

%% Viterbi
avg_path = zeros(1,size(train_data,2));
counter = 0;
path = viterbi_path(prior2, transmat2, obslik);
path_total = path_total + path;

subplot(4,1,3)
plot(path(1:48))
title('First Day in Viterbi Algorithm');

% for trial = 1:30
%     path = viterbi_path(prior2, transmat2, obslik);
%     avg_path = avg_path + path;
%     counter = counter + 1;
% end
% avg_path = avg_path ./ counter;

% subplot(4,1,3)
% plot(path(1:48))
% title('First Day in Viterbi Algorithm');

normed_path = norm_seq(path);
normed_path_total = normed_path_total + normed_path;

subplot(4,1,4)
plot(normed_path)
title('Average Day in Viterbi Algorithm');
ylim([1,2])

%% Infer the most likely Observations
% test_data_raw = importdata('sample_test_data.mat');
% test_data = test_data_raw{25};
% [M,S,H,W] = deal(zeros(1,size(test_data,2)));
% for i = 1:size(test_data,2)
%     [M(i),S(i),H(i),W(i)] = extrac_num(test_data(i));
% end
% test_obslik = multinomial_prob(test_data, obsmat2);
% 
% [alpha_2, beta_2, gamma_2, loglik_2, xi_2, gamma2_2] = fwdback(prior2, transmat2, test_obslik, 'fwd_only', 1);
% state_seq = zeros(1,size(alpha_2,2));
% for i = 1:size(state_seq,2)
%     if alpha_2(1,i) >= alpha_2(2,i)
%         state_seq(i) = 0;
%     else
%         state_seq(i) = 1;
%     end
% end
% figure(2);
% plot(state_seq)

% %% Accuracy
% accuracy = 0;
% accuracy = 1 - sum(abs(state_seq - M))/size(state_seq,2);

% figure(2);
% subplot(2,1,1);
% plot(state_seq)
% subplot(2,1,2);
% plot(M)
%% Similarity
similarity = 0;
similarity = 1- sum(abs(norm_result_seq - normed_path))/size(norm_result_seq,2)
end

result_seq_total = result_seq_total ./ num_trial;
norm_result_seq_total = norm_result_seq_total ./ num_trial;
path_total = path_total ./ num_trial;
normed_path_total = normed_path_total ./ num_trial;

figure(2);
subplot(4,1,1)
plot(result_seq_total(1:48))
title('First Day Sequence in Forward Algorithm');
ylim([1,2]);

subplot(4,1,2)
plot(norm_result_seq_total)
title('Average Day in Forward Algorithm');
ylim([1,2]);

subplot(4,1,3)
plot(path_total(1:48))
title('First Day in Viterbi Algorithm');
ylim([1,2]);

subplot(4,1,4)
plot(normed_path_total)
title('Average Day in Viterbi Algorithm');
ylim([1,2]);

similarity = 1- sum(abs(norm_result_seq_total - normed_path_total))/size(norm_result_seq_total,2)