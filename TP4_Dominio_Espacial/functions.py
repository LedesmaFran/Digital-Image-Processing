import numpy as np
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