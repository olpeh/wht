/*
Copyright (C) 2016 Olavi Haapala.
<harbourwht@gmail.com>
Twitter: @0lpeh
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

#include "BreakTimer.h"
#include "Database.h"

BreakTimer::BreakTimer(Database* db, QObject *parent) : QObject(parent) {
    this->db = db;
}

BreakTimer::~BreakTimer() {}

QDateTime BreakTimer::start() {
    QDateTime startTime  = QDateTime::currentDateTime();

    if (setTimer(startTime, true)) {
        Logger::instance().debug("Breaktimer was saved to database at: " + startTime.toString());
        return startTime;
    }
    return QDateTime();
}

QDateTime BreakTimer::getStartTime() {
    QSqlQuery query;
    query.prepare("SELECT starttime from breaks WHERE STARTED = 1 ORDER BY id DESC LIMIT 1");
    if (query.exec() && query.first()) {
        return QDateTime::fromString(query.record().value("starttime").toString());
    }
    return QDateTime();
}

qint64 BreakTimer::getDurationInMilliseconds() {
    QDateTime dateTimeNow = QDateTime::currentDateTime();
    QDateTime startTime = getStartTime();
    return startTime.msecsTo(dateTimeNow);
}

qint64 BreakTimer::getTotalDurationInMilliseconds() {
    QSqlQuery query;
    query.prepare("SELECT sum(duration) FROM breaks;");
    if(query.exec()) {
        if(query.first() && !query.value(0).isNull()) {
            return query.value(0).toDouble();
        }
        else {
            return 0;
        }
    }
    else {
        Logger::instance().error("Query: " + query.lastQuery() + " failed " + query.lastError().text());
        return 0;
    }
}

bool BreakTimer::isRunning() {
    return !getStartTime().isNull();
}

void BreakTimer::stop() {
    qint64 duration = getDurationInMilliseconds();
    QSqlQuery query;
    query.prepare(QStringLiteral("UPDATE breaks "
                  "SET started = 0, duration = %1 "
                  "WHERE started = 1;").arg(duration));

    if (query.exec()) {
        Logger::instance().debug("BreakTimer was stopped, break duration was: " + QString::number(duration) + " ms");
    }
    else {
        Logger::instance().error("Error stopping the breaktimer: Query: " + query.lastQuery() + " failed " + query.lastError().text());
    }
}

void BreakTimer::clear() {
    QSqlQuery query;
    query.prepare("DELETE FROM breaks");
    query.exec();
}


bool BreakTimer::setTimer(QDateTime startTime, bool running) {
    QSqlQuery query;
    query.prepare("INSERT INTO breaks "
                  "VALUES (NULL, :starttime, :started, :duration);");

    query.bindValue(":starttime", startTime.toString());
    query.bindValue(":started", running);
    query.bindValue(":duration", 0);

    if (query.exec()) {
        return true;
    }
    else {
        Logger::instance().error("Insert failed!: " + query.lastError().text() + " in " + query.lastQuery());
        return false;
    }
}


