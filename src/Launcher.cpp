#include "Launcher.h"

Launcher::Launcher(QObject *parent) :
    QObject(parent),
    m_process(new QProcess(this))
{

}

QString Launcher::launch(const QString &program)
{
    m_process->start(program);
    m_process->waitForFinished(-1);
    QByteArray bytes = m_process->readAllStandardOutput();
    QString output = QString::fromLocal8Bit(bytes);
    return output;
}

void Launcher::sendEmail(const QString &toAddress, const QString &ccAddress, const QString &bccAddress, const QString &subject, const QString &body) {
    QDBusInterface email("com.jolla.email.ui", "/com/jolla/email/ui", "com.jolla.email.ui");
    email.call("compose", subject, toAddress, ccAddress, bccAddress, body);
}


Launcher::~Launcher() {}
