from scipy.io import loadmat
import numpy as np
import statistics as stats
# from pylab import plot, show, savefig, xlim, figure, \
#                 hold, ylim, legend, boxplot, setp, axes
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon      

file1 = ['tts_2-1.mat','tts_1-1.mat','tts_1-2.mat']

x1 = loadmat(file1[2])
err1 = x1['err']
err1 = err1[0]
g1 = x1['g']
g1 = g1[0]
# print(err)
# print(g)
j = 0
g_compare_1 = []
first = 1
for i in range(len(g1)):
	if i == len(g1)-1:
		g_compare_1.append(i-j)
		break
	elif g1[i+1] != g1[i]:
		if first:
			g_compare_1.append(i+1-j)
			first = 0
			j = i
		else:
			g_compare_1.append(i-j)
			j = i
# print(g_compare)

err_compare_1 = []
j = 0
for i in range(len(g_compare_1)):
	err_compare_1.append(err1[j:j+g_compare_1[i]])
	j = j+g_compare_1[i]
print(err_compare_1)

err_average_per_file_1 = []
for k in range(len(err_compare_1)):
    err_average_per_file_1.append(float(stats.mean(err_compare_1[k])))

err_average_1 = '%.2f' % stats.mean(err_average_per_file_1)

file2 = [['err_per_day_total_1cc.mat','g_1cc.mat'],['err_per_day_total_1d0_1.mat','g_1d0_1.mat'],
    ['err_per_day_total_1d0_2.mat','g_1d0_2.mat']]

x2 = loadmat(file2[2][0])
err2 = x2['err_per_day_total'][0]
g2 = loadmat(file2[2][1])['g'][0]


j = 0
g_compare_2 = []
first = 1
for i in range(len(g2)):
	if i == len(g2)-1:
		g_compare_2.append(i-j)
		break
	elif g2[i+1] != g2[i]:
		if first:
			g_compare_2.append(i+1-j)
			first = 0
			j = i
		else:
			g_compare_2.append(i-j)
			j = i

err_compare_2 = []
j = 0
for i in range(len(g_compare_2)):
	err_compare_2.append(err2[j:j+g_compare_2[i]])
	j = j+g_compare_2[i]
# print(err_compare_2)


err_average_per_file_2 = []
for k in range(len(err_compare_2)):
    err_average_per_file_2.append(float(stats.mean(err_compare_2[k])))
    
err_average_2 = '%.2f' % stats.mean(err_average_per_file_2)

data = []
for i in range(len(err_compare_1)):
	data.append(err_compare_1[i])
	data.append(err_compare_2[i])
fig, ax1 = plt.subplots(figsize=(10, 6))
fig.canvas.set_window_title('Comparision between Hack Model and EM for 1d0_2 tts_1-2')
fig.subplots_adjust(left=0.075, right=0.95, top=0.9, bottom=0.25)

bp = ax1.boxplot(data, notch=0, sym='+', vert=1, whis=1.5)
plt.setp(bp['boxes'], color='black')
plt.setp(bp['whiskers'], color='black')
plt.setp(bp['fliers'], color='red', marker='+')
# plt.show()

ax1.yaxis.grid(True, linestyle='-', which='major', color='lightgrey',
               alpha=0.5)

# Hide these grid behind plot objects
ax1.set_axisbelow(True)
ax1.set_title('Comparison of Number of Errors per Day between Hack Model and EM for 1d0_2 tts_1-2')
ax1.set_xlabel('Files')
ax1.set_ylabel('Number of Errors per Day')

boxColors = ['mediumturquoise', 'gold']
numBoxes = 25*2
medians = list(range(numBoxes))
for i in range(numBoxes):
    box = bp['boxes'][i]
    boxX = []
    boxY = []
    for j in range(5):
        boxX.append(box.get_xdata()[j])
        boxY.append(box.get_ydata()[j])
    boxCoords = list(zip(boxX, boxY))
    # Alternate between Dark Khaki and Royal Blue
    k = i % 2
    boxPolygon = Polygon(boxCoords, facecolor=boxColors[k])
    ax1.add_patch(boxPolygon)
    # Now draw the median lines back over what we just filled in
    med = bp['medians'][i]
    medianX = []
    medianY = []
    for j in range(2):
        medianX.append(med.get_xdata()[j])
        medianY.append(med.get_ydata()[j])
        ax1.plot(medianX, medianY, 'k')
        medians[i] = medianY[0]
    # Finally, overplot the sample averages, with horizontal alignment
    # in the center of each box
    # ax1.plot([np.average(med.get_xdata())], [np.average(data[i])],
    #          color='w', marker='*', markeredgecolor='k')

top = 50
bottom = -2
ax1.set_ylim(bottom, top)
file_index = ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15',
'16','17','18','19','20','21','22','23','24','25']
ax1.set_xticklabels(np.repeat(file_index, 2),fontsize=8)
plt.yticks(np.arange(0, top, 5.0))

pos = np.arange(numBoxes) + 1
upperLabels = [str(np.round(
    s, 2)) for s in medians]
# weights = ['bold', 'bold']
for tick, label in zip(range(numBoxes), ax1.get_xticklabels()):
    k = tick % 2
    ax1.text(pos[tick], top - (top*0.04), upperLabels[tick],
             horizontalalignment='center', size='x-small', weight='bold',
             color=boxColors[k],rotation=45)

# Finally, add a basic legend
fig.text(0.815, 0.19, 'Hack Model,  mean: '+str(err_average_1),
         backgroundcolor=boxColors[0], color='black', weight='roman',
         size='x-small',bbox={'facecolor':boxColors[0],'pad':3})
fig.text(0.815, 0.16, 'EM Approach, mean: '+str(err_average_2),
         backgroundcolor=boxColors[1], color='black', weight='roman', 
         size='x-small',bbox={'facecolor':boxColors[1],'pad':3})
plt.show()
