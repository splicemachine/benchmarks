SET TIMING ON;
SET SCHEMA TPCH;
UPDATE STATISTICS FOR TABLE REGION ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE NATION ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE SUPPLIER ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE CUSTOMER ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE PART ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE PARTSUPP ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE ORDERS ON EVERY COLUMN SAMPLE;
UPDATE STATISTICS FOR TABLE LINEITEM ON EVERY COLUMN SAMPLE;
