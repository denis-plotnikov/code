#!/usr/bin/python
import matplotlib.pyplot as plot
import numpy as np
from scipy.fftpack import fft
from scipy.io import wavfile # get the api
from scipy import signal  
import sys
import soundfile as sf
import scipy

def get_file_data(filename):
	samples_num = 213000 
	data, sample_rate = sf.read(filename) # load the data
	print("Sampling rate: {0}".format(sample_rate))
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
	return np.array(data), sample_rate
	
def get_coherence(filename1, filename2):
	f1_data, f1_sample_rate = get_file_data(filename1)
	f2_data, f2_sample_rate = get_file_data(filename2)

	if f1_sample_rate != f2_sample_rate:
		print("Sample rates of the signals differ but have to be the same. Exiting... ")
		return
	else:
		sample_rate = f1_sample_rate
	f, coherence = signal.coherence(f1_data, f2_data, sample_rate, nperseg = 128)
	plot.gca().set_ylim([0.000001, 100])
	plot.semilogy(f, coherence)
	len_coherence = len(coherence)
	print("coherence vector len: {0}".format(len_coherence))
	print(coherence)
	sum_coherence = sum(coherence)
	print("coherence vector sum: {0}".format(sum_coherence))
	similarity = int(sum_coherence/len_coherence * 100.0)
	print("similarity(%): {0}".format(similarity))
	distorsion = 1 - coherence
	distorsion_avg = np.mean(distorsion)
	distorsion_std = np.std(distorsion)
	print("distorsion(%): {0:.1f} std: {1:.1f}".format(distorsion_avg * 100, distorsion_std * 100))
	log_coherence = abs(np.log10(coherence)) 
	log_coherence_sum = sum(log_coherence)
	print(log_coherence)

	# the numbers have been gotten from my personal observations
	threshold_mean = 1 # mean not more than 0.9 (1 - 0.9 = 1)
	threshold_std =  0.5 # with std dev not more than 0.5

	coh_sum = log_coherence_sum
	coh_mean = np.mean(log_coherence)
	coh_std =  np.std(log_coherence)

	print(
		"log coherence sum: {0:.1f} "
		"mean: {1:.1f} std: {2:.1f}".
		format(coh_sum, coh_mean, coh_std))

	signal_is = "GOOD"
	if coh_mean > threshold_mean or coh_std > threshold_std:
		signal_is = "BAD"
	print("The signal is {0}".format(signal_is))
		
	plot.show()
	
	
def get_lombscragle(filename1, filename2):
	f1_data, f1_sample_rate = get_file_data(filename1)
	f2_data, f2_sample_rate = get_file_data(filename2)

	if f1_sample_rate != f2_sample_rate:
		print("Sample rates of the signals differ but have to be the same. Exiting... ")
		return
	else:
		sample_rate = f1_sample_rate

	f = np.linspace(0.01, sample_rate, 100)
	r = signal.lombscargle(f1_data, f2_data, f)
	data_len = f1_data.shape[0]
	r = np.sqrt(r / data_len)
	plot.plot(f, r)
	print("lombscragle vector len: {0}".format(len(r)))
	print(r)
	print("lombscragle vector sum: {0}".format(sum(r)))
	plot.show()

if __name__ == "__main__":
	get_coherence(sys.argv[1], sys.argv[2])
#	get_lombscragle(sys.argv[1], sys.argv[2])
