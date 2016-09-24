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

#include <QObject>
#include <QtSql>
#include "BreakTimer.h"
#include "Database.h"

BreakTimer::BreakTimer(Database* db, QObject *parent) : QObject(parent) {
    this->db = db;
}

BreakTimer::~BreakTimer() {}

QString BreakTimer::start() {
    QString startTime = QTime::currentTime().toString("hh:mm");

    if (setTimer(startTime, true)) {
        qDebug() << "Breaktimer was saved to database at: " << startTime;
        return startTime;
    }
    return "Error";
}

QString BreakTimer::getStartTime() {
    QSqlQuery query;
    query.prepare("SELECT starttime from breaks WHERE STARTED = 1 ORDER BY id DESC LIMIT 1");
    if (query.exec() && query.first()) {
        return query.record().value("starttime").toString();
    }
    else {
        return "Not started";
    }
}

double BreakTimer::getDuration() {
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
        qDebug() << "Query: " << query.lastQuery() << " failed " << query.lastError();
        return 0;
    }
}

void BreakTimer::stop(double duration) {
    QSqlQuery query;
    query.prepare(QStringLiteral("UPDATE breaks "
                  "SET started = 0, duration = %1 "
                  "WHERE started = 1;").arg(duration));

    if (query.exec()) {
        qDebug() << "BreakTimer was stopped, duration was: " << duration;
    }
    else {
        qDebug() << "Error stopping the breaktimer";
        qDebug() << "Query: " << query.lastQuery() << " failed " << query.lastError();
    }
}

void BreakTimer::clear() {
    QSqlQuery query;
    query.prepare("DELETE FROM breaks");
    query.exec();
}

// Should use some better format for timestamps
// Now uses time in hh:mm format
bool BreakTimer::setTimer(QString timeString, bool running) {
    QSqlQuery query;
    query.prepare("INSERT INTO breaks "
                  "VALUES (NULL, :starttime, :started, :duration);");

    query.bindValue(":starttime", timeString);
    query.bindValue(":started", running);
    query.bindValue(":duration", 0);

    if (query.exec()) {
        return true;
    }
    else {
        qDebug() << "Insert failed! " << query.lastError() << " in " << query.lastQuery();
        return false;
    }
}


