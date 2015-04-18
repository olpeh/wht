/*
Copyright (c) 2014-2015 kimmoli kimmo.lindholm@gmail.com @likimmo
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "Exporter.h"
#include <QCoreApplication>
#include <QtSql>
#include <QFile>
#include <QLocale>

const QString Exporter::DB_NAME = "";

Exporter::Exporter(QObject *parent) :
    QObject(parent)
{
    /* Open the SQLite database */
    QDir dbdir(QStandardPaths::writableLocation(QStandardPaths::DataLocation));

    if (!dbdir.exists())
    {
        dbdir.mkpath(QStandardPaths::writableLocation(QStandardPaths::DataLocation));
    }
    qDebug() << QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));

    db->setDatabaseName(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/harbour-workinghourstracker/harbour-workinghourstracker/QML/OfflineStorage/Databases/e1e57aa3b56d20de7b090320d566397e.sqlite");

    if (db->open())
    {
        qDebug() << "Open Success";
    }
    else
    {
        qDebug() << "Open error";
        qDebug() << " " << db->lastError().text();
    }
}


QVariantList Exporter::readHours()
{
    QSqlQuery query = QSqlQuery("SELECT * FROM hours;", *db);
    QVariantList tmp;
    QVariantMap map;

    if (query.exec())
    {
        map.clear();
        while (query.next())
        {
            //uid|date|startTime|endTime|duration|project|description|breakDuration

            map.insert("uid", query.record().value("uid").toString());
            map.insert("date", query.record().value("date").toString());
            map.insert("startTime", query.record().value("startTime").toString());
            map.insert("endTime", query.record().value("endTime").toString());
            map.insert("duration", query.record().value("duration").toString());
            map.insert("project", query.record().value("project").toString());
            map.insert("description", query.record().value("description").toString());
            map.insert("breakDuration", query.record().value("breakDuration").toString());
            tmp.append(map);



        }
    }
    else
    {
        qDebug() << "readHours failed " << query.lastError();
    }

    return tmp;
}

QVariantList Exporter::readProjects()
{
    QSqlQuery query = QSqlQuery("SELECT * FROM projects;", *db);
    QVariantList tmp;
    QVariantMap map;

    if (query.exec())
    {
        map.clear();
        while (query.next())
        {
            //id|name|hourlyRate|contractRate|budget|hourBudget|labelColor

            map.insert("id", query.record().value("id").toString());
            map.insert("name", query.record().value("name").toString());
            map.insert("hourlyRate", query.record().value("hourlyRate").toString());
            map.insert("contractRate", query.record().value("contractRate").toString());
            map.insert("budget", query.record().value("budget").toString());
            map.insert("hourBudget", query.record().value("hourBudget").toString());
            map.insert("labelColor", query.record().value("labelColor").toString());
            tmp.append(map);
        }
    }
    else
    {
        qDebug() << "readHours failed " << query.lastError();
    }

    return tmp;
}




/*
 * Export Hours to CSV file
 */
QString Exporter::exportHoursToCSV()
{
    qDebug() << "Exporting hours";

    QLocale loc = QLocale::system(); /* Should return current locale */

    QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';
    qDebug() << "Using" << separator << "as separator";

    QString filename = QString("%1/workinghours.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    qDebug() << "Output filename is" << filename;

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QVariantList hours = readHours();
    QListIterator<QVariant> i(hours);

    while (i.hasNext())
    {
        QVariantMap data = i.next().value<QVariantMap>();
        //uid|date|startTime|endTime|duration|project|description|breakDuration
        out << data["uid"].toString() << separator << data["date"].toString() << separator << data["startTime"].toString() << separator << data["endTime"].toString() << separator << data["duration"].toString() << separator << data["project"].toString() << separator << data["description"].toString() << separator << data["breakDuration"].toString() << "\n";
    }

    out.flush();

    file.close();

    return filename;
}


/*
 * Export Projects to CSV file
 */
QString Exporter::exportProjectsToCSV()
{
    qDebug() << "Exporting projects";

    QLocale loc = QLocale::system(); /* Should return current locale */

    QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';
    qDebug() << "Using" << separator << "as separator";

    QString filename = QString("%1/whtProjects.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    qDebug() << "Output filename is" << filename;

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QVariantList projects = readProjects();
    QListIterator<QVariant> n(projects);

    while (n.hasNext())
    {
        QVariantMap data = n.next().value<QVariantMap>();
        //id|name|hourlyRate|contractRate|budget|hourBudget|labelColor
        out << data["id"].toString() << separator << data["name"].toString() << separator << data["hourlyRate"].toString().replace('.', loc.decimalPoint()) << separator << data["contractRate"].toString().replace('.', loc.decimalPoint()) << separator << data["budget"].toString().replace('.', loc.decimalPoint()) << separator << data["hourBudget"].toString().replace('.', loc.decimalPoint()) << separator << data["labelColor"].toString() << "\n";
    }

    out.flush();

    file.close();

    return filename;
}


Exporter::~Exporter(){}
