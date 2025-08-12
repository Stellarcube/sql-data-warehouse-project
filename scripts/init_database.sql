/*
=========================================================================
Create Database and Schemas
=========================================================================
Script Purpose:
This script creates a new database named 'DataWarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
within the database: 'bronze', silver', 'gold'.

WARNING: This script is DESTRUCTIVE. 
Running this script will drop the entire 'DataWarehouse' database it it exists.
All data in the database will be permanently deleted. Procees with caution
and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database 
-- (In order to check whether the database already exists)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO -- Seperates batches when working with multiple SQL statements.
CREATE SCHEMA gold;
GO
