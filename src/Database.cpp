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


#include "Database.h"
#include <QCoreApplication>
#include <QLocale>
#include <QObject>
#include <QtSql>
#include <QFile>

const QString Database::DB_NAME = "";

Database::Database(QObject *parent) : QObject(parent) {
    /* Open the SQLite database */
    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    QString data (QStandardPaths::writableLocation(QStandardPaths::DataLocation));
    qDebug() << data;

    if (data.length() && !data.endsWith("share")) {
        data = data.split("/mdeclarativecache_pre_initialized_qapplication").at(0);
        qDebug() << data;
    }
    else if (data.length() && data.endsWith("/harbour-workinghourstracker/harbour-workinghourstracker")) {
        data = data.split("/harbour-workinghourstracker/harbour-workinghourstracker").at(0);
        qDebug() << data;
    }

    db->setDatabaseName(data + "/harbour-workinghourstracker/harbour-workinghourstracker/QML/OfflineStorage/Databases/e1e57aa3b56d20de7b090320d566397e.sqlite");

    if (db->open()) {
        qDebug() << "Database OK";
    }
    else {
        qCritical() << "Open error" << " " << db->lastError().text();
    }
}

void Database::queryBuilder(QSqlQuery* query, QString select, QString from, QString where = "") {
    if(where != "") {
        where = " AND " + where;
    }
    *query = QSqlQuery("SELECT " + select + " "
                       "FROM " + from + " "
                       "WHERE 1=1" + where + ";",*db);
}

bool Database::hasDuration(QSqlQuery* query) {
    if(query->first() && !query->value(0).isNull()) {
        return true;
    }
    else {
       qDebug() << "No results for query: " << query->lastQuery();
       return false;
    }
}

QVariant Database::getDurationForPeriod(QString period, int offset) {
    QString select = QString("sum(duration - breakDuration)");
    QString from = QString("hours");
    QString where = "";
    QString off;
    off.setNum(offset);

    if (period == "day") {
        where = QStringLiteral("date = strftime('%Y-%m-%d', 'now', '-%1 days', 'localtime')").arg(off);
    }
    else if (period == "week") {
        QString startOffset, endOffset;
        startOffset.setNum((offset + 1) * 7 - 1);
        endOffset.setNum(offset * 7);
        qDebug() << startOffset << "  " <<endOffset;
        where = QStringLiteral("date BETWEEN strftime('%Y-%m-%d', 'now', 'weekday 0', '-%1 days', 'localtime') "
                               "AND strftime('%Y-%m-%d', 'now', 'weekday 0', '-%2 days', 'localtime')").arg(startOffset, endOffset);
    }
    else if (period == "month") {
        where = QStringLiteral("date BETWEEN strftime('%Y-%m-%d', 'now', 'start of month', '-%1 month', 'localtime') "
                               "AND strftime('%Y-%m-%d', 'now', 'start of month', '-%1 month', '+1 month', '-1 day', 'localtime')").arg(off);
    }
    else if (period == "year") {
        where = QStringLiteral("date BETWEEN strftime('%Y-%m-%d', 'now', 'start of year', '-%1 years', 'localtime') "
                               "AND strftime('%Y-%m-%d', 'now', 'start of year', '-%1 years', '+1 years', '-1 day', 'localtime')").arg(off);
    }
    else if (period != "all") {
        qDebug() << "Invalid period given as a parameter for getDurationForPeriod!";
        return 0;
    }

    QSqlQuery query;
    queryBuilder(&query, select, from, where);
    if(query.exec()) {
        if(hasDuration(&query)) {
            return query.value(0);
        }
    }
    else {
       qDebug() << "Query: " << query.lastQuery() << " failed " << query.lastError();
    }
    return 0;
}

Database::~Database(){}
