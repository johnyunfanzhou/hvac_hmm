% HVAC_HMM "Hack" model using time-shifting
% Please set the Current Folder to hvac_hmm
% Please locate formed_data in the parent directory of hvac_hmm

addpath(genpath('../formed_data'));
addpath(genpath('./HMMall'));
addpath(genpath('./HackModel'));

%% initialization

% list of filenames
filename = ['1d0733906f57440ecade6f8d3f091630de8c24ec.csv'; 
    '5a582fd2839fc31dbc553389cf8e65b8b845aa7c.csv'; 
    '6d195551c1ef0ca9bf855903cdfd9dd6b71a6ff5.csv';
    '7a805f75e7a914388de0fb8308227c7ba627271c.csv';
    '8bb1a09d4729c4908f4a7dfc173de7f7d0d3642c.csv';
    '11e9aff05e9dadce7aa8292f13fe7187ea5a3037.csv';
    '78c451cc556e71801bc66686fbc075cdd895dde6.csv';
    '80b98d4c69fc7c6d89facafb1580454016f46f20.csv';
    '83ed059e2bd6f36735a871c924fa74caa55f4878.csv';
    '110dda328a521cd41d3771feaf994a9faa966b1e.csv';
    '3200f9aa03bfedc80533b273d6dc2de839f8343e.csv';
    '7310f1a63efce1496ad98bb8149a05e93ad4292f.csv';
    '84607b6dce9e34641814db21a0bb5882d5375814.csv';
    'a722b876dcf882b0c0412d535ab98943cd4a1846.csv';
    'ab23b4f49689c5dd4bf205210bf3877126b115ef.csv';
    'ac37d357c0d4436d5077a6c91a4634939514086f.csv';
    'ae064b908ecfc8ec21028722ed86661c2b59d7c7.csv';
    'c0d48ccbe55cc94acdebe3b4b5f35dd85e92b26a.csv';
    'd805f6abf5c22a5e0582b29905468f735682ea0d.csv';
    'd6753e2c7717cda160070bed00183cb722951f5f.csv';
    'dd489fa33b229e50a89170159107ab2c3ca7369d.csv';
    'e56deb5addea10ecc6b962cb2e8f4a57442b52ee.csv';
    'e79039a7615153cfebfda4669160c06ad3a5658d.csv';
    'f17826dce7c323c15e8f1e91cb7543f10b09520d.csv';
    'fb4d3fa98447464e0d38ba15b6928ed5ca072eef.csv'];

%   M_t, S_t, H_t, W_t

%% store all data in a matrix

file_index = 1;

data = csvread(filename(file_index, :), 1, 1);

datacell = textscan(fopen(filename(file_index, :)), '%s', 'Delimiter', '\n');
datacell = datacell{1}(2 : end);

%% learn data with HackModel.m

Sn = 3;
Wn = 2;
Hn = 48;

[A, B, state, itr] = HackModel(data, Sn, Hn, Wn);

%% result summary

% plot the trained occupancy states
fStates = figure('Name','Trained Occupancy States','NumberTitle','off');
[smrPlot, falPlot, wtrPlot] = statePlot(data, state, Sn, Hn, Wn);

% plot the real motion sensor observations
fObs = figure('Name','Motion Sensor Observations','NumberTitle','off');
[smrPlotObs, falPlotObs, wtrPlotObs] = statePlot(data, data(:, 1), Sn, Hn, Wn);

%% prediction result

mode = 'rand'; % 'rand': randomly select test data
               % 'clus': select the last cluster of data as test data
               % 'days': select random days for testing
[accuracy, predictions, fPred, fProb] = testPrediction(data, Sn, Hn, Wn, mode);
fprintf('Predict accuracy is %f\n', accuracy);

%% save figures (comment if already saved)

% if rand
%     cd 'HackModel/results/random predictions';
% else
%     cd 'HackModel/results/cluster predictions';
% end
% cd 'HackModel/results/tts_day predictions';
% dirname = cat(2, int2str(file_index), cat(2, ' - ', num2str(accuracy, '%6f')));
% mkdir(dirname);
% cd(dirname);
% fileID = fopen(cat(2, int2str(file_index), ' - result.txt'), 'w');
% fprintf(fileID, 'Data size is %d\n', size(data, 1));
% if itr == 11
%     fprintf(fileID, 'Absolute convergence not reached after max number of iterations\n');
% else
%     fprintf(fileID, 'Absolute convergence reached after iteration %d\n', itr);
% end
% fprintf(fileID, 'Predict accuracy is %f\n', accuracy);
% fclose(fileID);
% saveas(fStates, cat(2, int2str(file_index), ' - Trained Occupancy States.png'));
% saveas(fObs, cat(2, int2str(file_index), ' - Motion Sensor Observations.png'));
% saveas(fPred, cat(2, int2str(file_index), ' - Discrete Predictions.png'));
% saveas(fProb, cat(2, int2str(file_index), ' - Forward Probabilities.png'));
% cd '../../../..';
