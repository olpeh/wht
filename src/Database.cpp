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

QString Database::DB_NAME = "";

Database::Database(QObject *parent) : QObject(parent)
{
    /* Open the SQLite database */
    Logger::instance().debug("Trying to open the SQLite database");
    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    QString dbName = "e1e57aa3b56d20de7b090320d566397e.sqlite";

    // Support legacy versions where the db might be in a weird folder
    QString appName = "harbour-workinghourstracker";
    QString data = QStandardPaths::writableLocation(QStandardPaths::DataLocation);

    //  Legacy hack
    if (data.length() && !data.endsWith("share"))
    {
        data = data.split("/mdeclarativecache_pre_initialized_qapplication").at(0);
        Logger::instance().debug("Data path was splitted to: " + data);
    }
    else if (data.length() && data.endsWith("/harbour-workinghourstracker/harbour-workinghourstracker"))
    {
        data = data.split("/harbour-workinghourstracker/harbour-workinghourstracker").at(0);
        Logger::instance().debug("Extra app name was removed. Datapath now: " + data);
    }

    QString legacyDbPath = data + "/" + appName + "/" + appName + "/QML/OfflineStorage/Databases/";
    Logger::instance().debug("Checking if legacyDB exists in path: " + legacyDbPath);
    if (fileExists(legacyDbPath + dbName))
    {
        Logger::instance().debug("Legacy db exists -> let's try to use it");
        DB_NAME = legacyDbPath + dbName;
    }
    else
    {
        Logger::instance().debug("Legacy does not exist. Using standard db location");
        if (!QDir(data + "/" + appName).exists())
        {
            Logger::instance().debug(data + "/" + appName + " was not existing yet. Trying to create it.");
            QDir().mkdir(data + "/" + appName);
        }
        DB_NAME = data + "/" + appName + "/" + dbName;
    }

    db->setDatabaseName(DB_NAME);
    Logger::instance().debug("DB name is now: " + DB_NAME);

    // If open - initilialize the tables
    if (db->open() && init())
    {
        Logger::instance().info("Database OK");
    }
    else
    {
        Logger::instance().error("Error opening the DB: " + db->lastError().text());
    }
}

bool Database::fileExists(QString path)
{
    QFileInfo check_file(path);
    // check if file exists and if yes: Is it really a file and no directory?
    return check_file.exists() && check_file.isFile();
}

bool Database::init()
{
    // Let's try to support older versions too
    upgradeIfNeeded();
    return createTables();
}

void Database::upgradeIfNeeded()
{
    bool success = QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.exec("PRAGMA user_version");
    // 1 -> 2 Add breakDuration if missing
    if (query.first() && !query.value(0).isNull())
    {
        QVariant version = query.value(0);
        if (version < 3)
        {
            query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='hours';");
            if (query.first() && query.value(0) == "hours")
            {
                if (version < 2)
                {
                    query.exec("ALTER TABLE hours ADD breakDuration REAL DEFAULT 0;");
                    Logger::instance().debug("Updating table hours to user_version 2. Adding breakDuration column.");
                }
                query.exec("ALTER TABLE hours ADD taskId TEXT;");
                Logger::instance().debug("Updating table hours to user_version 3. Adding tadkId column.");

                query.exec("PRAGMA user_version = 3;");
            }
            else
            {
                Logger::instance().debug("No table named hours - " + query.lastError().text());
            }
        }
    }
    QSqlDatabase::database().commit();
    if (success)
    {
        Logger::instance().debug("Database schema version is currently 3");
    }
    else
    {
        Logger::instance().error("Error upgrading tables!: " + query.lastError().text());
    }
}

bool Database::createTables()
{
    bool success = QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS hours(uid LONGVARCHAR UNIQUE, date TEXT, startTime TEXT, endTime TEXT, duration REAL,project TEXT, description TEXT,breakDuration REAL DEFAULT 0, taskId TEXT);");
    query.exec("CREATE TABLE IF NOT EXISTS timer(uid INTEGER UNIQUE,starttime TEXT, started INTEGER);");
    query.exec("CREATE TABLE IF NOT EXISTS breaks(id INTEGER PRIMARY KEY,starttime TEXT, started INTEGER, duration REAL DEFAULT -1);");
    query.exec("CREATE TABLE IF NOT EXISTS projects(id LONGVARCHAR UNIQUE, name TEXT, hourlyRate REAL DEFAULT 0, contractRate REAL DEFAULT 0, budget REAL DEFAULT 0, hourBudget REAL DEFAULT 0, labelColor TEXT);");
    query.exec("CREATE TABLE IF NOT EXISTS tasks(id LONGVARCHAR UNIQUE, projectId REFERENCES projects(id), name TEXT);");
    query.exec("PRAGMA user_version=3;");
    QSqlDatabase::database().commit();

    if (!success)
    {
        Logger::instance().error("Error creating tables!");
    }
    return success;
}

