from pickletools import uint8
from IPython.display import display
from PIL import Image
from skimage.measure import block_reduce
import numpy as np
import cv2

def displayImage(img, w, h):
    display(img.resize((w,h), resample=Image.NEAREST))

def displayImage_fromcv2(img, w, h):
    img = Image.fromarray(img.astype(np.uint8))
    displayImage(img, w, h)

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
