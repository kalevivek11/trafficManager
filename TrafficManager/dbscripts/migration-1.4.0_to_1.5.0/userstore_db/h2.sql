CREATE TABLE UM_DOMAIN(
            UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_DOMAIN_NAME VARCHAR(255),
            UM_TENANT_ID INTEGER DEFAULT 0,
            PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)
);

CREATE TABLE UM_SYSTEM_USER ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_USER_NAME VARCHAR(255) NOT NULL, 
             UM_USER_PASSWORD VARCHAR(255) NOT NULL,
             UM_SALT_VALUE VARCHAR(31),
             UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
             UM_CHANGED_TIME TIMESTAMP NOT NULL,
             UM_TENANT_ID INTEGER DEFAULT 0, 
             PRIMARY KEY (UM_ID, UM_TENANT_ID), 
             UNIQUE(UM_USER_NAME, UM_TENANT_ID)
); 

ALTER TABLE UM_ROLE ADD COLUMN UM_SHARED_ROLE BOOLEAN DEFAULT FALSE;

CREATE TABLE UM_MODULE(
	UM_ID INTEGER  NOT NULL AUTO_INCREMENT,
	UM_MODULE_NAME VARCHAR(100),
	UNIQUE(UM_MODULE_NAME),
	PRIMARY KEY(UM_ID)
);

CREATE TABLE UM_MODULE_ACTIONS(
	UM_ACTION VARCHAR(255) NOT NULL,
	UM_MODULE_ID INTEGER NOT NULL,
	PRIMARY KEY(UM_ACTION, UM_MODULE_ID),
	FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE
);

ALTER TABLE UM_PERMISSION ADD COLUMN UM_MODULE_ID INTEGER DEFAULT 0;
ALTER TABLE UM_ROLE_PERMISSION ADD COLUMN UM_DOMAIN_ID INTEGER;
ALTER TABLE UM_ROLE_PERMISSION ADD CONSTRAINT UQ_UM_ROLE_PERMISSION UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID);
ALTER TABLE UM_ROLE_PERMISSION ADD CONSTRAINT UM_ROLE_PERMISSION_UM_DOMAIN FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE;


INSERT INTO UM_DOMAIN (UM_DOMAIN_NAME, UM_TENANT_ID) VALUES ('PRIMARY', -1234);
INSERT INTO UM_DOMAIN (UM_DOMAIN_NAME, UM_TENANT_ID) VALUES ('SYSTEM', -1234);
INSERT INTO UM_DOMAIN (UM_DOMAIN_NAME, UM_TENANT_ID) VALUES ('INTERNAL', -1234);


INSERT INTO UM_DOMAIN (UM_TENANT_ID) SELECT UM_ID FROM UM_TENANT;
UPDATE UM_DOMAIN SET UM_DOMAIN_NAME = 'SYSTEM' WHERE UM_DOMAIN_NAME IS NULL AND UM_TENANT_ID IN (SELECT UM_ID FROM UM_TENANT);

INSERT INTO UM_DOMAIN (UM_TENANT_ID) SELECT UM_ID FROM UM_TENANT;
UPDATE UM_DOMAIN SET UM_DOMAIN_NAME = 'INTERNAL' WHERE UM_DOMAIN_NAME IS NULL AND UM_TENANT_ID IN (SELECT UM_ID FROM UM_TENANT);

INSERT INTO UM_DOMAIN (UM_TENANT_ID) SELECT UM_ID FROM UM_TENANT;
UPDATE UM_DOMAIN SET UM_DOMAIN_NAME = 'PRIMARY' WHERE UM_DOMAIN_NAME IS NULL AND UM_TENANT_ID IN (SELECT UM_ID FROM UM_TENANT);

/**
SYSTEM
INTERNAL
PRIMARY
**/

