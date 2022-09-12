import matplotlib.pyplot as plt
import numpy as np
from cv2 import filter2D

def imadjust(x,a,b,c,d):
    # Similar to imadjust in MATLAB.
    # Converts an image range from [a,b] to [c,d].
    x_a = x < a
    x_b = x > b
    y = x.copy()
    y[x_a] = c
    y[x_b] = d
    return y

def calc_prob(data,plot=False,figsize=(16,8)):
    pdf, bins = np.histogram(data.flatten(), bins=int(data.max()-data.min()), density=True)
    cdf = np.cumsum(pdf)

    if plot:
        fig, ax1 = plt.subplots(1, 1, figsize=figsize)
        ax2 = ax1.twinx()
        ax1.bar(bins[:-1]+0.5, pdf, width=1.0, label='Densidad de probabilidad')
        ax1.set_xlabel('$r$', fontsize=16)
        ax1.set_ylabel('$p_r(r)$', fontsize=16)
        ax1.legend(fontsize=16)
        # ax1.grid()

        ax2.plot(cdf,'r-',label='Distribución de probabilidad')
        ax2.set_xlabel('$r$', fontsize=16)
        ax2.set_ylabel('$P_r(r)$', fontsize=16)
        ax2.legend(fontsize=16)
        # ax2.grid()

        plt.show()
    
    return pdf, cdf


def apply_transformation(transform, image):
    return np.asarray(list(map(np.vectorize(transform), image)), dtype=np.uint8)

def contrast_stretching(threshold, max_value, input_pixel):
    return max_value if input_pixel > threshold else 0

def logaritmic(coefficient, max_value, input_pixel):
    return coefficient * np.log10(1 + input_pixel / max_value)

def exponential_logaritmic(coefficient, gamma, max_value, input_pixel):
    return coefficient * ((input_pixel / max_value) ** gamma)