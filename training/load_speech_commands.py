import os 
import numpy as np
import librosa
import matplotlib.pyplot as plt 
import soundfile as sf

pad_amount = 0
#dataset_path = "./speech_commands_v0.02"
def pad_audiofile(data):
    """
    pad audiofile to 16000
    """
    data, sr = sf.read(path, dtype='float32')
    pad_amount = pad_amount + 1
    print(f"[{pad_amount}]paddind:{path}, with shape{data.shape}")
    sample = np.zeros(16000)
    sample[:sample_1.shape[0]] = data
    sf.write(path, sample, sr)



def load_data(dataset_path, num=20000, sr=16000):
    """
    load all num samples and 10 class .
    resample the audio signal by rate of sr.
    return x(num,sr), y(num), labels.
   
    """

    #get the dir and files in the dataset path
    dataset_dirs = os.listdir(dataset_path)
    #get all sample file dirs in a list,
    dataset_sample_files = []
    labels = list()
    for dir in dataset_dirs:
        if dir[0] == "_":
            print(dir, "passed")
            continue
    
        fdir = f"{dataset_path}/{dir}"
        if not os.path.isdir(fdir):
            print(fdir, " is not a dir")
            continue

        labels.append(dir)
        filelist = os.listdir(fdir)
        filelist = [f"{fdir}/{s}" for s in filelist]
        print(filelist)
        dataset_sample_files = dataset_sample_files + filelist[:num//10]


    # #pad  audio file with zero
    # for sample_path in dataset_sample_files:
    #     data, sr = sf.read(sample_path, dtype='float32')
    #     if data.shape[0] != 16000:
    #         sample = np.zeros(16000)
    #         sample[:data.shape[0]] = data
    #         sf.write(sample_path, sample, sr,  subtype='PCM_16')

    #generate label
    #y is among (0, 1, 2,..., 9)
    data_y = np.zeros(num)
    for i in range(10):
        data_y[i*num//10: (i+1)*num//10] = i

    #load data to numpy array
    data_x = np.zeros((num, sr), dtype=np.float32) 
    for i, sample_path in enumerate(dataset_sample_files):
        # print(f"load {i}, {sample_path}")
        sample, _ = librosa.load(sample_path, sr=sr)
        data_x[i, :sample.shape[0]]= sample
            
            

    #shuffle x and y
    idx = np.arange(num)
    np.random.shuffle(idx)
    data_y = data_y[idx]
    data_x = data_x[idx]

    return data_x, data_y, labels

    