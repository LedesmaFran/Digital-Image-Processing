import matplotlib.pyplot as plt
import numpy as np
from cv2 import filter2D
from PIL import Image
def imadjust(x,a,b,c,d):
    # Similar to imadjust in MATLAB.
    # Converts an image range from [a,b] to [c,d].
    x_a = x < a
    x_b = x > b
    y = x.copy()
    y[x_a] = c
    y[x_b] = d
    return y

def build_gamma_comparison():
    # Only for clarity in main code
    desk = Image.open('img/GammaDesktop.png')
    pablo = Image.open('img/GammaBlackW.png')
    pablo_nm = Image.open('img/GammaBlackW_NM.png')
    mati = Image.open('img/GammaMati.png')
    mati_nm = Image.open('img/GammaMati_NM.png')
    w, h = mati.size
    desk = desk.resize((2*w,2*h), resample=Image.NEAREST)
    pablo = pablo.resize((w,h), resample=Image.NEAREST)
    pablo_nm = pablo_nm.resize((w,h), resample=Image.NEAREST)
    mati_nm = mati_nm.resize((w,h), resample=Image.NEAREST)
    desk = np.asarray(desk)
    pablo = np.asarray(pablo)
    pablo_nm = np.asarray(pablo_nm)
    mati = np.asarray(mati)
    mati_nm = np.asarray(mati_nm)

    comp_H = np.concatenate((pablo, mati), axis=1)
    comp_L = np.concatenate((pablo_nm, mati_nm), axis=1)
    comp_sq = np.concatenate((comp_H, comp_L))
    comp = np.concatenate((comp_sq, desk), axis=1)
    return Image.fromarray(comp)

def calc_prob(data,plot=False,figsize=(16,8)):
    pdf, bins = np.histogram(data.flatten(), bins=int(data.max()-data.min()), density=True)
    cdf = np.cumsum(pdf)/pdf.sum()

    if plot:
        fig, ax1 = plt.subplots(1, 1, figsize=figsize)
        ax2 = ax1.twinx()
        n, bins, patches  = ax1.hist(data.flatten(),256,[0,256], width=1.0, label='Histograma')
        ax1.set_xlabel('$r$', fontsize=16)
        ax1.set_ylabel('$p_r(r)$', fontsize=16)
        # ax1.legend(fontsize=16)
        # ax1.grid()

        cdf_line, = ax2.plot(cdf,'r-',label='cdf')
        ax2.set_xlabel('$r$', fontsize=16)
        ax2.set_ylabel('$P_r(r)$', fontsize=16)
        # ax2.legend(fontsize=16)
        # ax2.grid()
        # lns = patches + cdf_line
        # labs = [l.get_label() for l in lns]
        # ax1.legend(lns, labs, fontsize=16)


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