/*
 * Copyright © 2015-2016 Antti Lamminsalo
 *
 * This file is part of Orion.
 *
 * Orion is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with Orion.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "customapp.h"
#include <QDebug>

CustomApp::CustomApp(int &argc, char **argv): QApplication(argc, argv)
{
}

CustomApp::~CustomApp()
{
}

bool CustomApp::event(QEvent *e)
{
    // qDebug() << "Window event: " << e->type();
    if (e->type() == QEvent::Type::Quit){
        //Do nothing
    } else {
       QApplication::event(e);
    }

    return true;
}
