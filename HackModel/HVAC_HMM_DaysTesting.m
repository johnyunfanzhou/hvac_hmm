% HVAC_HMM "Hack" model testing - Predict 20 random days of observation
% Please set the Current Folder to hvac_hmm
% Please locate formed_data in the parent directory of hvac_hmm

addpath(genpath('../formed_data'));
addpath(genpath('./HMMall'));
addpath(genpath('./HackModel'));

%% initialization

% list of filenames
filename = ['1cca90adb7de8aabbb74be37171e805ba6dd74e8.csv'; 
    '2cceb7f426f847d09f9c4d15808e24884bb3dbf8.csv'; 
    '02d4dbbdec6d776bf72ef3ee530ef2de918ce363.csv';
    '7d9bf619d6d3c19e16ef6702a90f816fccee5786.csv';
    '7db7d2b15622a495dac614fbdd158a8d9a33d656.csv';
    '35bdf3e00084fce2a0d2abbb0e7cd785e921823f.csv';
    '53e2551fffa9c249843080675f9e780e1a4db041.csv';
    '63d5d2618d055003be3a73071da4b5cbaec8f2ee.csv';
    '75b6b3ac33d35f887313468ee62f1a99c96000f6.csv';
    '86dbd90f921d838a4521f5a01b58951a431fbe23.csv';
    '583ef0c5d9dd4beefd5c16d9f52f39f560a20140.csv';
    '2250e1dc735fd0faa56e62c8ff61d286f0074a16.csv';
    '4234c00c716610fdd6ed369fe2745b59c0149312.csv';
    '4787f63d478fa706c63b8a09a106f683791da3c7.csv';
    '9158c348bce8a7636564d7928afb75420f88307e.csv';
    '212825c18b59f3faab8a9fab9e88f87426cb5d3a.csv';
    '716436602a0820a58892e51e8f131c7a699e7b7a.csv';
    'b510c2b4f4a2cff8a0cba279a4f3b9fd8490fb59.csv';
    'bdd49d5cb90eef2f1e0e8f97478936321c39be53.csv';
    'c798c4784802c709e2c5d7790f0d3c464d52d395.csv';
    'c5748e664560ff6462dbe033bcff33f2b6a7a31e.csv';
    'd0ce32cf46f3e7267fedccdc89caa88a07ee409d.csv';
    'f55c7ebf8c354c1fbe2b86c9d15032e47de83780.csv';
    'f411422c063f9d0809def300e7657a9f6d63b1ef.csv';
    'f6178010526fce4bebc535194b3ccc6c9ebe19ad.csv'];

%   M_t, S_t, H_t, W_t

%% store all data in a matrix

err = [];
g = [];

for file_index = 1 : 25

data = csvread(filename(file_index, :), 1, 1);
datasize = size(data, 1);
datacell = textscan(fopen(filename(file_index, :)), '%s', 'Delimiter', '\n');
datacell = datacell{1}(2 : end);
testcell = textscan(fopen(['test_', filename(file_index, :)]), '%s', 'Delimiter', '\n');
testcell = testcell{1}(2 : end);
testsize = size(testcell, 1);
testdays = cell(0);
for i = 1 : testsize
    if size(strfind([testdays{:}], testcell{i}(1:10)), 1) == 0
        testdays = [testdays; {testcell{i}(1:10)}]; %#ok<AGROW>
    end
end
numdays = size(testdays, 1);
clear testcell testsize;

%% learn data with HackModel.m

Sn = 3;
Wn = 2;
Hn = 48;
% 
% [~, ~, state, ~] = HackModel(data, Sn, Hn, Wn);

%% result summary

% % plot the trained occupancy states
% fStates = figure('Name','Trained Occupancy States','NumberTitle','off');
% [smrPlot, falPlot, wtrPlot] = statePlot(data, state, Sn, Hn, Wn);
% 
% % plot the real motion sensor observations
% fObs = figure('Name','Motion Sensor Observations','NumberTitle','off');
% [smrPlotObs, falPlotObs, wtrPlotObs] = statePlot(data, data(:, 1), Sn, Hn, Wn);

%% Prediction by Days

testdata = cell(numdays, 1);
traindata = [];
for i = 1 : datasize
    for j = 1 : numdays
        if isequal(datacell{i}(1 : 10), testdays{j})
            testdata{j} = [testdata{j}, i];
        else
            traindata = [traindata, i]; %#ok<AGROW>
        end
    end
end

[A, B, ~, ~] = HackModel(data(traindata, :), Sn, Hn, Wn, 10, true);

for j = 1 : numdays
    if size(testdata{j}, 2) ~= 0
        [new_data, ~] = hvacpredict(A, B, data, Sn, Hn, Wn, testdata{j}, true);
        predictions = new_data(:, 1);
        err = [err, sum(abs(predictions(testdata{j}) - data(testdata{j}, 1)))]; %#ok<AGROW>
        g = [g, file_index]; %#ok<AGROW>
    end
end
clear data datasize datacell testdays numdays testdata traindata A B new_data predictions; 
end

% fPred = figure('Name','Discrete Predictions','NumberTitle','off');
% statePlot(data(testdata, :), predictions(testdata), Sn, Hn, Wn);
%     
% fProb = figure('Name', 'Forward Probabilities', 'NumberTitle', 'off');
% forwardProbPlot(data(testdata, :), forward_prob(testdata, :), Sn, Hn, Wn);

fprintf('Average predict error is %f\n', mean(err));

fErr = figure('Name','Number of prediction errors','NumberTitle','off');
boxplot(err, g);
xlabel('Errors');
ylabel('File index');