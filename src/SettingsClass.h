/*
Copyright (C) 2015 Olavi Haapala.
<harbourwht@gmail.com>
Twitter: @0lpeh
IRC: olpe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of wht nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef SETTINGSCLASS_H
#define SETTINGSCLASS_H

#include <QObject>
#include <QVariant>
#include <QSettings>

class Settings : public QObject {
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

        Q_INVOKABLE bool getDefaultBreakInTimer();
        Q_INVOKABLE void setDefaultBreakInTimer(bool value);

        Q_INVOKABLE QString getDefaultProjectId();
        Q_INVOKABLE void setDefaultProjectId(QString value);

        Q_INVOKABLE QString getCurrencyString();
        Q_INVOKABLE void setCurrencyString(QString value);

        Q_INVOKABLE QString getToAddress();
        Q_INVOKABLE void setToAddress(QString value);
        Q_INVOKABLE QString getCcAddress();
        Q_INVOKABLE void setCcAddress(QString value);
        Q_INVOKABLE QString getBccAddress();
        Q_INVOKABLE void setBccAddress(QString value);

        Q_INVOKABLE QString getLastVersionUsed();
        Q_INVOKABLE void setLastVersionUsed(QString value);

        Q_INVOKABLE int getRoundToNearest();
        Q_INVOKABLE void setRoundToNearest(int value);


    private:
        QString defaultProject;
        double defaultDuration;
        double defaultBreakDuration;
        QString endsNowByDefault;
        QString endTimeStaysFixed;
        bool timerAutoStart;
        bool defaultBreakInTimer;
        QString defaultProjectId;
        QString currencyString;
        QString toAddress;
        QString ccAddress;
        QString bccAddress;
        QString lastVersionUsed;
        int roundToNearest;
};

#endif // SETTINGSCLASS_H
