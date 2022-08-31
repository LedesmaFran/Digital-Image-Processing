import numpy as np
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