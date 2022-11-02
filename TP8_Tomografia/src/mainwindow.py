# PyQt5 modules
from PyQt5.QtWidgets import QMainWindow, QFileDialog, QInputDialog, QApplication, QWidget, QPushButton, QAction, QLineEdit, \
    QMessageBox
from PyQt5.QtCore import QCoreApplication, QObject, QRunnable, QThread, QThreadPool, pyqtSignal, pyqtSlot
from PyQt5 import uic, QtGui
from PyQt5.QtGui import QFont

# Project modules
from src.ui.mainwindow import Ui_MainWindow

# Python Modules
import numpy as np
import cv2

class MainWindow(QMainWindow, Ui_MainWindow):

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setupUi(self)
        self.statusbar.hide()
        self.setFixedSize(1000, 800)
