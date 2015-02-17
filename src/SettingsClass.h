#ifndef SETTINGSCLASS_H
#define SETTINGSCLASS_H

#include <QObject>
#include <QVariant>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT

public:
    explicit Settings(QObject *parent = 0);
    ~Settings();
    explicit Settings(const Settings &settings);
    Q_INVOKABLE double getDefaultDuration();
    Q_INVOKABLE void setDefaultDuration(double value);
    Q_INVOKABLE double getDefaultBreakDuration();
    Q_INVOKABLE void setDefaultBreakDuration(double value);

    Q_INVOKABLE QString getEndsNowByDefault();
    Q_INVOKABLE void setEndsNowByDefault(QString value);

    Q_INVOKABLE QString getEndTimeStaysFixed();
    Q_INVOKABLE void setEndTimeStaysFixed(QString value);

    Q_INVOKABLE bool getTimerAutoStart();
    Q_INVOKABLE void setTimerAutoStart(bool value);

    Q_INVOKABLE QString getDefaultProjecId();
    Q_INVOKABLE bool setDefaultProjecId(QString value);

private:
    QString defaultProject;
    double defaultDuration;
    double defaultBreakDuration;
    QString endsNowByDefault;
    QString endTimeStaysFixed;
    bool timerAutoStart;
    QString defaultProjectId;
};
#endif // SETTINGSCLASS_H
