#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import libcalamares
from libcalamares.ui.helpers import *
from PySide2.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QLabel,
    QRadioButton,
    QButtonGroup,
    QSpacerItem,
    QSizePolicy
)

class DesktopPage(QWidget):
    def __init__(self):
        super().__init__()
        
        # Set up the UI
        self.setLayout(QVBoxLayout())
        
        # Add title
        title = QLabel("Choose your desktop environment")
        title.setStyleSheet("font-size: 18pt; font-weight: bold;")
        self.layout().addWidget(title)
        
        # Add description
        description = QLabel("Select the desktop environment you want to install:")
        self.layout().addWidget(description)
        
        # Create button group
        self.button_group = QButtonGroup(self)
        
        # KDE option
        self.kde_radio = QRadioButton("KDE Plasma - A modern, feature-rich desktop environment")
        self.kde_radio.setChecked(True)
        self.layout().addWidget(self.kde_radio)
        self.button_group.addButton(self.kde_radio, 1)
        
        # GNOME option
        self.gnome_radio = QRadioButton("GNOME - A simple, elegant desktop environment")
        self.layout().addWidget(self.gnome_radio)
        self.button_group.addButton(self.gnome_radio, 2)
        
        # XFCE option
        self.xfce_radio = QRadioButton("XFCE - A lightweight desktop environment")
        self.layout().addWidget(self.xfce_radio)
        self.button_group.addButton(self.xfce_radio, 3)
        
        # Add spacer
        spacer = QSpacerItem(20, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)
        self.layout().addItem(spacer)

def run():
    return None

def get_desktop_choice():
    if DesktopPage.kde_radio.isChecked():
        return "kde"
    elif DesktopPage.gnome_radio.isChecked():
        return "gnome"
    else:
        return "xfce"

def create_widget():
    return DesktopPage()

def next_clicked():
    # Get the selected desktop environment
    if DesktopPage.kde_radio.isChecked():
        desktop_env = "kde"
    elif DesktopPage.gnome_radio.isChecked():
        desktop_env = "gnome"
    else:
        desktop_env = "xfce"
    
    # Save it to a file
    with open("/tmp/desktop_choice", "w") as f:
        f.write(desktop_env)
    
    # Run the setup script
    os.system("/usr/bin/setup-desktop-packages")
    
    return None
