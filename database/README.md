# SmartBuilding Database

`smartbuildingdb.sql` is the source MySQL script for this project. It creates the schema, tables, and seed data for the building management system.

## Import the database

1. Open MySQL Workbench or a MySQL terminal.
2. Run `database/smartbuildingdb.sql`.
3. Update the MySQL user and password in `backend/SmartBuilding.API/appsettings.Development.json`.

The script starts with `DROP DATABASE IF EXISTS smartbuildingdb`. Do not rerun it when the existing database data must be retained.
