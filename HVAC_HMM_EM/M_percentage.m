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
num_files = size(test_files,1);
accuracy_total = zeros(1,num_files);
err_per_day_total = [];
g = [];
M_percent = [];
M_size = [];

for file_index = 1:num_files
    %% Initialization
%     clear;
%     clc;
    count = 0;
    train_data_raw = importdata('sample_train1_data.mat');
    train_data = train_data_raw{file_index};
    test_data_raw = importdata('sample_test1_data.mat');
    test_data = test_data_raw{file_index};
    days_data_raw = importdata('sample_days1_data.mat');
    days_data = days_data_raw{file_index};
    
    [M,S,H,W] = deal(zeros(1,size(test_data,2)));
    for i = 1:size(test_data,2)
        [M(i),S(i),H(i),W(i)] = extrac_num(test_data(i));
    end
%     M_size = [M_size, size(M,2)/48];
%     M_percent = [M_percent, sum(M)/size(M,2)];
    for i = 1:(size(M,2)-1)
        if M(i+1) ~= M(i)
            count = count + 1;
        end
    end
    M_percent = [M_percent, count/(size(M,2)-1)]
end
%% save
save('M_percent.mat','M_percent');