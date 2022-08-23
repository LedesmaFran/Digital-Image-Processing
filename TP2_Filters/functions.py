import skimage
from PIL import Image
import numpy as np
import scipy.fft as fft
import plotly.graph_objects as go
import plotly.express as px
import scipy.signal as ss
import scipy.ndimage
import numpy as np
import cv2

def plotImage(img_f,w,h):
    fig = px.imshow(img_f,binary_string=True)
    fig.update_layout(width=w, height=h, margin=dict(l=0, r=0, b=0, t=0))
    fig.show()


def disk(radius):
    N=2*int(radius)+1
    F = np.zeros((N,N))
    for i in range(N):
        for j in range(N):
            r2 = (i-N//2)**2 + (j-N//2)**2
            if r2 <= radius**2:
                F[i,j]=1/(np.pi*radius**2)
    return F


def laplacian(alpha=0.2):
    lc = -4/(alpha+1)
    l1 = alpha/(alpha+1)
    l2 = (1-alpha)/(alpha+1)
    return np.array([[l1,l2,l1],
            [l2,lc,l2],
            [l1,l2,l1]])

def unsharp(alpha=0.2):
    identity = np.array([[0,0,0],[0,1,0],[0,0,0]])
    return identity-laplacian(alpha=alpha)

def freqz2(h,title,N=256):
    H = fft.fftshift(fft.fft2(h, [N, N]))
    f = fft.fftshift(fft.fftfreq(N))
    fig = go.Figure(data=[go.Surface(x=f, y=f, z=np.abs(H))])
    fig.update_layout(title=title,
                      scene = dict(
                    xaxis_title='Fx',
                    yaxis_title='Fy',
                    zaxis_title='Magnitude'),
                    width=400,
                    height=400,
                    margin=dict(r=30, b=30, l=30, t=30))
    fig.show()
    
def conv2(x, y, mode='same'):
    return np.rot90(ss.convolve2d(np.rot90(x, 2), np.rot90(y, 2), mode=mode), 2)

# Downsample the square image img by a factor of m
def downsampling(img, m, filter):
    N,M = img.size
    if N != M:
        N = min(N, M)
        img = img.crop((0,0,N-1,N-1))   # Correct if not square
    
    if filter == 'FILTER_ON':
        w = 1.0/m
        F = fft.fftshift(fft.fft2(np.asarray(img), [N, N]))

        for i in range(N):
            for j in range(N):
                r2 = (i-N//2)**2 + (j-N//2)**2
                if r2 > int((N/2*w)**2): 
                    F[i,j] = 0
        
        img = np.real(fft.ifft2(fft.fftshift(F)))
        img = Image.fromarray(img.astype(np.uint8))

    return img.resize((N//m,N//m), resample=Image.NEAREST)

# Upsample the square image img by a factor of m
def upsampling(img, m):
    N,M = img.size
    if N != M:
        N = min(N, M)
        img = img.crop((0,0,N-1,N-1))   # Correct if not square
    
    N = m*N
    img_up = np.zeros((N, N))

    # Expand input image
    img_up[::m, ::m] = np.asarray(img)
    
    # Ideal filter
    w = 1.0/m
    F = fft.fftshift(fft.fft2(img_up, [N, N]))

    for i in range(N):
        for j in range(N):
            r2 = (i-N//2)**2 + (j-N//2)**2
            if r2 > int((N/2*w)**2): 
                F[i,j] = 0
    
    img = (m**2)*np.real(fft.ifft2(fft.fftshift(F)))
    return Image.fromarray(img.astype(np.uint8))
