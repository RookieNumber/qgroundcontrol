/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "PasswordAuthManager.h"
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <QDateTime>

static const char* KEY_HASH = "PasswordProtection/hash";
static const char* KEY_SALT = "PasswordProtection/salt";

PasswordAuthManager::PasswordAuthManager(QObject* parent)
    : QObject(parent),
      _settings("QGroundControl", "QGroundControl")
{
    if (!_settings.contains(KEY_SALT)) {
        QString salt = QString::number(QRandomGenerator::global()->generate64());
        _settings.setValue(KEY_SALT, salt);
    }
}

QString PasswordAuthManager::_hashPassword(const QString& plain) const {
    QByteArray salt = _settings.value(KEY_SALT).toByteArray();
    QByteArray data = salt + plain.toUtf8();
    return QString(QCryptographicHash::hash(data, QCryptographicHash::Sha256).toHex());
}

bool PasswordAuthManager::authenticate(const QString& plainPassword) {
    QString storedHash = _settings.value(KEY_HASH).toString();
    if (storedHash.isEmpty()) {
        _accessGranted = true; // no password set
    } else {
        _accessGranted = (_hashPassword(plainPassword) == storedHash);
    }
    emit accessChanged();
    return _accessGranted;
}

bool PasswordAuthManager::setPassword(const QString& newPassword) {
    if (newPassword.isEmpty()) return false;
    _settings.setValue(KEY_HASH, _hashPassword(newPassword));
    _accessGranted = true;
    emit accessChanged();
    return true;
}

void PasswordAuthManager::logout() {
    _accessGranted = false;
    emit accessChanged();
}
