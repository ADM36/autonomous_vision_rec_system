# -*- coding: utf-8 -*-
"""
Created on Mon Jul 29 10:48:24 2019

@author: MIL1PLY
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.lines as lines
import matplotlib.patches as mpatches
import statistics as st

threshold_list = [[160, 60, 120, 90, 191, 155]] #feed in lists of threshold values used for specififed image segment


fig, ax = plt.subplots()

fig.set_size_inches(22,18)# Make graph large enough to view, and dimensions readable 


plt.title("Red Lights - Segment 3 (Gmean SD)", fontsize = 20)
plt.xlabel("Sequence", fontsize = 15)
plt.ylabel("Channel Value", fontsize = 15)

plt.xlim([0,35]) #set xlim, add 5 for each threshold list
plt.ylim([0,250]) #set ylim, should always be 0, 250 (YUV pixel values)

plt.yticks(np.arange(0, 350, step=10))
plt.xticks(np.arange(2.5, 35, step=5), ('9376', '9387', '9388', '9443', '9447', '9450', '9470'))#second input of np.arange should be same as xlim argument above. second argument of xticks should be a list of the names (str) of the sequences, corresponding to the thresholds provided

count = 1 
y_channel_nums = [] #create empty list for Y channel values
u_channel_nums = [] #create empty list for U channel values
v_channel_nums = [] #create empty list for V channel values

for threshold in threshold_list: #iterate through list of thresholds (one threshold per sequence)
    
    y_channel_nums.append(threshold[0]) #append upper bound of y channel values
    y_channel_nums.append(threshold[1]) #append lower bound of y channel values
    u_channel_nums.append(threshold[2]) #append upper bound of u channel values
    u_channel_nums.append(threshold[3]) #append lower bound of u channel values
    v_channel_nums.append(threshold[4]) #append upper bound of v channel values
    v_channel_nums.append(threshold[5]) #append lower bound of v channel values
    
    y_channel = [(count,threshold[1]), (count,threshold[0])] #gets upper and lower bound for y channel thresholds
    u_channel = [((count + 1),threshold[3]), ((count + 1),threshold[2])] #gets upper and lower bound for u channel thresholds
    v_channel = [((count + 2),threshold[5]), ((count + 2),threshold[4])] #gets upper and lower bound for v channel thresholds

    (y_channel_xs, y_channel_ys) = zip(*y_channel) #for plotting
    (u_channel_xs, u_channel_ys) = zip(*u_channel)
    (v_channel_xs, v_channel_ys) = zip(*v_channel)
    
    ax.add_line(lines.Line2D(y_channel_xs, y_channel_ys, linewidth=2, ls='--', dash_capstyle='butt', color='goldenrod')) #graphs y channel thresholds
    ax.add_line(lines.Line2D(u_channel_xs, u_channel_ys, linewidth=2, color='tomato')) #graphs u channel thresholds
    ax.add_line(lines.Line2D(v_channel_xs, v_channel_ys, linewidth=2, color='darkviolet')) #graphs v channel thresholds
    
    count = count + 5 #count increases spacing between plotted thresholds 

y_patch = mpatches.Patch(color='goldenrod', label='Y Channel') #creates legend
u_patch = mpatches.Patch(color='tomato', label='U Channel')
v_patch = mpatches.Patch(color='darkviolet', label='V Channel')
legend1 = plt.legend(handles=[y_patch, u_patch, v_patch], loc='upper right')
plt.gca().add_artist(legend1)

#plt.show() #unhash to show plot
plt.savefig('Red Lights - Segment 3 (Gmean SD)') #saves plot to pdf

print("Y Channel Summary Statistics")
print(st.mean(y_channel_nums)) #print Y channel mean for all sequences in segment provided
print(st.stdev(y_channel_nums)) #print Y channel standard deviation for all sequences in segment provided
print(max(y_channel_nums)) #print Y channel maximum value for all sequences in segment provided
print(min(y_channel_nums)) #print Y channel minimum value for all sequences in segment provided

print("U Channel Summary Statistics")
print(st.mean(u_channel_nums)) #print U channel mean for all sequences in segment provided
print(st.stdev(u_channel_nums)) #print U channel standard deviation for all sequences in segment provided
print(max(u_channel_nums)) #print U channel maximum value for all sequences in segment provided
print(min(u_channel_nums)) #print U channel minimum value for all sequences in segment provided

print("V Channel Summary Statistics")
print(st.mean(v_channel_nums)) #print V channel mean for all sequences in segment provided
print(st.stdev(v_channel_nums)) #print V channel standard deviation for all sequences in segment provided
print(max(v_channel_nums)) #print V channel maximum value for all sequences in segment provided
print(min(v_channel_nums)) #print V channel minimum value for all sequences in segment provided