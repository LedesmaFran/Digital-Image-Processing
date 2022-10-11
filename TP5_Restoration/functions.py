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


def compare(images):
    fig=plt.figure(figsize=(14, 10))
    n_images = len(images)
    i=1
    for key, value in images.items():
        fig.add_subplot(1, n_images, i)
        plt.title(key)
        plt.imshow(value,cmap='gray')
        i+=1

def normal_noise(img,snr):
    # return np.random.normal(0,np.sqrt(((img.std())**2) * (10**(-snr/10))), img.shape )
    img_std = img.std()
    noise_std = np.sqrt(((img_std)**2) * (10**(-snr/10)))
    return np.random.normal(0,noise_std, img.shape)


def apply_wiener_filter(img, deg_img, noise, kernel):
    H = np.fft.fft2(kernel)
    D = np.fft.fft2(deg_img)
    Snn = np.square(np.abs(np.fft.fft2(noise)))
    Sff = np.square(np.abs(np.fft.fft2(img)))
    W = np.conj(H)/(np.square(np.abs(H)) + Snn/Sff)
    F_hat = np.fft.fftshift(W*D)
    f = np.real(np.fft.fftshift(np.fft.ifft2(np.fft.ifftshift(F_hat))))
    return f