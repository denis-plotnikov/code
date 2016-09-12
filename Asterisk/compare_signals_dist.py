#!/usr/bin/python
import matplotlib.pyplot as plt
import numpy as np
from scipy.fftpack import fft
from scipy.io import wavfile # get the api
import sys
import soundfile as sf

def get_file_data(filename):
	samples_num = 213000 
	data, sample_rate = sf.read(filename) # load the data
	#a = data.T[0] # this is a two channel soundtrack, I get the first track
	b=[(ele/2**8.)*2-1 for ele in data] # this is 8-bit track, b is now normalized on [-1,1)
	#print("vector more than 0 vals number: {0}".format(len(c)))
	b = b[0:samples_num]
	c = fft(b) # calculate fourier transform (complex numbers list)
	d = len(c)/2 - 1 # you only need half of the fft list (real signal symmetry)
	#d = len(c)  # you only need half of the fft list (real signal symmetry)
	#print("complex val: {0} abs(complex val): {1}".format(c[0], abs(c[0])))
	c = c[:d]
	data = abs(c)
	return np.array(data)
	
def get_distance(filename1, filename2):
	f1_data = get_file_data(filename1)
	f2_data = get_file_data(filename2)

	diff = f1_data - f2_data
	dist = diff.dot(diff)
	print(dist)


if __name__ == "__main__":
	get_distance(sys.argv[1], sys.argv[2])
