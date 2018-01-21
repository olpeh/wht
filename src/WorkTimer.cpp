/*
Copyright (C) 2016 Olavi Haapala.
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

#include "WorkTimer.h"

WorkTimer::WorkTimer(Database* db, QObject *parent) : QObject(parent) {
    this->db = db;
}

WorkTimer::~WorkTimer() {}


QDateTime WorkTimer::start(QDateTime startTime) {
    if (setTimer(startTime, true)) {
        Logger::instance().debug("Timer was saved to database at: " + startTime.toString());
        return startTime;
    }
    // NULL DateTime
    return QDateTime();
}

QDateTime WorkTimer::getStartTime() {
    QSqlQuery query;
    query.prepare("SELECT starttime from timer WHERE started = 1 LIMIT 1");
    if (query.exec() && query.first()) {
        return QDateTime::fromString(query.record().value("starttime").toString());
    }
    else {
        // NULL DateTime
        return QDateTime();
    }
}

qint64 WorkTimer::getDurationInMilliseconds() {
    // TODO: Does this work
    QDateTime dateTimeNow = QDateTime::currentDateTime();
    QDateTime startTime = getStartTime();
    return startTime.msecsTo(dateTimeNow);
}

qint64 WorkTimer::getActualDurationInMilliseconds(BreakTimer* breakTimer) {
    // TODO: Is this even safe?
    return getDurationInMilliseconds() - breakTimer->getTotalDurationInMilliseconds();
}

bool WorkTimer::isRunning() {
    return !getStartTime().isNull();
}

void WorkTimer::stop() {
    QDateTime stopTime = QDateTime::currentDateTime();
    if (setTimer(stopTime, false)) {
        Logger::instance().debug("Timer was stopped at: " + stopTime.toString());
    }
}

bool WorkTimer::setTimer(QDateTime startTime, bool running) {
    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO timer "
                  "VALUES (:uid, :starttime, :started);");

    // TODO: Why did I do it like this earlier?
    // Plz refactor this
    // Why did I comment like that?
    query.bindValue(":uid", 1);
    query.bindValue(":starttime", startTime.toString());
    query.bindValue(":started", running);

    if (query.exec()) {
        if(running) {
           emit startTimeChanged(startTime);
        }
        return true;
    }
    else {
        Logger::instance().error("Insert failed!: " + query.lastError().text() + " in " + query.lastQuery());
        return false;
    }
}


