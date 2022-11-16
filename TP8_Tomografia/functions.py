import numpy as np
import matplotlib.pyplot as plt
import cv2
from skimage.transform import radon, iradon, rescale

def radon_g4(image, start_deg=0., end_deg=180., step_deg=-1.):
    my_image = image.copy()
    n = max(my_image.shape) if step_deg == -1. else (int(end_deg/step_deg)+1)
    theta = np.linspace(start_deg, end_deg, n, endpoint=True)
    return theta, radon(my_image, theta=theta, circle=False), n

def view_deg(sinogram, deg, step_deg):
    h = sinogram.shape[0]
    pixels = np.linspace(start=0, stop=h, num=h, endpoint=False)
    deg_data = np.flip(sinogram[:,int(deg/step_deg)])
    return pixels, deg_data

"""
Filters available: ramp, shepp-logan, cosine, hamming, hann. Assign None to use no filter.
Interpolation methods available: ‘linear’, ‘nearest’, and ‘cubic’ (‘cubic’ is slow).
"""
def iradon_g4(image, sinogram, theta, filter_name='ramp', interpolation='linear'):
    my_image = image.copy()
    if len(my_image.shape) == 3:
        my_image = cv2.cvtColor(my_image, cv2.COLOR_RGB2GRAY)
    #my_image = rescale(my_image, scale=0.4, mode='reflect', channel_axis=None)
    reconstruction = iradon(sinogram, theta=theta, filter_name=filter_name, interpolation=interpolation, circle=False)
    error_rms = np.sqrt(np.mean((reconstruction - my_image)**2))
    return reconstruction, error_rms