/*
Copyright (c) 2014-2015 kimmoli kimmo.lindholm@gmail.com @likimmo
Copyright (C) 2017 Olavi Haapala ojhaapala@gmail.com  Twitter: @0lpeh
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "Exporter.h"
#include "Launcher.h"
#include "Database.h"
#include <QCoreApplication>
#include <QtSql>
#include <QFile>
#include <QLocale>

Exporter::Exporter(QObject *parent) : QObject(parent) {}

/*
 * Export Hours to CSV file
 */
QString Exporter::exportHoursToCSV(Database* db) {
    Logger::instance().debug("Trying to export hours to CSV");

    //QLocale loc = QLocale::system(); /* Should return current locale */
    //QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';

    QString filename = QString("%1/workinghours.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    Logger::instance().debug("Output filename is " + filename);

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QVariantList hours = db->getHoursForPeriod("all");
    QListIterator<QVariant> i(hours);

    while (i.hasNext()) {
        QVariantMap data = i.next().value<QVariantMap>();
        //uid|date|startTime|endTime|duration|project|description|breakDuration|taskId
        out << "'" << data["uid"].toString() << "'" << ',' << "'" << data["date"].toString() << "'" << ',' << "'" << data["startTime"].toString() << "'" << ',' << "'" << data["endTime"].toString() << "'" << ',' << data["duration"].toString().replace(',', '.') << ',' << "'" << data["project"].toString() << "'" << ',' << "'" << data["description"].toString().replace(',', ' ') << "'" << ','  << data["breakDuration"].toString().replace(',', '.') << ',' << "'" << data["taskId"].toString() << "'" << "\n";
    }

    out.flush();
    file.close();

    return filename;
}


/*
 * Export Projects to CSV file
 */
QString Exporter::exportProjectsToCSV(Database* db) {
    Logger::instance().debug("Trying to export projects to CSV");

    //QLocale loc = QLocale::system(); /* Should return current locale */
    //QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';

    QString filename = QString("%1/whtProjects.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    Logger::instance().debug("Output filename is " + filename);

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QVariantList projects = db->getProjects();
    QListIterator<QVariant> n(projects);

    while (n.hasNext()) {
        QVariantMap data = n.next().value<QVariantMap>();
        //id|name|hourlyRate|contractRate|budget|hourBudget|labelColor
        out << "'" << data["id"].toString() << "'" << ',' << "'" << data["name"].toString().replace(',', ' ') << "'" << ',' << data["hourlyRate"].toString().replace(',', '.') << ',' << data["contractRate"].toString().replace(',',',') << ',' << data["budget"].toString().replace(',', '.') << ',' << data["hourBudget"].toString().replace(',','.') << ',' << "'" << data["labelColor"].toString() << "'" << "\n";
    }

    out.flush();
    file.close();

    return filename;
}

QString Exporter::exportCategoryToCSV(QString section, QVariantList allHours) {
    Logger::instance().debug("Trying to export hours for " + section);

    //QLocale loc = QLocale::system(); /* Should return current locale */
    //QChar separator = (loc.decimalPoint() == '.') ? ',' : ';';

    QString filename = QString("%1/%2.csv").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)).arg(section);
    Logger::instance().debug("Output filename is " + filename);

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");

    QListIterator<QVariant> n(allHours);

    while (n.hasNext()) {
        QVariantMap data = n.next().value<QVariantMap>();
        //uid|date|startTime|endTime|duration|project|description|breakDuration|taskId
        out << "'" << data["uid"].toString() << "'" << ',' << "'" << data["date"].toString() << "'" << ',' << "'" << data["startTime"].toString() << "'" << ',' << "'" << data["endTime"].toString() << "'" << ',' << data["duration"].toString().replace(',','.') << ',' << "'" << data["project"].toString() << "'" << ',' << "'" << data["description"].toString().replace(',', ' ') << "'" << ',' << "'" << data["breakDuration"].toString() << ',' << "'" << data["taskId"].toString() << "'" << "\n";
    }

    out.flush();
    file.close();

    return filename;
}

QString Exporter::dump() {
    Logger::instance().debug("Trying to dumb the database to a file");

    QString filename = QString("%1/wht.sql").arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    Logger::instance().debug("Output filename is " + filename);

    QFile file(filename);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out.setCodec("ISO-8859-1");
    Launcher l;
    QString command = "sqlite3 " + Database::DB_NAME + " .dump";
    Logger::instance().debug("Going to run command: " + command);
    QString retval = l.launch(command);
    Logger::instance().debug("Done. Return value was: " + retval);
    out << retval;
    file.close();

    if (retval.length() < 1) {
        return "Error";
    }
    else {
        return filename;
    }
}

QString Exporter::importHoursFromCSV(QString filename) {
    return "Not implemented";
}

QString Exporter::importProjectsFromCSV(QString filename) {
    return "Not implemented";
}

QString Exporter::importDump(QString filename) {
    Logger::instance().debug("Trying to import from a dump file: " + filename);

    /**
    * Read each line from a .sql QFile and when ; is reached, execute
    * the SQL gathered until then on the query object. Then do this until a COMMIT SQL
    * statement is found. In other words, this function assumes each file is a single
    * SQL transaction, ending with a COMMIT line.
    */

    QFile file(filename);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QSqlQuery query;
        int counter = 0;
        int errors = 0;
        int success = 0;

        while (!file.atEnd()) {
            QByteArray readLine="";
            QString cleanedLine;
            QString line="";
            bool finished=false;

            while (!finished) {
                readLine = file.readLine();
                cleanedLine=readLine.trimmed();
                // remove comments at end of line
                //QStringList strings=cleanedLine.split("--");
                //cleanedLine=strings.at(0);

                // remove lines with only comment, and DROP lines
                if (!cleanedLine.startsWith("--") && !cleanedLine.startsWith("DROP")&& !cleanedLine.isEmpty()){
                    line+=cleanedLine;
                }

                if (cleanedLine.endsWith(";")) {
                    break;
                }

                if (cleanedLine.startsWith("COMMIT")) {
                    finished=true;
                }
            }

            if (!line.isEmpty()) {
                if (!line.startsWith("COMMIT") && !line.startsWith("PRAGMA") && !line.startsWith("BEGIN") && !line.startsWith("CREATE TABLE")) {
                    counter++;
                }

                // Change to INSERT OR REPLACE
                if (line.startsWith("INSERT")) {
                    line.replace(QString("INSERT"), QString("INSERT OR REPLACE"));
                }

                // Change to CREATE TABLE IF NOT EXISTS
                if (line.startsWith("CREATE TABLE")) {
                    line.replace(QString("CREATE TABLE"), QString("CREATE TABLE IF NOT EXISTS"));
                }

                if (query.exec(line)) {
                    Logger::instance().debug("Successful line: " + line);
                    success++;
                }
                else {
                    if (!line.startsWith("COMMIT") && !line.startsWith("PRAGMA") && !line.startsWith("BEGIN") && !line.startsWith("CREATE TABLE")) {
                        errors++;
                    }
                    Logger::instance().error("Error in importDump: " + query.lastError().text() + " in " + query.lastQuery());
                }
            }
        }

        if (errors) {
            return QString("Done: %1 rows inserted or updated \n%2 errors occured.").arg(success).arg(errors);
        }
        else {
            return QString("Done: %1 rows inserted or updated").arg(success);
        }

    }

    return "Error opening the file!";
}

Exporter::~Exporter(){}
