Network analysis for the CENTAUR project
=====================================


Copyright
-------------------------------------------------------------------------------

Copyright 2016-2017 EAWAG. All rights reserved. 
Any use of this document constitutes full acceptance of all terms of the 
document licence.

Description
-------------------------------------------------------------------------------

This is a network analysis software that reads in data files from SWMM.
It is being used within the CENTAUR project [0].

[0] http://www.eawag.ch/en/department/sww/projects/centaur/

Main Packages
-------------------------------------------------------------------------------

 - *centaur.db*: contains the Java Hibernate classes and configuration files that 
   map database relations into Java classes.
   
 - *centaur.in*: contains the classes used to import data from a SWMM file into 
   the database.   

 - *centaur.opt*: the routines used to calculate flooded segments and find the
   best gate locations.

Executable classes
-------------------------------------------------------------------------------

This package contains a number of different executable classes (i.e. with a 
main() menthod) that perform different tasks, from importing the data to 
computing flooded volumes and locating gates. They must be used in order 
presented below.

### 1. centaur.in/CreateDBSchema.java

Creates all the necessary database assets (tables, functions and views) in the 
desired schema. Takes as arguments (in this order):
 - database user name
 - database user password
 - new schema name 
 - database name
 
### 2. centaur.in/CreateHibernateConfig.java

Creates the Hibernate configuration files to access a given database schema. 
These are necessary assets to use a new schema created with the CreateDBSchema
class.  Takes as arguments (in this order):
 - database user name
 - database user password
 - new schema name 
 - database name (optional)
 - database port (optional)

### 3. centaur.in/ImportSWMM.java

Imports the sewer network data present in a given SWMM file into a desired 
database schema. Takes as arguments (in this order): 
 - the path to the .inp file 
 - the database schema

### 4. centaur.opt/Main.java

Used to trigger the computation of flood segments for each network node and to 
optimally locate flood control gates. In the future it shall be split in more
specific classes.


Licence
-------------------------------------------------------------------------------

This software is released under the EUPL 1.1 licence [1]. For further details please 
consult the LICENCE file.

[1] https://joinup.ec.europa.eu/community/eupl/og_page/eupl
