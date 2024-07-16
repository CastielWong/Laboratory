CREATE DATABASE IF NOT EXISTS DEMO;

USE DEMO;

DROP TABLE IF EXISTS SampleDataset;

CREATE TABLE SampleDataset (
    a   INTEGER       PRIMARY KEY
    , b   VARCHAR(10)
);

INSERT INTO SampleDataset    VALUES
(1001, 'Something'),
(1002, 'Anything'),
(1003, 'Nothing');
