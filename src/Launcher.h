#ifndef LAUNCHER_H
#define LAUNCHER_H

#include <QObject>
#include <QProcess>
#include <QDBusInterface>

class Launcher : public QObject
{
    Q_OBJECT

public:
    explicit Launcher(QObject *parent = 0);
    ~Launcher();
    Q_INVOKABLE QString launch(const QString &program);
    Q_INVOKABLE void sendEmail(const QString &toAddress, const QString &ccAddress, const QString &bccAddress, const QString &subject, const QString &body);

protected:
    QProcess *m_process;
};

#endif // LAUNCHER_H
