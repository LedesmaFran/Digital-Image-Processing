import skimage
import PIL
import numpy as np
import scipy.fft as fft
import plotly.graph_objects as go
import plotly.express as px
import scipy.signal as ss


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