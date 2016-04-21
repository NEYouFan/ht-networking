DROP TABLE IF EXISTS TBL_HT_CACHE_PROFILE;
CREATE TABLE TBL_HT_CACHE_PROFILE (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    propertyname varchar(40),
    propertyvalue varchar(300)
);

INSERT INTO TBL_HT_CACHE_PROFILE (propertyname, propertyvalue)
SELECT 'db_version', '1010000';

DROP TABLE IF EXISTS TBL_HT_CACHE_RESPONSE;
CREATE TABLE TBL_HT_CACHE_RESPONSE (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    requestkey varchar(36,0),
    response blob,
    version INTEGER DEFAULT 0,
    createdate INTEGER DEFAULT 0,
    expiredate INTEGER DEFAULT 0,
    UNIQUE(requestkey)
);