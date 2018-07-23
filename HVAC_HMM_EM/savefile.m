% err = importdata('err_per_day_total_1d0_1.mat');
% g = importdata('g_1d0_1.mat');
% save('ttsEM_1-1','err','g')
ans = importdata('ttsMM.mat');
err = ans.errMM;
g = ans.gMM;
save('tts_MM.mat','err','g')