QUuid Database::getUniqueId()
{
    return QUuid::createUuid();
}

bool Database::saveHourRow(QVariantMap values)
{
    if (!values.empty())
    {
        QSqlQuery query;
        query.prepare("INSERT OR REPLACE INTO hours "
                      "VALUES (:uid, :date, :startTime, :endTime, :duration, :project, "
                      ":description, :breakDuration, :taskId);");

        query.bindValue(":uid", values["uid"].isNull() ? getUniqueId() : values["uid"].toString());
        query.bindValue(":date", values["date"].toString());
        query.bindValue(":startTime", values["startTime"].toString());
        query.bindValue(":endTime", values["endTime"].toString());
        query.bindValue(":duration", values["duration"].toString());
        query.bindValue(":project", values["project"].toString());
        query.bindValue(":description", values["description"].toString());
        query.bindValue(":breakDuration", values["breakDuration"].toString());
        query.bindValue(":taskId", values["taskId"].toString());

        if (query.exec())
        {
            Logger::instance().debug("Row saved! ID: " + values["uid"].toString());
            return true;
        }
        else
        {
            Logger::instance().error("Insert failed!: " + query.lastError().text() + " in " + query.lastQuery());
            return false;
        }
    }
    else
    {
        Logger::instance().warn("Values empty in saveHourRow");
        return false;
    }
}

void Database::queryBuilder(QSqlQuery *query, QString select, QString from, QList<QString> where, QList<QString> sorting, int limit)
{
    QListIterator<QString> i(where);
    QString w = "1=1";
    QString limitString = "";

    while (i.hasNext())
    {
        w += " AND " + i.next();
    }

    QListIterator<QString> s(sorting);
    QString sort;
    while (s.hasNext())
    {
        if (!s.hasPrevious())
        {
            sort = " ORDER BY";
        }

        sort += " " + s.next();

        if (s.hasNext())
        {
            sort += ",";
        }
    }

    if (limit)
    {
        limitString = QStringLiteral(" LIMIT %1").arg(limit);
    }

    *query = QSqlQuery("SELECT " + select + " FROM " + from + " WHERE " + w + sort + limitString + ";", *db);
}

bool Database::periodQueryBuilder(QSqlQuery *query, QString select, QString period, int timeOffset, QList<QString> sorting, QString projectId)
{
    QString from = QString("hours");
    QList<QString> where;
    QString off;
    off.setNum(timeOffset);

    if (period == "day")
    {
        where.append(QStringLiteral("date = strftime('%Y-%m-%d', 'now', '-%1 days', 'localtime')").arg(off));
    }
    else if (period == "week")
    {
        QString startOffset, endOffset;
        startOffset.setNum((timeOffset + 1) * 7 - 1);
        endOffset.setNum(timeOffset * 7);
        where.append(QStringLiteral("date BETWEEN strftime('%Y-%m-%d', 'now', 'weekday 0', '-%1 days', 'localtime')").arg(startOffset));
        where.append(QStringLiteral("strftime('%Y-%m-%d', 'now', 'weekday 0', '-%2 days', 'localtime')").arg(endOffset));
    }
    else if (period == "month")
    {
        where.append(QStringLiteral("date BETWEEN strftime('%Y-%m-%d', 'now', 'start of month', '-%1 month', 'localtime')").arg(off));
        where.append(QStringLiteral("strftime('%Y-%m-%d', 'now', 'start of month', '-%1 month', '+1 month', '-1 day', 'localtime')").arg(off));
    }
    else if (period == "year")
    {
        where.append(QStringLiteral("date BETWEEN strftime('%Y-%m-%d', 'now', 'start of year', '-%1 years', 'localtime')").arg(off));
        where.append(QStringLiteral("strftime('%Y-%m-%d', 'now', 'start of year', '-%1 years', '+1 years', '-1 day', 'localtime')").arg(off));
    }
    else if (period != "all")
    {
        Logger::instance().warn("Invalid period given as a parameter for getDurationForPeriod!");
        return false;
    }

    // Default sorting for hours
    if (sorting.empty())
    {
        sorting.append("date DESC");
        sorting.append("startTime DESC");
    }

    // Filter by projectId
    if (projectId != NULL)
    {
        where.append(QStringLiteral("project = '%1'").arg(projectId));
    }

    // Make the actual query string
    queryBuilder(query, select, from, where, sorting);
    return true;
}

