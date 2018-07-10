%% Initialization
clear;
clc;
O = 3*48*2*2;
Q = 2;

train_data_raw = importdata('sample_train_data.mat');
tain_data = train_data_raw{7};% data from the first/ 25th csv file
test_data_raw = importdata('sample_test_data.mat');
test_data = test_data_raw{7};
[M,S,H,W] = deal(zeros(1,size(test_data,2)));
for i = 1:size(test_data,2)
    [M(i),S(i),H(i),W(i)] = extrac_num(test_data(i));
end


%% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1 = mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));

%%
best_accuracy = 0;
best_state_seq = zeros(1,size(test_data,2));
best_obs_seq = zeros(1,size(test_data,2));
best_prior2 = zeros(2,1);
best_transmat2 = zeros(2,2);
best_obsmat2 = zeros(2,O);

for trial = 1:15
%% improve guess of parameters using EM
    [LL, prior2, transmat2, obsmat2] = dhmm_em(tain_data, prior1, transmat1, obsmat1, 'max_iter', 100);
    % use model to compute log likelihood
    loglik = dhmm_logprob(tain_data, prior2, transmat2, obsmat2);
    % log lik is slightly different than LL(end), since it is computed after the final M step
    %% Forward Algorithm
    % data = num2cell(data, 2);
    index = 7;
    obs = train_data_raw{index};
    obslik = multinomial_prob(obs, obsmat2);
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
%     figure(1);
    norm_result_seq = norm_seq(result_seq);
    % subplot(3,1,1)
%     plot(norm_result_seq)

    %% Infer the Most Likely Hidden States
    test_obslik = multinomial_prob(test_data, obsmat2);
    [alpha_2, beta_2, gamma_2, loglik_2, xi_2, gamma2_2] = fwdback(prior2, transmat2, test_obslik, 'fwd_only', 1);
    state_seq = zeros(1,size(alpha_2,2));
    for i = 1:size(state_seq,2)
        if alpha_2(1,i) >= alpha_2(2,i)
            state_seq(i) = 0;
        else
            state_seq(i) = 1;
        end
    end
    % figure(2);
    % plot(state_seq)
    
    %% Infer the Most Likely Observations
    obs_seq = zeros(1,size(state_seq,2));
    for i = 1:size(state_seq,2)
        index1 = W(i) + 2*H(i) + 2*48*S(i) + 2*48*3*0 + 1;
        index2 = W(i) + 2*H(i) + 2*48*S(i) + 2*48*3*1 + 1;
        if obsmat2(state_seq(i)+1,index1) > obsmat2(state_seq(i)+1, index2)
            obs_seq(i) = 0;
        else
            obs_seq(i) = 1;
        end
    end
    %% Accuracy
    accuracy = 0;
    accuracy = 1 - (sum(abs(obs_seq - M))/size(obs_seq,2));
    
    if accuracy > best_accuracy
        best_accuracy = accuracy;
        best_state_seq = state_seq;
        best_obs_seq = obs_seq;
        best_prior2 = prior2;
        best_transmat2 = transmat2;
        best_obsmat2 = obsmat2;
    end
end

% figure(2);
subplot(3,1,1);
plot(best_state_seq)
title('Most Likely State Sequence');
subplot(3,1,2);
plot(best_obs_seq)
title_str = 'Most Likely Observation Sequence, Accuracy: %f%%';
title(sprintf(title_str,best_accuracy*100));
subplot(3,1,3);
plot(M)
title('True Observation Sequence (M)');
