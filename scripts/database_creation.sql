/*
================================================================================
Description : Creates the DataWarehouse database and its Bronze, Silver, and
              Gold schemas used for organizing the data warehouse layers.

WARNING : This script may DROP existing tables before recreating them.
================================================================================
*/
USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN
	DROP DATABASE DataWarehouse
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;	
GO

