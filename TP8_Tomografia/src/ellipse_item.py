import numpy as np
import cv2

class Ellipse():
    def __init__(self, img, intensidad=0, inclinacion=0, semi_eje_x=0.001, semi_eje_y=0.001, centro_x=0, centro_y=0):
        self.intensidad = intensidad
        self.inclinacion = inclinacion
        self.semi_eje_x = semi_eje_x
        self.semi_eje_y = semi_eje_y
        self.centro_x = centro_x
        self.centro_y = centro_y
        self.img = img
        b = self.norm_intensity()
        self.color = (b, b, b)

    def draw(self):
        imag = cv2.imread(self.img)
        self.img_shape = imag.shape
        x_center = int(self.img_shape[0]*(self.centro_x+1)//2)
        y_center = int(self.img_shape[1]*(self.centro_y+1)//2)
        center = (x_center, y_center)

        x_axis = int((self.img_shape[0]//2)*self.semi_eje_x)
        y_axis = int((self.img_shape[1]//2)*self.semi_eje_y)
        axes = (x_axis, y_axis)


        return cv2.ellipse(imag, angle=self.inclinacion, center=center, startAngle=0, endAngle=360,
                            axes=axes, color=self.color, thickness=-1)

    def norm_intensity(self):
        return int(255*(self.intensidad + 1)/2)
        