UPDATE UM_ROLE_PERMISSION SET UM_ROLE_PERMISSION.UM_DOMAIN_ID = (SELECT UM_DOMAIN.UM_DOMAIN_ID FROM UM_DOMAIN WHERE UM_DOMAIN.UM_TENANT_ID = UM_ROLE_PERMISSION.UM_TENANT_ID AND UM_ROLE_PERMISSION.UM_DOMAIN_ID IS NULL AND UM_DOMAIN.UM_DOMAIN_NAME = 'PRIMARY') WHERE UM_ROLE_PERMISSION.UM_DOMAIN_ID IS NULL;

UPDATE UM_ROLE_PERMISSION SET UM_ROLE_PERMISSION.UM_DOMAIN_ID = (SELECT UM_DOMAIN.UM_DOMAIN_ID FROM UM_DOMAIN WHERE UM_DOMAIN.UM_TENANT_ID = UM_ROLE_PERMISSION.UM_TENANT_ID AND UM_ROLE_PERMISSION.UM_ROLE_NAME = 'everyone' AND UM_DOMAIN.UM_DOMAIN_NAME = 'INTERNAL') WHERE UM_ROLE_PERMISSION.UM_ROLE_NAME = 'everyone';

UPDATE UM_ROLE_PERMISSION SET UM_ROLE_PERMISSION.UM_DOMAIN_ID = (SELECT UM_DOMAIN.UM_DOMAIN_ID FROM UM_DOMAIN WHERE UM_DOMAIN.UM_TENANT_ID = UM_ROLE_PERMISSION.UM_TENANT_ID AND  UM_ROLE_PERMISSION.UM_ROLE_NAME = 'wso2.anonymous.role' AND UM_DOMAIN.UM_DOMAIN_NAME = 'SYSTEM') WHERE UM_ROLE_PERMISSION.UM_ROLE_NAME = 'wso2.anonymous.role';

CREATE TABLE UM_SHARED_USER_ROLE(
    UM_ROLE_ID INTEGER NOT NULL,
    UM_USER_ID INTEGER NOT NULL,
    UM_USER_TENANT_ID INTEGER NOT NULL,
    UM_ROLE_TENANT_ID INTEGER NOT NULL,
    UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),
    FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,
    FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE
);

CREATE TABLE UM_ACCOUNT_MAPPING(
	UM_ID INTEGER NOT NULL AUTO_INCREMENT,
	UM_USER_NAME VARCHAR(255) NOT NULL,
	UM_TENANT_ID INTEGER NOT NULL,
	UM_USER_STORE_DOMAIN VARCHAR(100),
	UM_ACC_LINK_ID INTEGER NOT NULL,
	UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),
	FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,
	PRIMARY KEY (UM_ID)
);


ALTER TABLE UM_CLAIM ADD COLUMN UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255);
ALTER TABLE UM_CLAIM ADD COLUMN UM_CHECKED_ATTRIBUTE SMALLINT;
ALTER TABLE UM_CLAIM ADD COLUMN UM_READ_ONLY SMALLINT;

ALTER TABLE UM_CLAIM ADD CONSTRAINT UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN);

DROP TABLE IF EXISTS UM_CLAIM_BEHAVIOR;

ALTER TABLE UM_HYBRID_USER_ROLE ADD COLUMN UM_DOMAIN_ID INTEGER;

ALTER TABLE UM_HYBRID_USER_ROLE ADD CONSTRAINT UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID);
ALTER TABLE UM_HYBRID_USER_ROLE ADD CONSTRAINT FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE;

CREATE TABLE UM_SYSTEM_ROLE(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_ROLE_NAME VARCHAR(255),
            UM_TENANT_ID INTEGER DEFAULT 0,
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
);

CREATE TABLE UM_SYSTEM_USER_ROLE(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_USER_NAME VARCHAR(255),
            UM_ROLE_ID INTEGER NOT NULL,
            UM_TENANT_ID INTEGER DEFAULT 0,
            UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),
            FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
);
