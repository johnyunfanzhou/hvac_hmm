from scipy.io import loadmat
import numpy as np
# import statistics as stats
# from pylab import plot, show, savefig, xlim, figure, \
#                 hold, ylim, legend, boxplot, setp, axes
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon      

def build_data(file,err_compare_total,err_mean_total):
    x = loadmat(file)
    err = x['err'][0]
    print(np.mean(np.array(err)))
    err_mean_total.append('%.2f' % np.mean(np.array(err)))
    g = x['g'][0]
    j = 0
    g_compare = []
    first = 1
    for i in range(len(g)):
        if i == len(g)-1:
            g_compare.append(i-j)
            break
        elif g[i+1] != g[i]:
            if first:
                g_compare.append(i+1-j)
                first = 0
                j = i
            else:
                g_compare.append(i-j)
                j = i

    err_compare = []
    j = 0
    for i in range(len(g_compare)):
        err_compare.append(err[j:j+g_compare[i]])
        j = j+g_compare[i]
    err_compare_total.append(err_compare)
    
if __name__ == '__main__':
    files = ['tts_CRF.mat','tts_MM.mat','tts_1-1.mat','ttsEM_1-1_new.mat']
    err_compare_total = []
    err_mean_total = []
    for i in range(len(files)):
        build_data(files[i],err_compare_total,err_mean_total)
    # print(err_compare_total[3][0])
    data = []
    for k in range(len(err_compare_total[0])):
        for j in range(len(err_compare_total)):
            data.append(err_compare_total[j][k])
    fig, ax1 = plt.subplots(figsize=(25, 10))
    fig.canvas.set_window_title('Comparision between CRF, MM, ViterbiEM, EM for tts_1-1')
    # fig.subplots_adjust(left=0.075, right=0.95, top=0.9, bottom=0.25)
    fig.subplots_adjust(left=0.065, right=0.95, top=0.9, bottom=0.20)

    bp = ax1.boxplot(data, notch=0, sym='+', vert=1, whis=1.5)
    plt.setp(bp['boxes'], color='black')
    plt.setp(bp['whiskers'], color='black')
    plt.setp(bp['fliers'], color='red', marker='+')
    # plt.show()

    ax1.yaxis.grid(True, linestyle='-', which='major', color='lightgrey',
                   alpha=0.5)

    # Hide these grid behind plot objects
    ax1.set_axisbelow(True)
    ax1.set_title('Comparison of Number of Errors per Day between CRF, MM, ViterbiEM, EM for tts_1-1')
    ax1.set_xlabel('Thermostat')
    ax1.set_ylabel('Number of Errors per Day')

    boxColors = ['magenta','olive','mediumturquoise', 'gold']
    numBoxes = 25*len(files)
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
        k = i % 4
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
    ax1.set_xticklabels(np.repeat(file_index, 4),fontsize=6)
    plt.yticks(np.arange(0, top, 5.0))

    pos = np.arange(numBoxes) + 1
    upperLabels = [str(np.round(s, 2)) for s in medians]
    # weights = ['bold', 'bold']
    for tick, label in zip(range(numBoxes), ax1.get_xticklabels()):
        k = tick % 4
        ax1.text(pos[tick], top - (top*0.04), upperLabels[tick],
                 horizontalalignment='center', size='x-small', weight='bold',
                 color=boxColors[k],rotation=45)

    # Finally, add a basic legend
    fig.text(0.7, 0.161, 'CRF, mean: '+str(err_mean_total[0]),
             backgroundcolor=boxColors[0], color='black', weight='roman',
             size='small',bbox={'facecolor':boxColors[0],'pad':3})
    fig.text(0.76, 0.161, 'MM, mean: '+str(err_mean_total[1]),
             backgroundcolor=boxColors[1], color='black', weight='roman', 
             size='small',bbox={'facecolor':boxColors[1],'pad':3})
    fig.text(0.818, 0.161, 'ViterbiEM, mean: '+str(err_mean_total[2]),
             backgroundcolor=boxColors[2], color='black', weight='roman',
             size='small',bbox={'facecolor':boxColors[2],'pad':3})
    fig.text(0.899, 0.161, 'EM, mean: '+str(err_mean_total[3]),
             backgroundcolor=boxColors[3], color='black', weight='roman', 
             size='small',bbox={'facecolor':boxColors[3],'pad':3})
    plt.show()
