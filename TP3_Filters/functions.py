import numpy as np
from scipy import fft
import matplotlib.pyplot as plt
from cv2 import filter2D

def lowpass_unit_kernel(img, n):
    kernel = np.ones((n,n),dtype=float)/(n*n)
    img_filtered = filter2D(src=img, ddepth=-1, kernel=kernel)
    return img_filtered

def binary_mask(img, threshold):
    keep = img > threshold
    dump = img < threshold
    mask = img.copy()
    mask[keep] = 255
    mask[dump] = 0
    return mask

def salt_and_pepper_noise(img, d=0.05):
    h, w = img.shape
    sp_mat = np.random.rand(h, w)
    salt = sp_mat > (1-d/2)
    pepper = sp_mat < d/2
    img_sp = img.copy()
    img_sp[salt] = 255
    img_sp[pepper] = 0
    return img_sp

def HB_Filter(A,img):
    n = 3
    kernel = np.ones((n,n))*(-1)
    kernel[n//2,n//2] = A+8
    return filter2D(src=img, ddepth=-1, kernel=kernel)

def homomorphic_filter(img, gamma_h=10, gamma_l=0.4, c=1, D0=0.1, plot_filter=False):
    
    m = np.log(img + 0.000001)
    
    M = fft.fft2(m)

    d_center = (np.array(M.shape) - 1) / 2
    d = np.array([np.sqrt((range(img.shape[0]) - d_center[0])**2 + (i - d_center[1])**2) for i in range(img.shape[1])]).T
    
    H = (gamma_h - gamma_l) * (1 - np.exp(-c * d**2 / (2*D0 * img.shape[0])**2)) + gamma_l
    H = np.interp(H, (H.min(), H.max()), (H.min(), 1))

    if (plot_filter):
        plt.imshow(H)
        plt.colorbar()

    N = np.multiply(M, H)
    n = np.exp(fft.ifft2(N, s=np.shape(img)).real)
    
    return n
