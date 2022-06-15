import numpy as np
import tensorflow as tf
import get_model
import mfcc
import librosa
import sounddevice as sd
import time
import matplotlib.pyplot as plt

"""
real time audio test
"""
#load label
data = np.load("data_set_mfcc.npz")
labels = data["labels"]
#load snn model 
model = get_model.get_cnn_model((61, 13, 1))
model.load_weights("cnn_model_checkpoints/checkpoint")


sr = 16000
buffer = np.zeros((12000))

duration = 1000  # seconds


def callback(indata, outdata, frames, time, status):

    d = np.concatenate((buffer, indata[:, 0])) * 5
    m = np.max(d)

    sample_mfccs = mfcc.get_mfcc(d, sr, n_fft=512, hop_length=256, n_mels=26, mfcc_n=13)
    predict = model(sample_mfccs[np.newaxis, :, :, np.newaxis])
    sample_y = labels[np.argmax(predict)]
    confidence = np.max(predict)

    if confidence > 0.85 :
        print(f"you just said {sample_y}({confidence})")
        # plt.plot(d)
        # plt.show()
    print(m)
    #flush data
    buffer[:8000] = buffer[4000:]
    buffer[8000:] = indata[:, 0]

with sd.Stream(channels=1, callback=callback, blocksize=4000, samplerate=sr):
    sd.sleep(int(duration * 1000))