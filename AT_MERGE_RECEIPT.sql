DROP TABLE AT_MERGE_RECEIPT CASCADE CONSTRAINTS ; 

CREATE TABLE AT_MERGE_RECEIPT ( 
  ATMERGERECEIPTID    NUMBER(15,5)  NOT NULL, 
  SWSERVICEORDLNID    NUMBER(15,5), 
  SWSERVICEORDERID    NUMBER(15,5), 
  SWCREATEDBY         VARCHAR2(20)  NOT NULL, 
  SWDATECREATED       DATE          NOT NULL, 
  TIMESTAMP           VARCHAR2(10), 
  ATWAYBILL           VARCHAR2(40), 
  ATQTYSHIPPED        VARCHAR2(40), 
  ATDATESHIPPED       DATE, 
  ATDATEACKNOWLEDGED  DATE, 
  ATPOLINEFLAG        NUMBER(1), 
  ATCARRIER           VARCHAR2(40), 
  PRIMARY KEY ( ATMERGERECEIPTID ));