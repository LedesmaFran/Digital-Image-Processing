from importlib.resources import path
from PIL import Image
import numpy as np

def openImage(path):
    fs = Image.open(path)
    print(fs.size)
    display(fs)
    return fs