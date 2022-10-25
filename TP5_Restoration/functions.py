import numpy as np
from scipy import fft,ndimage
from scipy.signal import convolve
from collections.abc import Iterable
import matplotlib.pyplot as plt
import plotly.express as px
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


def motion_kernel(d, angle, size=None):
    kernel = np.zeros((d, d), dtype=np.float32)
    kernel[(d-1)// 2,:] = np.ones(d, dtype=np.float32)
    kernel = cv2.warpAffine(kernel, cv2.getRotationMatrix2D((d/2-0.5,d/2-0.5) , angle, 1.0), (d, d))  
    kernel = kernel * ( 1.0 / np.sum(kernel) )
    if size is not None:
        if size > d:
            pad_len = (size - d)//2
            kernel = np.pad(kernel, pad_len, mode='constant')
    return kernel


new_float_type = {
    # preserved types
    np.float32().dtype.char: np.float32,
    np.float64().dtype.char: np.float64,
    np.complex64().dtype.char: np.complex64,
    np.complex128().dtype.char: np.complex128,
    # altered types
    np.float16().dtype.char: np.float32,
    'g': np.float64,      # np.float128 ; doesn't exist on windows
    'G': np.complex128,   # np.complex256 ; doesn't exist on windows
}

def _supported_float_type(input_dtype, allow_complex=False):
    """Return an appropriate floating-point dtype for a given dtype.
    float32, float64, complex64, complex128 are preserved.
    float16 is promoted to float32.
    complex256 is demoted to complex128.
    Other types are cast to float64.
    Parameters
    ----------
    input_dtype : np.dtype or Iterable of np.dtype
        The input dtype. If a sequence of multiple dtypes is provided, each
        dtype is first converted to a supported floating point type and the
        final dtype is then determined by applying `np.result_type` on the
        sequence of supported floating point types.
    allow_complex : bool, optional
        If False, raise a ValueError on complex-valued inputs.
    Returns
    -------
    float_type : dtype
        Floating-point dtype for the image.
    """
    if isinstance(input_dtype, Iterable) and not isinstance(input_dtype, str):
        return np.result_type(*(_supported_float_type(d) for d in input_dtype))
    input_dtype = np.dtype(input_dtype)
    if not allow_complex and input_dtype.kind == 'c':
        raise ValueError("complex valued input is not supported")
    return new_float_type.get(input_dtype.char, np.float64)


def richardson_lucy(image, psf, num_iter=50, clip=True, filter_epsilon=None):
    """https://github.com/scikit-image/scikit-image/blob/master/skimage/restoration/deconvolution.py"""

    """Richardson-Lucy deconvolution.
    Parameters
    ----------
    image : ndarray
       Input degraded image (can be n-dimensional).
    psf : ndarray
       The point spread function.
    num_iter : int, optional
       Number of iterations. This parameter plays the role of
       regularisation.
    clip : boolean, optional
       True by default. If true, pixel value of the result above 1 or
       under -1 are thresholded for skimage pipeline compatibility.
    filter_epsilon: float, optional
       Value below which intermediate results become 0 to avoid division
       by small numbers.
    Returns
    -------
    im_deconv : ndarray
       The deconvolved image.
    Examples
    --------
    >>> from skimage import img_as_float, data, restoration
    >>> camera = img_as_float(data.camera())
    >>> from scipy.signal import convolve2d
    >>> psf = np.ones((5, 5)) / 25
    >>> camera = convolve2d(camera, psf, 'same')
    >>> rng = np.random.default_rng()
    >>> camera += 0.1 * camera.std() * rng.standard_normal(camera.shape)
    >>> deconvolved = restoration.richardson_lucy(camera, psf, 5)
    References
    ----------
    .. [1] https://en.wikipedia.org/wiki/Richardson%E2%80%93Lucy_deconvolution
    """
    float_type = _supported_float_type(image.dtype)
    image = image.astype(float_type, copy=False)
    psf = psf.astype(float_type, copy=False)
    im_deconv = np.full(image.shape, 0.5, dtype=float_type)
    psf_mirror = np.flip(psf)

    # Small regularization parameter used to avoid 0 divisions
    eps = 1e-12

    for _ in range(num_iter):
        conv = convolve(im_deconv, psf, mode='same') + eps
        if filter_epsilon:
            relative_blur = np.where(conv < filter_epsilon, 0, image / conv)
        else:
            relative_blur = image / conv
        im_deconv *= convolve(relative_blur, psf_mirror, mode='same')

    if clip:
        im_deconv[im_deconv > 1] = 1
        im_deconv[im_deconv < -1] = -1

    return im_deconv

def distance(x, y, cx, cy):
    return (x - cx)**2 + (y - cy)**2