#!/usr/bin/python
import matplotlib.pyplot as plt
import numpy as np
from scipy.fftpack import fft
from scipy.io import wavfile # get the api
import sys

def show_file_hystogram(filename):
	fs, data = wavfile.read(filename) # load the data
	#a = data.T[0] # this is a two channel soundtrack, I get the first track
	b=[(ele/2**8.)*2-1 for ele in data] # this is 8-bit track, b is now normalized on [-1,1)
	#print("vector more than 0 vals number: {0}".format(len(c)))
	c = fft(b) # calculate fourier transform (complex numbers list)
	d = len(c)/2 - 1 # you only need half of the fft list (real signal symmetry)
	#d = len(c)  # you only need half of the fft list (real signal symmetry)
	#print("complex val: {0} abs(complex val): {1}".format(c[0], abs(c[0])))

	c = c[:d]

	k = np.arange(d)
	fs = 8000 # 8kHz
	T = len(c)/fs
	frqLabel = k/T

	print("vector dimensionality: {0}".format(d))

	plt.plot(frqLabel, abs(c), 'g') 
	plt.show()


if __name__ == "__main__":
	show_file_hystogram(sys.argv[1])
