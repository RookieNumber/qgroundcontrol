/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QtCore/QObject>
#include <QtCore/QSettings>

class PasswordAuthManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool accessGranted READ accessGranted NOTIFY accessChanged)

public:
    explicit PasswordAuthManager(QObject* parent = nullptr);

    Q_INVOKABLE bool authenticate(const QString& plainPassword);
    Q_INVOKABLE bool setPassword(const QString& newPassword);
    Q_INVOKABLE void logout();

    bool accessGranted() const { return _accessGranted; }

signals:
    void accessChanged();

private:
    QString _hashPassword(const QString& plain) const;
    bool _accessGranted{false};
    QSettings _settings;
};
