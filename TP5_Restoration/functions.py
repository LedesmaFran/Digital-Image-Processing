import numpy as np
from scipy import fft,ndimage
import matplotlib.pyplot as plt
import cv2
import math

def gaussian_kernel(size=5, sigma=1.):
    arr = np.linspace(-(size - 1) / 2., (size - 1) / 2., size)
    gauss = np.exp(-0.5 * np.square(arr) / np.square(sigma))
    kernel = np.outer(gauss, gauss)
    return kernel / np.sum(kernel)

def resize_kernel(size,kernel):
    delta_arr = np.zeros(size).astype(np.float64)
    delta_arr[delta_arr.shape[0]//2,delta_arr.shape[1]//2] = 1
    return cv2.filter2D(src=delta_arr, kernel=kernel, ddepth=-1)

def apply_filter(F,H):
    res = np.fft.fftshift(np.fft.fft2(F)*np.fft.fft2(H)) 
    return np.real(np.fft.fftshift(np.fft.ifft2(np.fft.ifftshift(res))))

def apply_inverse_filter(G,H):
    res = np.fft.fftshift(np.fft.fft2(G)/(np.fft.fft2(H)))
    return np.real(np.fft.fftshift(np.fft.ifft2(np.fft.ifftshift(res))))

def plot_images(original,txt1,degraded,txt2,restored,txt3):
    fig=plt.figure(figsize=(14, 10))
    fig.add_subplot(1, 3, 1)
    plt.title(txt1)
    plt.imshow(original,cmap='gray')
    fig.add_subplot(1, 3, 2)
    plt.title(txt2)
    plt.imshow(degraded,cmap='gray')
    fig.add_subplot(1, 3, 3)
    plt.title(txt3)
    plt.imshow(restored,cmap='gray')