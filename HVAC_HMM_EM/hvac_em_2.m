%% Specify Test Files
% test_files = ["test_1cca90adb7de8aabbb74be37171e805ba6dd74e8.csv"
%                 ,"test_2cceb7f426f847d09f9c4d15808e24884bb3dbf8.csv"
%                 ,"test_02d4dbbdec6d776bf72ef3ee530ef2de918ce363.csv"
%                 ,"test_7d9bf619d6d3c19e16ef6702a90f816fccee5786.csv"
%                 ,"test_7db7d2b15622a495dac614fbdd158a8d9a33d656.csv"
%                 ,"test_35bdf3e00084fce2a0d2abbb0e7cd785e921823f.csv"
%                 ,"test_53e2551fffa9c249843080675f9e780e1a4db041.csv"
%                 ,"test_63d5d2618d055003be3a73071da4b5cbaec8f2ee.csv"
%                 ,"test_75b6b3ac33d35f887313468ee62f1a99c96000f6.csv"
%                 ,"test_86dbd90f921d838a4521f5a01b58951a431fbe23.csv"
%                 ,"test_583ef0c5d9dd4beefd5c16d9f52f39f560a20140.csv"
%                 ,"test_2250e1dc735fd0faa56e62c8ff61d286f0074a16.csv"
%                 ,"test_4234c00c716610fdd6ed369fe2745b59c0149312.csv"
%                 ,"test_4787f63d478fa706c63b8a09a106f683791da3c7.csv"
%                 ,"test_9158c348bce8a7636564d7928afb75420f88307e.csv"
%                 ,"test_212825c18b59f3faab8a9fab9e88f87426cb5d3a.csv"
%                 ,"test_716436602a0820a58892e51e8f131c7a699e7b7a.csv"
%                 ,"test_b510c2b4f4a2cff8a0cba279a4f3b9fd8490fb59.csv"
%                 ,"test_bdd49d5cb90eef2f1e0e8f97478936321c39be53.csv"
%                 ,"test_c798c4784802c709e2c5d7790f0d3c464d52d395.csv"
%                 ,"test_c5748e664560ff6462dbe033bcff33f2b6a7a31e.csv"
%                 ,"test_d0ce32cf46f3e7267fedccdc89caa88a07ee409d.csv"
%                 ,"test_f55c7ebf8c354c1fbe2b86c9d15032e47de83780.csv"
%                 ,"test_f411422c063f9d0809def300e7657a9f6d63b1ef.csv"
%                 ,"test_f6178010526fce4bebc535194b3ccc6c9ebe19ad.csv"];
            
test_files = ["test_1d0733906f57440ecade6f8d3f091630de8c24ec.csv"
			,"test_5a582fd2839fc31dbc553389cf8e65b8b845aa7c.csv"
			,"test_6d195551c1ef0ca9bf855903cdfd9dd6b71a6ff5.csv"
			,"test_7a805f75e7a914388de0fb8308227c7ba627271c.csv"
			,"test_8bb1a09d4729c4908f4a7dfc173de7f7d0d3642c.csv"
			,"test_11e9aff05e9dadce7aa8292f13fe7187ea5a3037.csv"
			,"test_78c451cc556e71801bc66686fbc075cdd895dde6.csv"
			,"test_80b98d4c69fc7c6d89facafb1580454016f46f20.csv"
			,"test_83ed059e2bd6f36735a871c924fa74caa55f4878.csv"
			,"test_110dda328a521cd41d3771feaf994a9faa966b1e.csv"
			,"test_3200f9aa03bfedc80533b273d6dc2de839f8343e.csv"
			,"test_7310f1a63efce1496ad98bb8149a05e93ad4292f.csv"
			,"test_84607b6dce9e34641814db21a0bb5882d5375814.csv"
			,"test_a722b876dcf882b0c0412d535ab98943cd4a1846.csv"
			,"test_ab23b4f49689c5dd4bf205210bf3877126b115ef.csv"
			,"test_ac37d357c0d4436d5077a6c91a4634939514086f.csv"
			,"test_ae064b908ecfc8ec21028722ed86661c2b59d7c7.csv"
			,"test_c0d48ccbe55cc94acdebe3b4b5f35dd85e92b26a.csv"
			,"test_d805f6abf5c22a5e0582b29905468f735682ea0d.csv"
			,"test_d6753e2c7717cda160070bed00183cb722951f5f.csv"
			,"test_dd489fa33b229e50a89170159107ab2c3ca7369d.csv"
			,"test_e56deb5addea10ecc6b962cb2e8f4a57442b52ee.csv"
			,"test_e79039a7615153cfebfda4669160c06ad3a5658d.csv"
			,"test_f17826dce7c323c15e8f1e91cb7543f10b09520d.csv"
			,"test_fb4d3fa98447464e0d38ba15b6928ed5ca072eef.csv"];
        
