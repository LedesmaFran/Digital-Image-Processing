import numpy as np
import matplotlib.pyplot as plt
from functions import *

class Radon():
    def __init__(self):

        self.start = 0
        self.end = 0
        self.step = 0

        self.n = 0
        
        self.theta = 0
        self.img = 0
        self.radon = 0

        self.i_radon = 0
        self.i_theta = 0
        self.rms = 0

    def radon_transform(self, img, start, end, step):
        self.start = start
        self.end = end
        self.step = step

        self.img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        
        self.theta, self.radon, self.n = radon_g4(self.img, start_deg=self.start, end_deg=self.end, step_deg=self.step)
        self.i_theta = self.theta

    def radon_inverse(self, filter, interp):
        self.i_radon, self.rms = iradon_g4(self.img, self.radon, self.i_theta, 
                                        filter_name=filter, interpolation=interp)

    def radon_angle_view(self, angle):
        pixels, nulldeg = view_deg(self.radon, angle, self.step)
        plt.clf()
        plt.plot(pixels, nulldeg)
        plt.show()
