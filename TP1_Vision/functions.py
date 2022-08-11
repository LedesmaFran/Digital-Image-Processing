import imp
from importlib.resources import path
from operator import imod
from IPython.display import display
from PIL import Image
from skimage.measure import block_reduce
import numpy as np
import math


def makeSquare(sides_value, center_value):
    square = np.full(shape=(3,3), fill_value=sides_value, dtype=np.uint8)
    square[square.shape[0]//2,square.shape[1]//2] = center_value
    return square

def avgTiles(img_tiled):
    return img_tiled.mean(axis=(2,3)).astype(np.uint8)


def getPixelSize(screen_density = 460):
    return (print("Pixel size:", round(0.0254/screen_density*1e6,4), "µm"))