double Database::getDurationForPeriod(QString period, int timeOffset, QString projectId)
{
    QString select = QString("sum(duration - breakDuration)");
    QList<QString> sorting;
    QSqlQuery query;
    if (periodQueryBuilder(&query, select, period, timeOffset, sorting, projectId))
    {
        if (query.exec())
        {
            if (query.first() && !query.value(0).isNull())
            {
                return query.value(0).toDouble();
            }
        }
        else
        {
            Logger::instance().error("Query: " + query.lastQuery() + " failed " + query.lastError().text());
        }
    }
    else
    {
        Logger::instance().warn("periodQueryBuilder failed for unknown reason!");
    }
    return 0;
}

QVariantList Database::getHoursForPeriod(QString period, int timeOffset, QList<QString> sorting, QString projectId)
{
    QString select = QString("uid, date, startTime, endTime, duration, project, description, breakDuration, taskId");
    QSqlQuery query;
    QVariantList tmp;
    QVariantMap map;
    if (periodQueryBuilder(&query, select, period, timeOffset, sorting, projectId))
    {
        if (query.exec())
        {
            map.clear();
            while (query.next())
            {
                map.insert("uid", query.record().value("uid").toString());
                map.insert("date", query.record().value("date").toString());
                map.insert("startTime", query.record().value("startTime").toString());
                map.insert("endTime", query.record().value("endTime").toString());
                map.insert("duration", query.record().value("duration").toString());
                map.insert("project", query.record().value("project").toString());
                map.insert("description", query.record().value("description").toString());
                map.insert("breakDuration", query.record().value("breakDuration").toString());
                map.insert("taskId", query.record().value("taskId").toString());
                tmp.append(map);
            }
        }
        else
        {
            Logger::instance().error("getHoursForPeriod failed " + query.lastError().text());
        }
    }
    else
    {
        Logger::instance().warn("periodQueryBuilder failed for unkown reason!");
    }
    return tmp;
}

QVariantMap Database::getLastUsedInput(QString projectID, QString taskID)
{
    QString select = QString("project, taskId, description");
    QString from = QString("hours");
    QList<QString> where;
    QList<QString> sorting;
    int limit = 1;
    QSqlQuery query;
    QVariantMap result;

    sorting.append("strftime('%Y-%m-%d', date) DESC");

    if (!projectID.isEmpty())
    {
        where.append(QStringLiteral("project='%1'").arg(projectID));
    }

    if (!taskID.isEmpty())
    {
        where.append(QStringLiteral("taskID='%1'").arg(taskID));
    }

    queryBuilder(&query, select, from, where, sorting, limit);

    if (query.exec())
    {
        if (query.first())
        {
            result.insert("projectId", query.record().value("project").toString());
            result.insert("taskId", query.record().value("taskId").toString());

            QString descr = query.record().value("description").toString();
            if (descr != "No description")
            {
                result.insert("description", descr);
            }
        }
    }
    else
    {
        Logger::instance().error("Query: " + query.lastQuery() + " failed " + query.lastError().text());
    }

    Logger::instance().debug("Query: " + query.lastQuery());
    Logger::instance().debug(result["projectId"].toString() + " " + result["taskId"].toString() + " " + result["description"].toString());
    return result;
}

