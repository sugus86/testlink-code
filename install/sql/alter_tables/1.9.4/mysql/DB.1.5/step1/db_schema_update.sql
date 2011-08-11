/*
 * TestLink Open Source Project - http://testlink.sourceforge.net/ 
 * This script is distributed under the GNU General Public License 2 or later. 
 * 
 * SQL script: Update schema MySQL database for TestLink 1.9 from version 1.8 
 * "/ *prefix* /" - placeholder for tables with defined prefix, used by sqlParser.class.php.
 *
 * @filesource	db_schema_update.sql
 *
 * Important Warning: 
 * This file will be processed by sqlParser.class.php, that uses SEMICOLON to find end of SQL Sentences.
 * It is not intelligent enough to ignore  SEMICOLONS inside comments, then PLEASE
 * USE SEMICOLONS ONLY to signal END of SQL Statements.
 *
 * @internal revisions:
 *
 * 20110808 - franciscom - manual migration from 1.9.1 (DB 1.4) to 1.9.4 (DB 1.5)
 */

# ==============================================================================
# ATTENTION PLEASE - replace /*prefix*/ with your table prefix if you have any. 
# ==============================================================================

/* update some config data */
INSERT INTO /*prefix*/node_types (id,description) VALUES (11,'requirement_spec_revision');

CREATE TABLE /*prefix*/req_specs_revisions (
  `parent_id` int(10) unsigned NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `revision` smallint(5) unsigned NOT NULL default '1',
  `doc_id` varchar(64) NULL,   /* it's OK to allow a simple update query on code */
  `name` varchar(100) NULL,
  `scope` text,
  `total_req` int(10) NOT NULL default '0',  
  `status` int(10) unsigned default '1',
  `type` char(1) default NULL,
  `log_message` text,
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifier_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/req_specs_revisions_uidx1 (`parent_id`,`revision`)
) DEFAULT CHARSET=utf8;

/* Create Req Spec Revision Nodes */
INSERT INTO /*prefix*/nodes_hierarchy 
(parent_id,name,node_type_id)
SELECT RSP.id,NHRSP.name,11
FROM /*prefix*/req_specs RSP JOIN /*prefix*/nodes_hierarchy NHRSP ON NHRSP.id = RSP.id;

/* Populate Req Spec Revisions Table */
INSERT INTO/*prefix*/req_specs_revisions 
(parent_id,doc_id,scope,total_req,type,author_id,creation_ts,id,name)
SELECT RSP.id,RSP.doc_id,RSP.scope,RSP.total_req,RSP.type,RSP.author_id,RSP.creation_ts,
NHRSPREV.id,NHRSPREV.name
FROM /*prefix*/req_specs RSP JOIN /*prefix*/nodes_hierarchy NHRSPREV
ON NHRSPREV.parent_id = RSP.id AND NHRSPREV.node_type_id=11; 

UPDATE /*prefix*/req_specs_revisions SET log_message='Requirement Specification Revision migrated from Testlink <= 1.9.3'; 

/* Drop Columns from Req Specs Table */
ALTER TABLE /*prefix*/req_specs DROP COLUMN scope;
ALTER TABLE /*prefix*/req_specs DROP COLUMN total_req;
ALTER TABLE /*prefix*/req_specs DROP COLUMN type;
ALTER TABLE /*prefix*/req_specs DROP COLUMN author_id;
ALTER TABLE /*prefix*/req_specs DROP COLUMN creation_ts;
ALTER TABLE /*prefix*/req_specs DROP COLUMN modifier_id;
ALTER TABLE /*prefix*/req_specs DROP COLUMN modification_ts;

ALTER TABLE /*prefix*/req_specs COMMENT = 'Updated to TL 1.9.4 - DB 1.5';


/* users */
ALTER TABLE /*prefix*/users ADD COLUMN cookie_string varchar(64) NOT NULL DEFAULT '' AFTER script_key;
UPDATE /*prefix*/users SET cookie_string=MD5(login);
ALTER TABLE /*prefix*/users ADD UNIQUE KEY /*prefix*/users_cookie_string (`cookie_string`);
ALTER TABLE /*prefix*/users COMMENT = 'Updated to TL 1.9.4 - DB 1.5';
/* ----- END ----- */