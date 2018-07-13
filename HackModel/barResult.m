addpath(genpath('./'));
clusP = dir('./HackModel/results/tts_2/cluster predictions');
randP = dir('./HackModel/results/tts_2/random predictions');
% clusP = dir('./HackModel/results/tts_day predictions/random predictions');
% randP = dir('./HackModel/results/tts_day predictions/cluster predictions');

exclusions = ['.', '..', '.DS_Store', 'result format.txt'];

clusData.x = [];
clusData.y = [];
for i = 1 : size(clusP)
    if ~contains(exclusions, clusP(i).name)
        v = split(clusP(i).name, ' - ');
        clusData.x = [clusData.x, str2double(v{1})];
        clusData.y = [clusData.y, str2double(v{2})];
    end
end

randData.x = [];
randData.y = [];
for i = 1 : size(randP)
    if ~contains(exclusions, randP(i).name)
        v = split(randP(i).name, ' - ');
        randData.x = [randData.x, str2double(v{1})];
        randData.y = [randData.y, str2double(v{2})];
    end
end

y = zeros(25, 2);
for i = 1 : 25
    y(clusData.x(i), 1) = clusData.y(i);
    y(randData.x(i), 2) = randData.y(i);
end

fBar = figure('Name','Accuracy of Prediction Testing','NumberTitle','off');
bar(y);
xlabel('File number');
ylabel('Accuracy');
legend('Cluster predictions', 'Random predictions');