QVariantList Database::getProjects()
{
    QVariantList tmp;
    QVariantMap map;
    QString select = QString("id, name, hourlyRate, contractRate, budget, hourBudget, labelColor");
    QString from = QString("projects");
    QSqlQuery query;
    QList<QString> where;
    QList<QString> sorting;
    sorting.append("name ASC");

    queryBuilder(&query, select, from, where, sorting);
    if (query.exec())
    {
        map.clear();
        while (query.next())
        {
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
        Logger::instance().error("getProjects failed " + query.lastError().text());
    }
    return tmp;
}

QString Database::insertInitialProject(QString labelColor)
{
    QVariantMap values;
    values.insert("uid", getUniqueId());
    values.insert("name", "default");
    values.insert("labelColor", labelColor);
    return saveProject(values);
}

QString Database::saveProject(QVariantMap values)
{
    if (!values.empty())
    {
        QString uid = values["uid"].isNull() ? getUniqueId().toString() : values["uid"].toString();
        QSqlQuery query;
        query.prepare("INSERT OR REPLACE INTO projects "
                      "VALUES (:uid, :name, :hourlyRate, :contractRate, :budget,"
                      " :hourBudget, :labelColor);");

        query.bindValue(":uid", uid);
        query.bindValue(":name", values["name"].isNull() ? "default" : values["name"].toString());
        query.bindValue(":hourlyRate", values["hourlyRate"].isNull() ? 0 : values["hourlyRate"]);
        query.bindValue(":contractRate", values["contractRate"].isNull() ? 0 : values["contractRate"]);
        query.bindValue(":budget", values["budget"].isNull() ? 0 : values["budget"]);
        query.bindValue(":hourBudget", values["hourBudget"].isNull() ? 0 : values["hourBudget"]);
        query.bindValue(":labelColor", values["labelColor"].toString());

        if (query.exec())
        {
            Logger::instance().debug("Project saved! ID: " + values["uid"].toString());
            return values["uid"].toString();
        }
        else
        {
            Logger::instance().error("Insert failed!: " + query.lastError().text() + " in " + query.lastQuery());
            return NULL;
        }
    }
    else
    {
        Logger::instance().warn("Values empty in saveProject");
        return NULL;
    }
}

QVariantList Database::getTasks(QString projectID)
{
    QVariantList tmp;
    QVariantMap map;
    QString select = QString("id, name");
    QString from = QString("tasks");
    QList<QString> where;
    QSqlQuery query;

    if (!projectID.isEmpty())
    {
        where.append(QStringLiteral("projectId='%1'").arg(projectID));
    }

    queryBuilder(&query, select, from, where);
    if (query.exec())
    {
        map.clear();
        while (query.next())
        {
            map.insert("id", query.record().value("id").toString());
            map.insert("name", query.record().value("name").toString());
            tmp.append(map);
        }
    }
    else
    {
        Logger::instance().error("getTasks failed: " + query.lastError().text() + " in " + query.lastQuery());
    }

    return tmp;
}

QString Database::saveTask(QVariantMap values)
{
    if (!values.empty())
    {
        QString uid = values["uid"].isNull() ? getUniqueId().toString() : values["uid"].toString();

        QSqlQuery query;
        query.prepare("INSERT OR REPLACE INTO tasks "
                      "VALUES (:uid, :projectId, :name);");

        query.bindValue(":uid", uid);
        query.bindValue(":projectId", values["projectID"]);
        query.bindValue(":name", values["name"].isNull() ? "Default task" : values["name"].toString());

        if (query.exec())
        {
            Logger::instance().debug("Task saved! ID: " + values["uid"].toString());
            return values["uid"].toString();
        }
        else
        {
            Logger::instance().error("Insert failed!: " + query.lastError().text() + " in " + query.lastQuery());
            return NULL;
        }
    }
    else
    {
        Logger::instance().warn("Values empty in saveTask");
        return NULL;
    }
}

bool Database::remove(QString table, QString id)
{
    if (id.isEmpty() || table.isEmpty())
    {
        Logger::instance().warn("No id or table was given for remove! You crazy?");
        return false;
    }

    QSqlQuery query;
    if (table == "hours" || table == "timer")
    {
        query = QSqlQuery("DELETE FROM " + table + " WHERE uid = '" + id + "';", *db);
    }
    else if (table == "breaks" || table == "projects" || table == "tasks")
    {
        query = QSqlQuery("DELETE FROM " + table + " WHERE id = '" + id + "';", *db);
    }
    else
    {
        Logger::instance().warn("Erroneous table: " + table + ". Nothing was removed.");
        return false;
    }

    if (query.exec())
    {
        if (query.size())
        {
            Logger::instance().debug("Deleted row with ID: " + id + " from " + table);
            return true;
        }
        else
        {
            Logger::instance().error("FAILED to delete row with ID: " + id + " from " + table);
            return false;
        }
    }
    Logger::instance().error("Error deleting. " + query.lastError().text() + " in " + query.lastQuery());
    return false;
}

void Database::resetDatabase()
{
    bool success = QSqlDatabase::database().transaction();
    QSqlQuery query;
    query.exec("DROP TABLE hours");
    query.exec("DROP TABLE timer");
    query.exec("DROP TABLE breaks");
    query.exec("DROP TABLE projects");
    query.exec("DROP TABLE tasks");
    QSqlDatabase::database().commit();
    if (success && createTables())
    {
        Logger::instance().info("Database was reset");
    }
    else
    {
        Logger::instance().error("Error resetting database!");
    }
}

Database::~Database() {}
