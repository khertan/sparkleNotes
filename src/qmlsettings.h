#ifndef QMLSETTINGS_H
#define QMLSETTINGS_H

#include <QSettings>

class QMLSettings : public QSettings
{
    Q_OBJECT
public:
    explicit QMLSettings(QObject *parent = 0);
    Q_INVOKABLE void set(QString key, QString value);
    Q_INVOKABLE QVariant get(QString key);
    Q_INVOKABLE QString readPubKey();
    Q_INVOKABLE bool keygen();

signals:

public slots:

};

#endif // QMLSETTINGS_H
