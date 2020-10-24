DROP TABLE DemoData;

CREATE TABLE DemoData (
    A   NUMBER(4)       PRIMARY KEY,
    B   VARCHAR2(10)
);

INSERT INTO DemoData    VALUES
(1001, 'Something'),
(1002, 'Anything'),
(1003, 'Nothing');
