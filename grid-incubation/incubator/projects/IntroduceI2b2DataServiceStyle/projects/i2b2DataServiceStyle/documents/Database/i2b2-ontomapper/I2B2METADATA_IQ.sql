/*
============================================================================
  The Ohio State University Research Foundation, Emory University,
  the University of Minnesota Supercomputing Institute

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/cagrid-grid-incubation/LICENSE.txt for details.
============================================================================
*/
--
-- Create Schema Script 
--   Schema             : I2B2METADATA 
--   Script Created by  : I2B2METADATA 
--   Script Created at  : 6/30/2009 4:27:37 PM 


CREATE TABLE I2B2METADATA.I2B2
(
  C_HLEVEL            NUMERIC(22)                NOT NULL,
  C_FULLNAME          VARCHAR(900)        NOT NULL,
  C_NAME              VARCHAR(2000)       NOT NULL,
  C_SYNONYM_CD        CHAR(1)              NOT NULL,
  C_VISUALATTRIBUTES  CHAR(3)              NOT NULL,
  C_TOTALNUM          NUMERIC(22),
  C_BASECODE          VARCHAR(450),
  C_METADATAXML       VARCHAR(8192) ,
  C_FACTTABLECOLUMN   VARCHAR(50)         NOT NULL,
  C_TABLENAME         VARCHAR(50)         NOT NULL,
  C_COLUMNNAME        VARCHAR(50)         NOT NULL,
  C_COLUMNDATATYPE    VARCHAR(50)         NOT NULL,
  C_OPERATOR          VARCHAR(10)         NOT NULL,
  C_DIMCODE           VARCHAR(900)        NOT NULL,
  C_COMMENT           VARCHAR(8192) ,
  C_TOOLTIP           VARCHAR(900),
  UPDATE_DATE         DATETIME,
  DOWNLOAD_DATE       DATETIME,
  IMPORT_DATE         DATETIME,
  SOURCESYSTEM_CD     VARCHAR(50),
  VALUETYPE_CD        VARCHAR(50),
  CONCEPT_PATH        VARCHAR(255)
)
;


CREATE TABLE I2B2METADATA.TABLE_ACCESS
(
  C_TABLE_CD          VARCHAR(50)         NOT NULL,
  C_TABLE_NAME        VARCHAR(50)         NOT NULL,
  C_PROTECTED_ACCESS  CHAR(1),
  C_HLEVEL            NUMERIC(22)                NOT NULL,
  C_FULLNAME          VARCHAR(900)        NOT NULL,
  C_NAME              VARCHAR(2000)       NOT NULL,
  C_SYNONYM_CD        CHAR(1)              NOT NULL,
  C_VISUALATTRIBUTES  CHAR(3)              NOT NULL,
  C_TOTALNUM          NUMERIC(22),
  C_BASECODE          VARCHAR(450),
  C_METADATAXML       VARCHAR(8192) ,
  C_FACTTABLECOLUMN   VARCHAR(50)         NOT NULL,
  C_DIMTABLENAME      VARCHAR(50)         NOT NULL,
  C_COLUMNNAME        VARCHAR(50)         NOT NULL,
  C_COLUMNDATATYPE    VARCHAR(50)         NOT NULL,
  C_OPERATOR          VARCHAR(10)         NOT NULL,
  C_DIMCODE           VARCHAR(900)        NOT NULL,
  C_COMMENT           VARCHAR(8192) ,
  C_TOOLTIP           VARCHAR(900),
  C_ENTRY_DATE        DATETIME,
  C_CHANGE_DATE       DATETIME,
  C_STATUS_CD         CHAR(1)
)
;


CREATE TABLE I2B2METADATA.SCHEMES
(
  C_KEY          VARCHAR(50)              NOT NULL,
  C_NAME         VARCHAR(50)              NOT NULL,
  C_DESCRIPTION  VARCHAR(100)
)
;


CREATE TABLE I2B2METADATA.BIRN
(
  C_HLEVEL            NUMERIC(22)                NOT NULL,
  C_FULLNAME          VARCHAR(900)        NOT NULL,
  C_NAME              VARCHAR(2000)       NOT NULL,
  C_SYNONYM_CD        CHAR(1)              NOT NULL,
  C_VISUALATTRIBUTES  CHAR(3)              NOT NULL,
  C_TOTALNUM          NUMERIC(22),
  C_BASECODE          VARCHAR(450),
  C_METADATAXML       VARCHAR(8192) ,
  C_FACTTABLECOLUMN   VARCHAR(50)         NOT NULL,
  C_TABLENAME         VARCHAR(50)         NOT NULL,
  C_COLUMNNAME        VARCHAR(50)         NOT NULL,
  C_COLUMNDATATYPE    VARCHAR(50)         NOT NULL,
  C_OPERATOR          VARCHAR(10)         NOT NULL,
  C_DIMCODE           VARCHAR(900)        NOT NULL,
  C_COMMENT           VARCHAR(8192) ,
  C_TOOLTIP           VARCHAR(900),
  UPDATE_DATE         DATETIME,
  DOWNLOAD_DATE       DATETIME,
  IMPORT_DATE         DATETIME,
  SOURCESYSTEM_CD     VARCHAR(50),
  VALUETYPE_CD        VARCHAR(50)
)
;


ALTER TABLE I2B2METADATA.TABLE_ACCESS ADD (
  CONSTRAINT TABLE_ACCESS_PK
 PRIMARY KEY
 (C_TABLE_CD));

ALTER TABLE I2B2METADATA.SCHEMES ADD (
  CONSTRAINT SCHEMES_PK
 PRIMARY KEY
 (C_KEY));

