import numpy as np
import csv
import matplotlib.pyplot as plt
import scipy.io

def build_data(file, Data_total): 
	with open(file,'r') as csvfile:
		wholefile = list(csv.reader(csvfile))
		j = 0
	V = [[]]
	for i in range(1,len(wholefile)):
		V[j].append([int(wholefile[i][1]),int(wholefile[i][2]),int(wholefile[i][3]),int(wholefile[i][4])])
		if i == len(wholefile)-1:
			break
		elif wholefile[i+1][0][9] != wholefile[i][0][9]:#when the date changes | split data by days
			V.append([])
			j += 1
	
	for i in range(len(V)-1,-1,-1):
		if len(V[i]) != 48:# remove the days that have missing data in a day
			del V[i]

	# print(len(V))

	V2 = np.zeros((len(V),len(V[0])),dtype=int)

	for i in range(len(V2)):
		for j in range(len(V2[i])):
			k = V[i][j]
			#convert (M,S,H,W) into numbers by their combinations
			V2[i][j] = int(k[3] + 2*k[2] + 2*48*k[1] + 2*48*3*k[0]) + 1

	V3 = []
	for i in range(len(V2)):
		V3.extend(V2[i])
	
	Data_total.append(V3)

if __name__ == '__main__':
	wholefile, M, S, H, W, V = [], [], [], [], [], [[]]
	Data_total = []
	# files = ["1d0733906f57440ecade6f8d3f091630de8c24ec.csv"
	# 		,"5a582fd2839fc31dbc553389cf8e65b8b845aa7c.csv"
	# 		,"6d195551c1ef0ca9bf855903cdfd9dd6b71a6ff5.csv"
	# 		,"7a805f75e7a914388de0fb8308227c7ba627271c.csv"
	# 		,"8bb1a09d4729c4908f4a7dfc173de7f7d0d3642c.csv"
	# 		,"11e9aff05e9dadce7aa8292f13fe7187ea5a3037.csv"
	# 		,"78c451cc556e71801bc66686fbc075cdd895dde6.csv"
	# 		,"80b98d4c69fc7c6d89facafb1580454016f46f20.csv"
	# 		,"83ed059e2bd6f36735a871c924fa74caa55f4878.csv"
	# 		,"110dda328a521cd41d3771feaf994a9faa966b1e.csv"
	# 		,"3200f9aa03bfedc80533b273d6dc2de839f8343e.csv"
	# 		,"7310f1a63efce1496ad98bb8149a05e93ad4292f.csv"
	# 		,"84607b6dce9e34641814db21a0bb5882d5375814.csv"
	# 		,"a722b876dcf882b0c0412d535ab98943cd4a1846.csv"
	# 		,"ab23b4f49689c5dd4bf205210bf3877126b115ef.csv"
	# 		,"ac37d357c0d4436d5077a6c91a4634939514086f.csv"
	# 		,"ae064b908ecfc8ec21028722ed86661c2b59d7c7.csv"
	# 		,"c0d48ccbe55cc94acdebe3b4b5f35dd85e92b26a.csv"
	# 		,"d805f6abf5c22a5e0582b29905468f735682ea0d.csv"
	# 		,"d6753e2c7717cda160070bed00183cb722951f5f.csv"
	# 		,"dd489fa33b229e50a89170159107ab2c3ca7369d.csv"
	# 		,"e56deb5addea10ecc6b962cb2e8f4a57442b52ee.csv"
	# 		,"e79039a7615153cfebfda4669160c06ad3a5658d.csv"
	# 		,"f17826dce7c323c15e8f1e91cb7543f10b09520d.csv"
	# 		,"fb4d3fa98447464e0d38ba15b6928ed5ca072eef.csv"]

	files = ["train_1cca90adb7de8aabbb74be37171e805ba6dd74e8.csv"
			,"train_2cceb7f426f847d09f9c4d15808e24884bb3dbf8.csv"
			,"train_02d4dbbdec6d776bf72ef3ee530ef2de918ce363.csv"
			,"train_7d9bf619d6d3c19e16ef6702a90f816fccee5786.csv"
			,"train_7db7d2b15622a495dac614fbdd158a8d9a33d656.csv"
			,"train_35bdf3e00084fce2a0d2abbb0e7cd785e921823f.csv"
			,"train_53e2551fffa9c249843080675f9e780e1a4db041.csv"
			,"train_63d5d2618d055003be3a73071da4b5cbaec8f2ee.csv"
			,"train_75b6b3ac33d35f887313468ee62f1a99c96000f6.csv"
			,"train_86dbd90f921d838a4521f5a01b58951a431fbe23.csv"
			,"train_583ef0c5d9dd4beefd5c16d9f52f39f560a20140.csv"
			,"train_2250e1dc735fd0faa56e62c8ff61d286f0074a16.csv"
			,"train_4234c00c716610fdd6ed369fe2745b59c0149312.csv"
			,"train_4787f63d478fa706c63b8a09a106f683791da3c7.csv"
			,"train_9158c348bce8a7636564d7928afb75420f88307e.csv"
			,"train_212825c18b59f3faab8a9fab9e88f87426cb5d3a.csv"
			,"train_716436602a0820a58892e51e8f131c7a699e7b7a.csv"
			,"train_b510c2b4f4a2cff8a0cba279a4f3b9fd8490fb59.csv"
			,"train_bdd49d5cb90eef2f1e0e8f97478936321c39be53.csv"
			,"train_c798c4784802c709e2c5d7790f0d3c464d52d395.csv"
			,"train_c5748e664560ff6462dbe033bcff33f2b6a7a31e.csv"
			,"train_d0ce32cf46f3e7267fedccdc89caa88a07ee409d.csv"
			,"train_f55c7ebf8c354c1fbe2b86c9d15032e47de83780.csv"
			,"train_f411422c063f9d0809def300e7657a9f6d63b1ef.csv"
			,"train_f6178010526fce4bebc535194b3ccc6c9ebe19ad.csv"]
	# files = ["6d195551c1ef0ca9bf855903cdfd9dd6b71a6ff5.csv"]
	for i in range(len(files)):
		build_data(files[i], Data_total)
	
	# print(len(Data_total)) #output len(Data_total) = 25 #files
	# ans = 0
	# for j in range(len(Data_total)):
	# 	print(len(Data_total[j]))
	# 	ans += len(Data_total[j])
	# print(ans) #output 263328
	# print(Data_total[0])
	scipy.io.savemat('sample_train_data.mat',mdict={"data": Data_total})

