# PyQt5 modules
from PyQt5.QtWidgets import QMainWindow, QFileDialog, QInputDialog, QApplication, QWidget, QPushButton, QAction, QLineEdit, \
    QMessageBox
from PyQt5.QtCore import QCoreApplication, QObject, QRunnable, QThread, QThreadPool, pyqtSignal, pyqtSlot
from PyQt5 import uic, QtGui
from PyQt5.QtGui import QFont, QPixmap
from PyQt5.QtOpenGL import *

# Project modules
from src.ui.mainwindow import Ui_MainWindow
from src.ellipse_item import Ellipse

# Python Modules
import numpy as np
import cv2

class MainWindow(QMainWindow, Ui_MainWindow):

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setupUi(self)
        self.statusbar.hide()
        self.setFixedSize(1000, 800)

        self.ellipse_new.clicked.connect(self.draw_ellipse)
        self.ellipse_delete.clicked.connect(self.delete_ellipse)

        self.ellipse_list.clicked.connect(self.update_counters)

        self.ellipses = []

        self.img = np.zeros((self.img_box.width(), self.img_box.height()))
        self.im_path = 'image.png'
        self.update_image()

        self.nullRow = self.ellipse_list.currentRow()
        
        self.counter = 0

    def draw_ellipse(self):
        self.ellipses.append(Ellipse(img=self.im_path, intensidad=self.intensidad_box.value(), 
                                    inclinacion=self.inclinacion_box.value(), semi_eje_x=self.semi_eje_x_box.value(),
                                    semi_eje_y=self.semi_eje_y_box.value(), centro_x=self.centro_x_box.value(), 
                                    centro_y=self.centro_y_box.value()))
        self.counter += 1
        self.ellipse_list.addItem(f"Elipse {self.counter}")
        self.update_image()

    def delete_ellipse(self):
        if self.ellipse_list.currentRow() != self.nullRow:
            self.ellipses.remove(self.ellipses[self.ellipse_list.currentRow()])
            self.counter = self.counter - 1 if self.counter != 0 else 0
            self.ellipse_list.takeItem(self.ellipse_list.currentRow())
            for item in range(self.ellipse_list.count()):
                self.ellipse_list.item(item).setText(f"Elipse {item + 1}")
                
            self.update_image()
    
    def update_counters(self):
        item = self.ellipse_list.currentRow()
        el = self.ellipses[item]
        self.intensidad_box.setValue(el.intensidad)
        self.inclinacion_box.setValue(el.inclinacion)
        self.semi_eje_x_box.setValue(el.semi_eje_x)
        self.semi_eje_y_box.setValue(el.semi_eje_y)
        self.centro_x_box.setValue(el.centro_x)
        self.centro_y_box.setValue(el.centro_y)

    def update_image(self):
        self.img = np.zeros((self.img_box.width(), self.img_box.height()))
        cv2.imwrite(self.im_path, self.img)
        for el in self.ellipses:
            self.img = el.draw()
            cv2.imwrite(self.im_path, self.img)
        self.img_box.setPixmap(QPixmap(self.im_path))
