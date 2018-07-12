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

filename_tts = ['1cca90adb7de8aabbb74be37171e805ba6dd74e8.csv'; 
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

file_index = 2;

data = csvread(filename(file_index, :), 1, 1);

% To detect number of toggled observations
% c = 0;
% for i = 2 : size(data, 1)
%     if data(i, 1) ~= data(i - 1, 1)
%         c = c + 1;
%     end
% end

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

mode = 'clus'; % 'rand': randomly select test data
               % 'clus': select the last cluster of data as test data

[accuracy, predictions, fPred, fProb] = testPrediction(data, Sn, Hn, Wn, mode);
fprintf('Predict accuracy is %f\n', accuracy);

%% save figures (comment if already saved)

% if rand
%     cd 'HackModel/results/random predictions';
% else
%     cd 'HackModel/results/cluster predictions';
% end
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