%% Initialization
num_files = size(test_files,1);
% Initialize total accuracy and error and g that stores value for each file
% g is used in box plotting that 
accuracy_total = zeros(1,num_files);
err_per_day_total = [];
g = [];
% Mn: # of M values, boolean, {0,1}, Mn = 2
% Sn: # of S values, {0,1,2}, 3 seasons, Sn = 3
% Hn: # of timesteps in a day, 30-min increment, {0,1,...,47},Hn = 48
% Wn: # of W values, boolean, {0,1}, Wn = 2
% O: size of observation set = # (M,S,H,W) combinations; as per toolbox
% Q: size of state set; as per toolbox
Mn = 2;
Sn = 3;
Hn = 48;
Wn = 2;
O = Mn * Sn * Hn * Wn;
Q = 2;

%%
for file_index = 1:num_files
    %% Import Data
    % parser_train.py outputs a .mat file 'sample_train1_data.mat' that
    % contains all observation sequences w/ incomplete days of data deleted
    train_data_raw = importdata('sample_train1_data.mat');
    % file_index according to the outer for loop, each loop for one file
    train_data = train_data_raw{file_index};
    % parser_test.py outputs a .mat file 'sample_test1_data.mat' that
    % contains all testing observation sequences (no deletion)
    test_data_raw = importdata('sample_test1_data.mat');
    test_data = test_data_raw{file_index};
    % parser_test.py also outputs the number of test days involved for each
    % thermostat file
    days_data_raw = importdata('sample_days1_data.mat');
    days_data = days_data_raw{file_index};
    
    % Extract M readings for each file
    % This can be later changed to directly read from the .csv file
    [M,S,H,W] = deal(zeros(1,size(test_data,2)));
    for i = 1:size(test_data,2)
        [M(i),S(i),H(i),W(i)] = extrac_num(test_data(i));
    end

    %% Initialize variables to record the trial with highest accuracy
    best_accuracy = 0;
    best_state_seq = zeros(1,size(test_data,2));
    best_obs_seq = zeros(1,size(test_data,2));
    best_prior2 = zeros(Q,1);
    best_transmat2 = zeros(Q,Q);
    best_obsmat2 = zeros(Q,O);

    %% Iterate through 30 trails and obtain the highest accuracy
    for trial = 1:30
        %% initial guess of parameters
        prior1 = normalise(rand(Q,1));
        transmat1 = mk_stochastic(rand(Q,Q));
        obsmat1 = mk_stochastic(rand(Q,O));

        %% improve guess of parameters using EM
        [LL, prior2, transmat2, obsmat2] = dhmm_em(train_data, prior1, transmat1, obsmat1, 'max_iter', 100);
        % use model to compute log likelihood; as per toolbox
        loglik = dhmm_logprob(train_data, prior2, transmat2, obsmat2);
        % log lik is slightly different than LL(end), since it is computed after the final M step
        %% Viterbi Algorithm applied on Training Data
        obs = train_data;
        obslik = multinomial_prob(obs, obsmat2);
        result_seq = viterbi_path(prior2, transmat2, obslik);
