.import QtQuick.LocalStorage 2.0 as LocalStorage

var _db = null;
var SCHEME_VERSION = "1.0";

// DATABASE GENERAL

function getDatabase() {
    if (_db === null) {
        _db = LocalStorage.LocalStorage.openDatabaseSync("NextAction", "0.1", "data", 10000);
        if (databaseIsUpToDate() === false) {
            dropDatabase();
            _initDatabase();
        }
    }
    return _db;
}

function databaseIsUpToDate()
{
    // Do not use getDatabase
    console.log("Checking if database is set correctly");
    var result = true;
    _db.transaction(function(tx){
       var tables = tx.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name ='settings'");
       if (tables.rows.length === 0) {
           console.log("Can't find 'settings' table. Requesting database init.");
           result = false;
           return;
       }
       var settings = tx.executeSql("SELECT value FROM settings WHERE name = 'scheme_version'");
       if (settings.rows.length === 0) {
           console.log("Can't determine database scheme version. Requesting database init.");
           result = false;
           return;
       }
       if (settings.rows.item(0).value !== SCHEME_VERSION) {
           console.log("Wrong database scheme version. Requesting database init.");
           result = false;
           return;
       }
       console.log("Database scheme version: " + SCHEME_VERSION + ". Proceed without init.");
    });
    return result;
}

function dropDatabase()
{
    console.log("dropDatabase started");
    _db.transaction(function(tx){
        tx.executeSql("DROP TABLE IF EXISTS settings;");
        tx.executeSql("DROP TABLE IF EXISTS contexts;");
        tx.executeSql("DROP TABLE IF EXISTS action_lists;");
        tx.executeSql("DROP TABLE IF EXISTS actions;");
        tx.executeSql("DROP TABLE IF EXISTS action_contexts;");
        tx.executeSql("DROP INDEX IF EXISTS 'actions_83908783';");
        tx.executeSql("DROP INDEX IF EXISTS 'action_contexts_868a749e';");
        tx.executeSql("DROP INDEX IF EXISTS 'action_contexts_e7c54ddc';");
        tx.executeSql("COMMIT;")
    });
    console.log("dropDatabase finished");
}

function _initDatabase() {
    console.log("initDatabase started");

    _db.transaction( function(tx) {
        tx.executeSql("CREATE TABLE settings(\
                           name TEXT NOT NULL PRIMARY KEY,\
                           value TEXT NOT NULL);");
        tx.executeSql("CREATE TABLE contexts(\
                           id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
                           name TEXT NOT NULL UNIQUE,\
                           status INTEGER NOT NULL,\
                           updated INTEGER NOT NULL);");
        tx.executeSql("CREATE TABLE action_lists(\
                           id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
                           name TEXT NOT NULL UNIQUE ,\
                           updated INTEGER NOT NULL);");
        tx.executeSql("CREATE TABLE actions(\
                           id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
                           name TEXT NOT NULL,\
                           list TEXT NOT NULL REFERENCES 'action_lists' ('name'),\
                           status INTEGER NOT NULL,\
                           updated INTEGER NOT NULL,\
                           UNIQUE ('name', 'list'));");
        tx.executeSql("CREATE TABLE action_contexts(\
                           id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\
                           context_id INTEGER NOT NULL REFERENCES 'contexts' ('id'),\
                           action_id INTEGER NOT NULL REFERENCES 'action' ('id'),
                           UNIQUE ('context_id', 'action_id'));");
        tx.executeSql("CREATE INDEX 'actions_83908783' ON 'actions' ('list');");
        tx.executeSql("CREATE INDEX 'action_contexts_868a749e' ON 'action_contexts' ('context_id');");
        tx.executeSql("CREATE INDEX 'action_contexts_e7c54ddc' ON 'action_contexts' ('action_id');");
        tx.executeSql("COMMIT;");
        }
    );
    setSetting('scheme_version', SCHEME_VERSION);
    console.log("initDatabase funished");
}
// UTILS


function getUnixTime() {
    return (new Date()).getTime();
}



// Settings
function getSetting(name)
{
    var db = getDatabase();
    var result;
    db.transaction(function(tx) {
        result = tx.executeSql("SELECT value FROM settings WHERE name = ?", name);
    });
    if (result.rows.length > 0) {
        console.log("Setting " + name + " has value " + result.rows.item(0).value);
        return result.rows.item(0).value;
    }
    else {
        return null;
    }
}

function setSetting(name, value) {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql("INSERT OR REPLACE INTO settings(name, value) VALUES (?, ?);", [name, value]);
        tx.executeSql("COMMIT;");
    });
    console.log("Setting " + name + " is set to " + value);
}

function invalidateSetting(name) {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql("DELETE FROM settings WHERE name = ?;", name);
        tx.executeSql("COMMIT;");
    });
}

// CONTEXTS
function getContexts(callback)
{
    var db = getDatabase();
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM contexts;");
        for (var i = 0; i < result.rows.length; ++i) {
            var context = result.rows.item(i);
            callback(context);
        }
    });
}

function getContext(id, callback)
{
    var db = getDatabase();
    db.transaction(function(tx) {
       var result = tx.executeSql("SELECT * FROM contexts WHERE id = ?", id);
       var context = result.rows.item(0);
       callback(context)
    });
}

function createContext(name) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("INSERT INTO contexts(name, status, updated) VALUES (?, 0, ?);", [name, getUnixTime()]);
        tx.executeSql("COMMIT;")
    });
}

