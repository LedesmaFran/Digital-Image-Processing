import imp
from importlib.resources import path
from operator import imod
from IPython.display import display
from PIL import Image
from skimage.measure import block_reduce
import numpy as np
import math


def displayImage(img, w, h):
    display(img.resize((w,h), resample=Image.NEAREST))

def tileImage(img, w_tile, h_tile):
    w, h = img.size
    im_mat = np.asarray(img)
    im_tiled = im_mat.reshape(h//h_tile, h_tile, w//w_tile, w_tile)
    im_tiled = im_tiled.swapaxes(1,2)
    return im_tiled

def pickPixelfromTile(img_tiled, pixel_pos):
    return img_tiled[:,:,pixel_pos[0],pixel_pos[1]]

def downscaleImage(img, new_w, new_h):
    mat = block_reduce(np.asarray(img), block_size=(img.size[0]//new_w, img.size[1]//new_h), func=lambda blocks, pixel_pos, axis: pickPixelfromTile(blocks, pixel_pos), func_kwargs={'pixel_pos': (0,0)})
    img = Image.fromarray(mat)
    return img


def makeSquare(sides_value, center_value):
    square = np.full(shape=(3,3), fill_value=sides_value, dtype=np.uint8)
    square[square.shape[0]//2,square.shape[1]//2] = center_value
    return square

def avgTiles(img_tiled):
    return img_tiled.mean(axis=(2,3)).astype(np.uint8)


def getPixelSize(screen_density = 460):
    return (print("Pixel size:", round(0.0254/screen_density*1e6,4), "µm"))
