from scipy.io import loadmat
import numpy as np
# import statistics as stats
# from pylab import plot, show, savefig, xlim, figure, \
#                 hold, ylim, legend, boxplot, setp, axes
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon      

# x = loadmat('accuracy_total.mat')
x = loadmat('M_percent.mat')
accuracy = x['M_percent'][0]
for i in range(len(accuracy)):
	print(accuracy[i])
