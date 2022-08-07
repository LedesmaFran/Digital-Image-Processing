from importlib.resources import path
from IPython.display import display
from PIL import Image
import numpy as np

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

# Buscar la forma de usar mean() sin usar for!!!
def avgTiles(img_tiled):
    return np.array([img_tiled[i,j].mean() for i in range(0, img_tiled.shape[0]) for j in range(0, img_tiled.shape[1])]).reshape(64,64).astype(np.uint8)