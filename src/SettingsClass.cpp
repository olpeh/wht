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

#include "SettingsClass.h"
#include <QSettings>
#include <QDebug>
#include <QGuiApplication>
#include <QCoreApplication>


Settings::Settings(QObject *parent)
    : QObject(parent)
{
}

Settings::Settings(const Settings &settings)
    : QObject(0)
{
    Q_UNUSED(settings)
}
Settings::~Settings()
{
}

void Settings::setDefaultDuration(double value)
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   s.setValue("defaultDuration", value);
   s.endGroup();
}

double Settings::getDefaultDuration()
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   defaultDuration = s.value("defaultDuration", -1).toDouble();
   s.endGroup();
   return defaultDuration;
}
void Settings::setDefaultBreakDuration(double value)
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   s.setValue("defaultBreakDuration", value);
   s.endGroup();
}

double Settings::getDefaultBreakDuration()
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   defaultBreakDuration = s.value("defaultBreakDuration", -1).toDouble();
   s.endGroup();
   return defaultBreakDuration;
}

void Settings::setEndsNowByDefault(QString value)
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   s.setValue("endsNowByDefault", value);
   s.endGroup();
}

QString Settings::getEndsNowByDefault()
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   endsNowByDefault= s.value("endsNowByDefault", "error").toString();
   s.endGroup();
   return endsNowByDefault;
}

void Settings::setEndTimeStaysFixed(QString value)
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   s.setValue("endTimeStaysFixed", value);
   s.endGroup();
}

QString Settings::getEndTimeStaysFixed()
{
   QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
   s.beginGroup("Settings");
   endTimeStaysFixed = s.value("endTimeStaysFixed", "error").toString();
   s.endGroup();
   return endTimeStaysFixed;
}

bool Settings::getTimerAutoStart()
{
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    timerAutoStart= s.value("timerAutoStart").toBool();
    s.endGroup();
    return timerAutoStart;
}

void Settings::setTimerAutoStart(bool value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("timerAutoStart", value);
    s.endGroup();
}

bool Settings::getDefaultBreakInTimer()
{
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    defaultBreakInTimer = s.value("defaultBreakInTimer", true).toBool();
    s.endGroup();
    return defaultBreakInTimer;
}

void Settings::setDefaultBreakInTimer(bool value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("defaultBreakInTimer", value);
    s.endGroup();
}

QString Settings::getDefaultProjectId() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    defaultProjectId= s.value("defaultProjectId").toString();
    s.endGroup();
    return defaultProjectId;
}

void Settings::setDefaultProjectId(QString value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("defaultProjectId", value);
    s.endGroup();
}

QString Settings::getCurrencyString() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    currencyString= s.value("currencyString").toString();
    s.endGroup();
    return currencyString;
}

void Settings::setCurrencyString(QString value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("currencyString", value);
    s.endGroup();
}

QString Settings::getToAddress() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    toAddress = s.value("toAddress","").toString();
    s.endGroup();
    return toAddress;
}

void Settings::setToAddress(QString value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("toAddress", value);
    s.endGroup();
}

QString Settings::getCcAddress() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    ccAddress = s.value("ccAddress","").toString();
    s.endGroup();
    return ccAddress;
}

void Settings::setCcAddress(QString value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("ccAddress", value);
    s.endGroup();
}
QString Settings::getBccAddress() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    bccAddress = s.value("bccAddress","").toString();
    s.endGroup();
    return bccAddress;
}

void Settings::setBccAddress(QString value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("bccAddress", value);
    s.endGroup();
}

QString Settings::getLastVersionUsed() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    lastVersionUsed = s.value("lastVersionUsed", "").toString();
    s.endGroup();
    return lastVersionUsed;
}

void Settings::setLastVersionUsed(QString value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("lastVersionUsed", value);
    s.endGroup();
}

int Settings::getRoundToNearest() {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    roundToNearest = s.value("roundToNearest", 0).toInt();
    s.endGroup();
    return roundToNearest;
}

void Settings::setRoundToNearest(int value) {
    QSettings s("harbour-workinghourstracker", "harbour-workinghourstracker");
    s.beginGroup("Settings");
    s.setValue("roundToNearest", value);
    s.endGroup();
}