%       if use Forward Algorithm
%       [alpha, beta, gamma, loglik, xi, gamma2] = fwdback(prior2, transmat2, obslik, 'fwd_only', 1);
%        result_seq = zeros(1,size(alpha,2));
%        for i = 1:size(result_seq,2)
%            if alpha(1,i) >= alpha(2,i)
%                result_seq(i) = 1;
%            else
%                result_seq(i) = 2;
%            end
%        end
%        figure(1);
%        norm_result_seq = norm_seq(result_seq);
%        subplot(3,1,1)
%        plot(norm_result_seq)
         
        %% Infer the Most Likely Hidden States in Test Data
        test_obslik = multinomial_prob(test_data, obsmat2);
        % avoid all zero entries, due to rounding
        for i = 1:size(test_obslik,2)
            if test_obslik(1,i) == 0
                test_obslik(1,i) = 1e-23;% add a very small number
            end
        end
        % using Viterbi Algorithm  
        state_seq = viterbi_path(prior2, transmat2, test_obslik)-1;

        %% Infer the Most Likely Observations
        % obs_seq is the most likely M readings in the observations
        obs_seq = zeros(1,size(state_seq,2));
        for i = 1:size(state_seq,2)
            % Since (S,H,W) in (M,S,H,W) are actually known in sequence, we
            % can compare the probability of (0,S,H,W) with (1,S,H,W) in
            % the Emission Probability Matrix obsmat2; the one with higher 
            % probability tells us if M = 0 or 1
            index1 = W(i) + Wn*H(i) + Wn*Hn*S(i) + Wn*Hn*Sn*0 + 1;
            index2 = W(i) + Wn*H(i) + Wn*Hn*S(i) + Wn*Hn*Sn*1 + 1;
            if obsmat2(state_seq(i)+1,index1) > obsmat2(state_seq(i)+1, index2)
                obs_seq(i) = 0;
            else
                obs_seq(i) = 1;
            end
        end
        %% Accuracy
        % obs_seq is the returned M readings from Viterbi
        % error is where obs_seq and actual M readings do not match
        error = abs(obs_seq - M);
        accuracy = 0;
        % print the current accuracy in this trial
        accuracy = 1 - (sum(error)/size(obs_seq,2))
        % print the current best_accuracy
        best_accuracy
        % if the accuracy for the current trial is better than the previous 
        % best_accuracy, the best_xx variables will be replaced
        if accuracy > best_accuracy
            best_accuracy = accuracy;
            best_state_seq = state_seq;
            best_obs_seq = obs_seq;
            best_prior2 = prior2; 
            best_transmat2 = transmat2;
            best_obsmat2 = obsmat2;
            best_error = error;
        end
    end
    % At the end of this 30 trials
    % store best_accuracy of each thermostat file into accuracy_total
    accuracy_total(file_index) = best_accuracy;
    %% Plot 
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
    % save this plot, figure name is the same as each filename
    saveas(gcf, strcat(test_files(file_index),'.jpg'));
    
    %% Error Analysis
    % From best_error, split it according to days_data, to get errors made 
    % per day
    err_per_day = zeros(1,size(days_data,2));
    j = 1;
    for i = 1:size(days_data,2)
        if (j+days_data(i)-1) <= size(best_error,2)
            err_per_day(i) = sum(best_error(j:(j+days_data(i)-1)));
            j = j + days_data(i);
        else
            break
        end
    end
    % Store err_per_day of each file into the entire err_per_day_total
    err_per_day_total = [err_per_day_total, err_per_day];
    % g records number of days for each file and will be used in box plot
    g = [g, file_index * ones(1,size(days_data,2))];
end
%% Box Plot for Error
figure(2);
boxplot(err_per_day_total,g);
xlabel('Test Files');
ylabel('Errors per Day');
% save err_per_day_total and g as .mat file, which will be used later in
% box plot comparison with other models
save('err_per_day_total.mat','err_per_day_total');
save('g.mat','g');
%% Bar Graph for Accuracy
figure(3);
bar(accuracy_total,0.6);
xlabel('Test Files');
ylabel('Accuracy');
title(sprintf('Accuracy, mean:%f%%',mean(accuracy_total)*100));
set(gca,'XTick',1:1:25);
% save accuracy_total, which may be used later
save('accuracy_total.mat','accuracy_total');
