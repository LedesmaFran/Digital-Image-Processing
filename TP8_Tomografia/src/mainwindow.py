# PyQt5 modules
from PyQt5.QtWidgets import QMainWindow, QFileDialog, QInputDialog, QApplication, QWidget, QPushButton, QAction, QLineEdit, \
    QMessageBox
from PyQt5.QtCore import QCoreApplication, QObject, QRunnable, QThread, QThreadPool, pyqtSignal, pyqtSlot
from PyQt5 import uic, QtGui
from PyQt5.QtGui import QFont
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

        self.ellipse_counter = 0

        self.ellipse_list.clicked.connect(self.update_counters)

        self.ellipses = []

        self.img = np.zeros(self.img_box.size)

    def draw_ellipse(self):
        self.ellipses.append(Ellipse())
        return 0

    def delete_ellipse(self):
        # do stuff
        return 0
    
    def update_counters(self):
        item = self.ellipse_list.currentItem()

        return 0

    def update_image(self):
        # do stuff
        return 0