/*
Copyright (C) 2015 Olavi Haapala ojhaapala@gmail.com  Twitter: @olpetik
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#ifndef EXPORTER_H
#define EXPORTER_H
#include <QObject>
#include <QtSql>


class Exporter : public QObject
{
    Q_OBJECT

public:
    explicit Exporter(QObject *parent = 0);
    ~Exporter();

    Q_INVOKABLE QString exportHoursToCSV();
    Q_INVOKABLE QString exportProjectsToCSV();
    Q_INVOKABLE QString exportCategoryToCSV(QString section, QVariantList allHours);
    Q_INVOKABLE QString dump();
    Q_INVOKABLE QVariantList readHours();
    Q_INVOKABLE QVariantList readProjects();
    Q_INVOKABLE QString importHoursFromCSV(QString filename);
    Q_INVOKABLE QString importProjectsFromCSV(QString filename);
    Q_INVOKABLE QString importDump(QString filename);


    static const QString DB_NAME;

private:
    QSqlDatabase* db;
};


#endif // EXPORTER_H
