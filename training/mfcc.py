
"""
    Library to extract MFCC of audio clips.
    Author: Chuanghao Zhang

"""
import scipy as sp
import numpy as np
import librosa

#my Audio frame function
def frame(y, frame_length=None, hop_length=None):
    """
    No error checking, please use this function carefully!
    return  y_frames : np.ndarray [shape=(frame_length, N_FRAMES)]  
    """
    n_frames = 1 + int((len(y) - frame_length) / hop_length)
    y_frames = np.zeros((frame_length, n_frames), dtype=np.float32)
    
    for i in range(n_frames):
        y_frames[:, i] = y[i*hop_length: i*hop_length+frame_length]

    return y_frames

#window function
def get_hann_window(length=8):
    window = np.linspace(0, length-1, length,dtype=np.float32)
    return 0.5 - 0.5*np.cos(2*np.pi*window / length)



#My fft
def bit_reverse(x):
  """ x is one dimention numpy array"""
  n = x.shape[0]
  X = np.zeros(n, dtype=np.complex64)
  width = int(np.log2(n))
  for i in range(n):
    b = '{:0{width}b}'.format(i, width=width)
    i_rev = int(b[::-1], 2)
    X[i_rev] = x[i]

  return X


def my_FFT_i(x):
  """
  A iterative implementation of the 1D Cooley-Tukey FFT for real number
  x is 1-d numpy array
  float32 precision
  """
  x = x.astype(dtype=np.complex64)
  N = x.shape[0]
  if np.log2(N) % 1 != 0:
    raise ValueError("size of x must be a power of 2")
    
  X = bit_reverse(x)
  for s in range(1, int(np.log2(N))+1): #s stage, produce N/2**s 2**s point DFT
    m = 2**s
    w_m = np.exp(-2j*np.pi/m, dtype=np.complex64)
    for k in range(0, N, m):
      w = 1
      for j in range(m//2):
        t = w * X[k+j+m//2]
        u = X[k+j]
        X[k+j]   = u + t
        X[k+j+m//2] = u - t
        w = w*w_m
  return X


def my_fft(x):
    """
    x is 2-d np array, x[0] is fft we need to perform
    """
    #pre allocate 
    spectrogram = np.empty(x.shape, dtype=np.complex64)
    for i in range(x.shape[1]):
        spectrogram[:, i] = my_FFT_i(x[:, i])
    
    return spectrogram

def get_spectrogram(y, frame_length=None, hop_length=None):
    """
    spectrigram.shape = [frame_length//2+1, #frames]
    return  complex 64
    """
    y_frames = frame(y, frame_length, hop_length)
    #Get window
    fft_window = get_hann_window(frame_length)
    #Reshape so that the window can be broadcast
    fft_window = fft_window.reshape((-1, 1))
    #Add window
    y_frames = y_frames * fft_window
    
    #pre allocate 
    spectrogram = np.empty((int(1 + frame_length // 2), y_frames.shape[1]), dtype=np.complex64)
    spectrogram = np.fft.fft(y_frames, axis=0)[:spectrogram.shape[0]] 
    #my fft is too slow
    #spectrogram = my_fft(y_frames)[:spectrogram.shape[0]] 
    
    

    return spectrogram
    

#get mel filter banks
def get_mel_filters(sr, n_fft, n_mels=128, fmin=0.0, fmax=None):
    """
        Returns
        -------
        M  : np.ndarray [shape=(n_mels, 1 + n_fft/2)]
        return  precision float32
    """
    if fmax is None:
        fmax = sr / 2

    # Initialize the weights
    n_mels = int(n_mels)
    weights = np.zeros((n_mels, int(1 + n_fft // 2)), dtype=np.float32)

    #convert min and max frequency to mel and get n_mels 
    mel_max, mel_min = np.log10(np.asarray((fmin, fmax))/700 + 1) * 2595
    mel_band_points  = np.linspace(mel_max, mel_min, n_mels+2)

    #covert mel_band_points to frequency points
    freq_band_points = (10**(mel_band_points/2595) - 1) * 700
    #round frequency to nearest bins 
    bin_points = (freq_band_points / (sr/n_fft)).astype(np.int)
    #create filtes 
    for i in range(1, len(bin_points)-1):
        left_bin = bin_points[i-1]
        right_bin = bin_points[i+1]
        middle_bin = bin_points[i]
        left = np.linspace(0, 1, middle_bin-left_bin+1)
        right = np.linspace(1, 0, right_bin-middle_bin+1)
        
        #fix the index
        weights[i-1, left_bin:middle_bin] =  left[:-1]
        weights[i-1, middle_bin:right_bin] =  right[:-1]

    return weights
 
def get_melspectrogram(x, sr, n_fft=2048, hop_length=512, n_mels=20, pre_emphasis=0.97):
    """
    x is 1_d numpy array
    
    return shape(#n_mels, #frames)
    """
    #pre_emphasis
    #x = x - pre_emphasis*np.concatenate((np.zeros(1), x[:-1]))
    
    spectrogram = np.abs(get_spectrogram(x, frame_length=n_fft, hop_length=hop_length))
    filter_banks = get_mel_filters(n_fft=n_fft, sr=sr, n_mels=n_mels)
    
    return filter_banks @ (spectrogram**2)

def my_dct(x, n=None):
    """
    input is numpy array
    x.shape = [#frames, #frame_size]
    
    return [#frames, n]
    """
    if n is None:
        n = x.shape[0]
    
    frame_size = x.shape[1]
    W = np.zeros((frame_size, n), dtype=np.float32)
    m = np.arange(0, frame_size)
    for i in range(n):
        W[:, i] = np.cos(np.pi*i*(2*m+1)/2/frame_size)
    dct = x @ W * 2
    
    return dct

def get_dct_coe(n_filters, n_mfccs):
    """
    return shape = (n_filters, n_mfccs)
    """
    W = np.zeros((n_filters, n_mfccs), dtype=np.float32)
    m = np.arange(0, n_filters)
    for i in range(n_mfccs):
        W[:, i] = np.cos(np.pi*i*(2*m+1)/2/n_filters)
        
    return W*2

def get_mfcc(x, sr, n_fft=512, hop_length=256, n_mels=40, mfcc_n=20, pre_emphasis=0.97):
    """
    get mfcc one sample by one sample
    x is 1d numpy array
    return [#frames, n]
    """
    mel_spectrogram = get_melspectrogram(x, sr, n_fft=n_fft, hop_length=hop_length, n_mels=n_mels, pre_emphasis=pre_emphasis)
    log_mel_spectrogram = mel_spectrogram
    log_mel_spectrogram = np.log(mel_spectrogram + 1e-8) #prevent log(0)
    #return sp.fft.dct(log_mel_spectrogram.T)[:, :mfcc_n]
    return my_dct(log_mel_spectrogram.T, n=mfcc_n)

