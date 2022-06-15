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
model.load_weights("cnn_model_checkpoints/checkpoint_8k")


sr = 8000
buffer = np.zeros((int(sr*3/4)))

duration = 1000  # seconds


def callback(indata, outdata, frames, time, status):
    d = np.concatenate((buffer, indata[:, 0])) * 4
    print(d.shape)
    m = np.max(d)

    sample_mfccs = mfcc.get_mfcc(d, sr, n_fft=256, hop_length=128, n_mels=26, mfcc_n=13)
    # sample_mfccs = librosa.feature.mfcc(d, n_mfcc=13, sr=sr,  center=False, n_fft=256, hop_length=128, n_mels=26).T
    predict = model(sample_mfccs[np.newaxis, :, :, np.newaxis])
    sample_y = labels[np.argmax(predict)]
    confidence = np.max(predict)

    if confidence > 0.85 :
        print(f"you just said {sample_y}({confidence})")
        # plt.plot(d)
        # plt.show()
    print(m)
    #flush data

    buffer[:4000] = buffer[2000:]
    buffer[4000:] = indata[:, 0]

with sd.Stream(channels=1, callback=callback, blocksize=2000, samplerate=sr):
    sd.sleep(int(duration * 1000))