function updateContext(id, name) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("UPDATE contexts SET name = ?, updated = ? WHERE id = ?;", [name, getUnixTime(), id]);
        tx.executeSql("COMMIT;")
    });
}

function markContextAsActive(id) {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql("UPDATE contexts SET status = 1, updated = ? WHERE id = ?;", [getUnixTime(), id]);
        tx.executeSql("COMMIT;")
    });
}

function markContextAsInactive(id) {
   var db = getDatabase();
   db.transaction(function(tx) {
        tx.executeSql("UPDATE contexts SET status = 0, updated = ? WHERE id = ?;", [getUnixTime(), id]);
        tx.executeSql("COMMIT;");
   });

}

function deleteContext(id) {
    var db = getDatabase();
    db.transaction(function(tx) {
         tx.executeSql("DELETE FROM contexts WHERE id = ?;", id);
         tx.executeSql("COMMIT;");
    });
}

// ACTION_LISTS

function getActionLists(callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM action_lists ORDER BY updated DESC;");
        for (var i = 0; i < result.rows.length; ++i) {
            var action_list = result.rows.item(i);
            callback(action_list);
        }
    });
}

function getActionList(id ,callback) {
    var db = getDatabase();
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM action_lists WHERE id = ? ORDER BY updated DESC;", id);
        var action_list = result.rows.item(0);
        callback(action_list);
    });
}

function createActionList(name) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("INSERT INTO action_lists(name, updated) VALUES (?, ?);", [name, getUnixTime()]);
        tx.executeSql("COMMIT;");
    });
}

function updateActionList(id, name) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("UPDATE action_lists SET name = ?, updated = ? WHERE id = ?;", [name, getUnixTime(), id]);
        tx.executeSql("COMMIT;")
    });
}

function deleteActionList(id) {
    var db = getDatabase();
    db.transaction(function(tx) {
         tx.executeSql("DELETE FROM action_lists WHERE id = ?;", id);
         tx.executeSql("COMMIT;");
    });
}

// ACTIONS
function getActions(callback, list, use_contexts) {
    var db = getDatabase();
    db.transaction(function(tx) {
        if (use_contexts) {
            var result = tx.executeSql("SELECT DISTINCT actions.id as id, actions.name as name, actions.status as status, actions.updated as updated\
                                        FROM actions\
                                        LEFT JOIN action_contexts ON actions.id = action_contexts.action_id\
                                        LEFT JOIN contexts ON contexts.id = action_contexts.context_id\
                                        WHERE list = ? AND\
                                              (context_id IS NULL OR contexts.status = 1)\
                                        ORDER BY actions.status, actions.updated DESC;", list);
        }
        else {
            var result = tx.executeSql("SELECT DISTINCT id, name, status, updated\
                                        FROM actions\
                                        WHERE list = ?\
                                        ORDER BY status, updated DESC;", list);
        }
        for (var i = 0; i < result.rows.length; ++i) {
            var action = result.rows.item(i);
            callback(action);
        }
    });
}

function getAction(id, callback)
{
    var db = getDatabase();
    db.transaction(function(tx) {
       var result = tx.executeSql("SELECT * FROM actions WHERE id = ?", id);
       var action = result.rows.item(0);
       callback(action)
    });
}

function createAction(name, list) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("INSERT INTO actions(name, list, status, updated) VALUES (?, ?, 0, ?);", [name, list, getUnixTime()]);
        tx.executeSql("COMMIT;");
    });
}

function updateAction(id, name) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("UPDATE actions SET name = ?, updated = ? WHERE id = ?;", [name, getUnixTime(), id]);
        tx.executeSql("COMMIT;");
    });
}

function markActionAsDone(id) {
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql("UPDATE actions SET status = 1, updated = ? WHERE id = ?;", [getUnixTime(), id]);
        tx.executeSql("COMMIT;")
    });
}

function markActionAsNotDone(id) {
   var db = getDatabase();
   db.transaction(function(tx) {
        tx.executeSql("UPDATE actions SET status = 0, updated = ? WHERE id = ?;", [getUnixTime(), id]);
        tx.executeSql("COMMIT;");
   });
}

function requireContext(action_id, context_id) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("INSERT INTO action_contexts(action_id, context_id) VALUES (?, ?);", [action_id, context_id]);
        tx.executeSql("COMMIT;");
    });
}

function notRequireContext(action_id, context_id) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("DELETE FROM action_contexts WHERE action_id = ?, context_id = ?;", [action_id, context_id]);
        tx.executeSql("COMMIT;");
    });
}

function getRequiredContexts(action_id, callback) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql("SELECT contexts.id as id, contexts.name as name\
                       FROM action_contexts\
                       JOIN contexts ON contexts.id = action_contexts.context_id
                       WHERE action_id = ?;", action_id);
        for (var i = 0; i < result.rows.length; ++i) {
            var context = result.rows.item(i);
            callback(context);
        }
        tx.executeSql("COMMIT;");
    });
}


function deleteAction(id) {
    var db = getDatabase();
    db.transaction(function(tx) {
         tx.executeSql("DELETE FROM actions WHERE id = ?;", id);
         tx.executeSql("COMMIT;");
    });
}

function deleteCompletedActions(list) {

    var db = getDatabase();
    db.transaction(function(tx) {
         tx.executeSql("DELETE FROM actions WHERE status = 1 AND list = ?;", list);
         tx.executeSql("COMMIT;");
    });
}







