import mfcc
import scipy as sp
import numpy as np
import matplotlib.pyplot as plt


n = 20
sample = np.random.randint(0, 100, (1,100))

my_dct = mfcc.my_dct(sample, n=n)
sp_dct = sp.fft.dct(sample)[:, :n]

plt.plot(range(n), sp_dct[0])
plt.figure()
plt.plot(range(n), my_dct[0])
plt.show()