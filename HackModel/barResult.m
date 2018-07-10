addpath(genpath('./'));
clusP = dir('./HackModel/results/random predictions');
randP = dir('./HackModel/results/cluster predictions');
% clusP = dir('./HackModel/results/tts_day predictions/random predictions');
% randP = dir('./HackModel/results/tts_day predictions/cluster predictions');

exclusions = ['.', '..', '.DS_Store', 'result format.txt'];

clusData.x = zeros(25, 1);
clusData.y = zeros(25, 1);
for i = 4 : 28
    v = split(clusP(i).name, ' - ');
    clusData.x(i - 3) = str2double(v{1});
    clusData.y(i - 3) = str2double(v{2});
end

randData.x = zeros(25, 1);
randData.y = zeros(25, 1);
for i = 4 : 28
    v = split(randP(i).name, ' - ');
    randData.x(i - 3) = str2double(v{1});
    randData.y(i - 3) = str2double(v{2});
end

y = zeros(25, 2);
for i = 1 : 25
    y(clusData.x(i), 2) = clusData.y(i);
    y(randData.x(i), 1) = randData.y(i);
end

fBar = figure('Name','Accuracy of Prediction Testing','NumberTitle','off');
bar(y);
xlabel('File number');
ylabel('Accuracy');
legend('Cluster predictions', 'Random predictions');
