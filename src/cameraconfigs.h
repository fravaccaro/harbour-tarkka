/*
Copyright (c) 2021 Jolla Ltd.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
  * Neither the name of the Jolla Ltd. nor the names of
    its contributors may be used to endorse or promote products
    derived from this software without specific prior written
    permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL JOLLA LTD OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef CAMERACONFIGS_H
#define CAMERACONFIGS_H

#include <QObject>
#include <QSize>
#include <QVariantList>

QT_BEGIN_NAMESPACE
class QCamera;
class QCameraImageCapture;
class QMediaRecorder;
QT_END_NAMESPACE

class CameraConfigs : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject * camera READ camera WRITE setCamera NOTIFY cameraChanged)

    // TODO: Replace QVariantList here with QList<QSize> on newer Qt
    Q_PROPERTY(QVariantList supportedViewfinderResolutions READ supportedViewfinderResolutions NOTIFY supportedViewfinderResolutionsChanged)
    Q_PROPERTY(QVariantList supportedImageResolutions READ supportedImageResolutions NOTIFY supportedImageResolutionsChanged)
    Q_PROPERTY(QVariantList supportedVideoResolutions READ supportedVideoResolutions NOTIFY supportedVideoResolutionsChanged)
    Q_PROPERTY(QVariantList supportedIsoSensitivities READ supportedIsoSensitivities NOTIFY supportedIsoSensitivitiesChanged)
    Q_PROPERTY(QVariantList supportedWhiteBalanceModes READ supportedWhiteBalanceModes NOTIFY supportedWhiteBalanceModesChanged)
    Q_PROPERTY(QVariantList supportedExposureModes READ supportedExposureModes NOTIFY supportedExposureModesChanged)
    Q_PROPERTY(QVariantList supportedFocusModes READ supportedFocusModes NOTIFY supportedFocusModesChanged)
    Q_PROPERTY(QVariantList supportedFocusPointModes READ supportedFocusPointModes NOTIFY supportedFocusPointModesChanged)
    Q_PROPERTY(QVariantList supportedMeteringModes READ supportedMeteringModes NOTIFY supportedMeteringModesChanged)
    Q_PROPERTY(QVariantList supportedFlashModes READ supportedFlashModes NOTIFY supportedFlashModesChanged)

public:
    CameraConfigs(QObject *parent = 0);
    ~CameraConfigs();

    QList<QObject *> exposedItems() const;

    QVariantList supportedViewfinderResolutions() const;
    QVariantList supportedImageResolutions() const;
    QVariantList supportedVideoResolutions() const;
    QVariantList supportedIsoSensitivities() const;
    QVariantList supportedWhiteBalanceModes() const;
    QVariantList supportedExposureModes() const;
    QVariantList supportedFocusModes() const;
    QVariantList supportedFocusPointModes() const;
    QVariantList supportedMeteringModes() const;
    QVariantList supportedFlashModes() const;

    void setCamera(QObject *camera);
    QObject *camera() const;

signals:
    void cameraChanged();
    void supportedViewfinderResolutionsChanged();
    void supportedImageResolutionsChanged();
    void supportedVideoResolutionsChanged();
    void supportedIsoSensitivitiesChanged();
    void supportedWhiteBalanceModesChanged();
    void supportedExposureModesChanged();
    void supportedFocusModesChanged();
    void supportedFocusPointModesChanged();
    void supportedMeteringModesChanged();
    void supportedFlashModesChanged();
private slots:
    void handleStatus();
    void handleState();
private:
    bool m_initialized = true;
    QCamera *m_camera = nullptr;
    QObject *m_qmlCamera = nullptr;
    QVariantList m_supportedViewfinderResolutions;
    QVariantList m_supportedImageResolutions;
    QVariantList m_supportedVideoResolutions;
    QVariantList m_supportedIsoSensitivities;
    QVariantList m_supportedWhiteBalanceModes;
    QVariantList m_supportedExposureModes;
    QVariantList m_supportedFocusModes;
    QVariantList m_supportedFocusPointModes;
    QVariantList m_supportedMeteringModes;
    QVariantList m_supportedFlashModes;
};

#endif // CAMERACONFIGS_H

