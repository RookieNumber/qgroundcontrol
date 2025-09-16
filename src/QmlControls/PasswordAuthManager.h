#pragma once

#include <QObject>
#include <QSettings>

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
