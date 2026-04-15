#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <sailfishapp.h>
#include <QStandardPaths>
#include "cameraconfigs.h"

static QObject *singletonFactory(QQmlEngine *, QJSEngine *)
{
    return new CameraConfigs;
}

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    // Register CameraConfigs
    qmlRegisterSingletonType<CameraConfigs>("CameraGallery", 1, 0, "CameraConfigs", singletonFactory);

    // Ask where the Pictures folder is
    QString picturesLocation = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);

    // Set "StandardPicturesPath" and serve it to the QML
    view->rootContext()->setContextProperty("StandardPicturesPath", picturesLocation);

    // Ask for the standard Cache folder (XDG_CACHE_HOME)
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);

    // Set "AppCachePath" and serve it to the QML
    view->rootContext()->setContextProperty("AppCachePath", cachePath);

    view->setSource(SailfishApp::pathToMainQml());
    view->show();

    return app->exec();
}
