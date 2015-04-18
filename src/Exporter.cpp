/*
Copyright (c) 2014-2015 kimmoli kimmo.lindholm@gmail.com @likimmo
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "Exporter.h"
#include "Launcher.h"
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

    //QLocale loc = QLocale::system(); /* Should return current locale */
    //QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';
    //qDebug() << "Using" << separator << "as separator";

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
        out << data["uid"].toString() << ',' << data["date"].toString() << ',' << data["startTime"].toString() << ',' << data["endTime"].toString() << ',' << data["duration"].toString().replace(',', '.') << ',' << data["project"].toString() << ',' << data["description"].toString().replace(',', ' ') << ','  << data["breakDuration"].toString().replace(',', '.') << "\n";
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

    //QLocale loc = QLocale::system(); /* Should return current locale */
    //QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';
    //qDebug() << "Using" << separator << "as separator";

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
        out << data["id"].toString() << ',' << data["name"].toString().replace(',', ' ') << ',' << data["hourlyRate"].toString().replace(',', '.') << ',' << data["contractRate"].toString().replace(',',',') << ',' << data["budget"].toString().replace(',', '.') << ',' << data["hourBudget"].toString().replace(',','.') << ',' << data["labelColor"].toString() << "\n";
    }

    out.flush();
    file.close();

    return filename;
}

QString Exporter::exportCategoryToCSV(QString section, QVariantList allHours) {
    qDebug() << "Exporting hours for " << section;

    //QLocale loc = QLocale::system(); /* Should return current locale */
    //QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';
    //qDebug() << "Using" << separator << "as separator";

    QString filename = QString("%1/%2.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation), section);
    qDebug() << "Output filename is" << filename;

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QListIterator<QVariant> n(allHours);

    while (n.hasNext())
    {
        QVariantMap data = n.next().value<QVariantMap>();
        //uid|date|startTime|endTime|duration|project|description|breakDuration
        out << data["uid"].toString() << ',' << data["date"].toString() << ',' << data["startTime"].toString() << ',' << data["endTime"].toString() << ',' << data["duration"].toString().replace(',','.') << ',' << data["project"].toString() << ',' << data["description"].toString().replace(',', ' ') << ',' << data["breakDuration"].toString() << "\n";
    }

    out.flush();
    file.close();

    return filename;
}

QString Exporter::dump() {
    qDebug() << "Dumping the database";

    QString filename = QString("%1/wht.sql").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    qDebug() << "Output filename is" << filename;

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");
    Launcher l;
    QString retval = l.launch("sqlite3 /home/nemo/.local/share/harbour-workinghourstracker/harbour-workinghourstracker/QML/OfflineStorage/Databases/e1e57aa3b56d20de7b090320d566397e.sqlite .dump");
    out << retval;
    file.close();

    if (retval.length() < 1)
        return "Error";
    return filename;
}

QString Exporter::importHoursFromCSV(QString filename) {
    return "Not implemented";
}

QString Exporter::importProjectsFromCSV(QString filename) {
    return "Not implemented";
}

QString Exporter::importDump(QString filename){
    qDebug() << "Trying to import from a dump file";
    qDebug() << "Input filename is" << filename;

    /**
    * @brief executeQueriesFromFile Read each line from a .sql QFile
    * (assumed to not have been opened before this function), and when ; is reached, execute
    * the SQL gathered until then on the query object. Then do this until a COMMIT SQL
    * statement is found. In other words, this function assumes each file is a single
    * SQL transaction, ending with a COMMIT line.
    */

    QFile file(filename);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QSqlQuery query;
    int counter = 0;
    int errors = 0;
    while (!file.atEnd()){
        counter++;
        QByteArray readLine="";
        QString cleanedLine;
        QString line="";
        bool finished=false;
        while(!finished){
            readLine = file.readLine();
            cleanedLine=readLine.trimmed();
            // remove comments at end of line
            //QStringList strings=cleanedLine.split("--");
            //cleanedLine=strings.at(0);

            // remove lines with only comment, and DROP lines
            if(!cleanedLine.startsWith("--") && !cleanedLine.startsWith("DROP")&& !cleanedLine.isEmpty()){
                line+=cleanedLine;
            }
            if(cleanedLine.endsWith(";")){
                break;
            }
            if(cleanedLine.startsWith("COMMIT")){
                finished=true;
            }
        }
        if(!line.isEmpty()){
            query.exec(line);
        }
        if(!query.isActive()){
            errors++;
            qDebug() <<  query.lastError();
            qDebug() << "Last query:"<< query.lastQuery();
        }
    }
    int inserted = counter - errors;
    QString ret = QString("Done with %1 errors. %2 rows inserted.").arg(errors, inserted);
    return ret;
}

Exporter::~Exporter(){}
