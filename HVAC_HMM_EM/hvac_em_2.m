O = 3*48*2*2;
Q = 2;

test_files = ["test_1cca90adb7de8aabbb74be37171e805ba6dd74e8.csv"
                ,"test_2cceb7f426f847d09f9c4d15808e24884bb3dbf8.csv"
                ,"test_02d4dbbdec6d776bf72ef3ee530ef2de918ce363.csv"
                ,"test_7d9bf619d6d3c19e16ef6702a90f816fccee5786.csv"
                ,"test_7db7d2b15622a495dac614fbdd158a8d9a33d656.csv"
                ,"test_35bdf3e00084fce2a0d2abbb0e7cd785e921823f.csv"
                ,"test_53e2551fffa9c249843080675f9e780e1a4db041.csv"
                ,"test_63d5d2618d055003be3a73071da4b5cbaec8f2ee.csv"
                ,"test_75b6b3ac33d35f887313468ee62f1a99c96000f6.csv"
                ,"test_86dbd90f921d838a4521f5a01b58951a431fbe23.csv"
                ,"test_583ef0c5d9dd4beefd5c16d9f52f39f560a20140.csv"
                ,"test_2250e1dc735fd0faa56e62c8ff61d286f0074a16.csv"
                ,"test_4234c00c716610fdd6ed369fe2745b59c0149312.csv"
                ,"test_4787f63d478fa706c63b8a09a106f683791da3c7.csv"
                ,"test_9158c348bce8a7636564d7928afb75420f88307e.csv"
                ,"test_212825c18b59f3faab8a9fab9e88f87426cb5d3a.csv"
                ,"test_716436602a0820a58892e51e8f131c7a699e7b7a.csv"
                ,"test_b510c2b4f4a2cff8a0cba279a4f3b9fd8490fb59.csv"
                ,"test_bdd49d5cb90eef2f1e0e8f97478936321c39be53.csv"
                ,"test_c798c4784802c709e2c5d7790f0d3c464d52d395.csv"
                ,"test_c5748e664560ff6462dbe033bcff33f2b6a7a31e.csv"
                ,"test_d0ce32cf46f3e7267fedccdc89caa88a07ee409d.csv"
                ,"test_f55c7ebf8c354c1fbe2b86c9d15032e47de83780.csv"
                ,"test_f411422c063f9d0809def300e7657a9f6d63b1ef.csv"
                ,"test_f6178010526fce4bebc535194b3ccc6c9ebe19ad.csv"];

accuracy_total = zeros(1,size(test_files,1));
err_per_day_total = [];
g = [];

for file_index = 1:25
    %% Initialization
%     clear;
%     clc;

%     file_index = num_file;
    train_data_raw = importdata('sample_train_data.mat');
    train_data = train_data_raw{file_index};% data from the first/ 25th csv file
    test_data_raw = importdata('sample_test_data.mat');
    test_data = test_data_raw{file_index};
    days_data_raw = importdata('sample_days_data.mat');
    days_data = days_data_raw{file_index};
    
    [M,S,H,W] = deal(zeros(1,size(test_data,2)));
    for i = 1:size(test_data,2)
        [M(i),S(i),H(i),W(i)] = extrac_num(test_data(i));
    end

    % %% initial guess of parameters
    % prior1 = normalise(rand(Q,1));
    % transmat1 = mk_stochastic(rand(Q,Q));
    % obsmat1 = mk_stochastic(rand(Q,O));

    %%
    best_accuracy = 0;
    best_state_seq = zeros(1,size(test_data,2));
    best_obs_seq = zeros(1,size(test_data,2));
    best_prior2 = zeros(2,1);
    best_transmat2 = zeros(2,2);
    best_obsmat2 = zeros(2,O);

    for trial = 1:30
        %% initial guess of parameters
        prior1 = normalise(rand(Q,1));
        transmat1 = mk_stochastic(rand(Q,Q));
        obsmat1 = mk_stochastic(rand(Q,O));

        %% improve guess of parameters using EM
        [LL, prior2, transmat2, obsmat2] = dhmm_em(train_data, prior1, transmat1, obsmat1, 'max_iter', 100);
        % use model to compute log likelihood
        loglik = dhmm_logprob(train_data, prior2, transmat2, obsmat2);
        % log lik is slightly different than LL(end), since it is computed after the final M step
        %% Forward Algorithm
        % data = num2cell(data, 2);
    %     index = 7;
        obs = train_data;
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

        %% Infer the Most Likely Hidden States in Test Data
        test_obslik = multinomial_prob(test_data, obsmat2);
        for i = 1:size(test_obslik,2)
            if test_obslik(1,i) == 0
                test_obslik(1,i) = 1e-23;
            end
        end
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
        error = abs(obs_seq - M)
        accuracy = 0;
        accuracy = 1 - (sum(error)/size(obs_seq,2))
        best_accuracy
        if accuracy > best_accuracy
            best_accuracy = accuracy;
            best_state_seq = state_seq;
            best_obs_seq = obs_seq;
            best_prior2 = prior2; 
            best_transmat2 = transmat2;
            best_obsmat2 = obsmat2;
        end
    end
    
    accuracy_total(file_index) = best_accuracy;
    figure(1);
    subplot(3,1,1);
    plot(best_state_seq)
    title({test_files(file_index);'Most Likely State Sequence'},'Interpreter','none');
    subplot(3,1,2);
    plot(best_obs_seq)
    title_str = 'Most Likely Observation Sequence, Accuracy: %f%%';
    title(sprintf(title_str,best_accuracy*100));
    subplot(3,1,3);
    plot(M)
    title('True Observation Sequence (M)');
%     saveas(gcf, strcat(test_files(file_index),'.jpg'));
    
    %% Error Analysis
    err_per_day = zeros(1,size(days_data,2));
    j = 1;
    while j <= size(error,2)
        for i = 1:size(days_data,2)
            err_per_day(i) = sum(error(j:(j+days_data(i)-1)));
            j = j + days_data(i);
        end
    end
%     if size(err_per_day,2) == 20
%         err_per_day_total(:,file_index) = err_per_day';
%     end
    err_per_day_total = [err_per_day_total, err_per_day];
    g = [g, file_index * ones(1,size(days_data,2))];
end
%% Box Plot for Error
figure(2);
boxplot(err_per_day_total,g);
xlabel('Test Files');
ylabel('Errors per Day');
%% Bar Graph for Accuracy
figure(3);
bar(accuracy_total,0.6);
xlabel('Test Files');
ylabel('Accuracy');
set(gca,'XTick',1:1:25);