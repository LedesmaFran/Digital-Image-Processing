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
        self.img_shape = np.shape(img)

    def draw(self):
        x_center = self.img_shape[0]*(self.centro_x+1)//2
        y_center = self.img_shape[0]*(self.centro_y+1)//2
        cv2.ellipse(Image=self.img, angle=self.inclinacion, center=(x_center, y_center), )
        