
-- administrative
SHOW DATABASES;

SELECT currentDatabase();

SELECT *
FROM system.tables;


CREATE DATABASE IF NOT EXISTS DemoDB;

-- won't work in HTTP interface
USE DemoDB;

CREATE TABLE IF NOT EXISTS checking(
  a String
  , b UInt8
  , c FixedString(1)
) ENGINE = Log;


INSERT INTO DemoDB.checking (a,b,c) VALUES
('user_1', 1, '1'), ('user_2', 2, '5'), ('user_3', 3, '5'),
('user_1', 1, '5'), ('user_4', 4, '5'), ('user_5', 5, '5');

SELECT  *
FROM  DemoDB.checking;
