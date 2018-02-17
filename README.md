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
computing flooded volumes and locating gates. They must be used in the order 
presented below.

### 1. centaur.in/CreateDBSchema.java

Creates all the necessary database assets (tables, functions and views) in the 
desired schema. Takes as arguments (in this order):
 - database user name
 - database user password
 - new schema name 
 - database name
 
This script requires access to the SQL scripts provided in the `data` directory. 
 
Example of use, creating a schema for Dübendorf in a database named SWW:

`$ java -jar CreateDBSchema.jar user password dubendorf sww`


 
### 2. centaur.in/CreateHibernateConfig.java

Creates the Hibernate configuration files, `.cfg.xml` and `.reveng.xml`, 
necessary to access a given database schema. All subsequent classes require 
these files to use a new schema created with the CreateDBSchema class.  Takes 
as arguments (in this order):
 - database user name
 - database user password
 - new schema name 
 - database name (optional, centaur by default)
 - database port (optional, 5432 by default)
  
Example of use, creating a configuration for Dübendorf in a database named SWW:

`$ java -jar CreateHibernateConfig.jar user password dubendorf sww 5433`

### 3. centaur.in/ImportSWMM.java

Imports the sewer network data present in a given SWMM file into a desired 
database schema. Takes as arguments (in this order): 
 - the database schema 
 - the path to the .inp file 
 
Example of use, importing data to the Dübendorf schema:

`$ java -jar ImportSWMM.jar dubendorf Dubendorf.inp`

### 4. centaur.opt/FloodedSegmentsStatic.java

Computes for each node of the network the segments floodable by a gate without 
producing overflows. It fills (or updates) the contents of the `flooded` table. 
This algorithm uses a *Static* assumption, i.e. there is no flow and energy 
lines are all flat. It takes as single argument the database schema.

Example with the Dübendorf schema:

`$ java -jar FloodedSegmentsStatic.jar dubendorf`

### 5. centaur.opt/FloodedSegmentsDynamic.java

Computes for each node of the network the segments floodable by a gate without 
producing overflows. It fills (or updates) the contents of the `flooded` table. 
This algorithm uses a *Dynamic* assumption, i.e. there is a flow and energy 
lines are taken into account to determine the extent flooded in each segment. 
It takes as single argument the database schema.

Example with the Dübendorf schema:

`$ java -jar FloodedSegmentsDynamic.jar dubendorf`

### 6. centaur.opt/LocateGates.java

Locates a desired number of gates upstream of a given node of a given network.
To run this executable the `flooded` table must be filled in; this can be done 
with one of the *FloodedSegments* classes listed above It uses five different 
heuristics to rank the best gate locations using the variables:
 - upstream storage volume (V)
 - total contributing surface area (A)
 - number of contributing sub-catchments (C)

The heuristics are:
 - V 
 - V * A
 - V / C
 - V * A / C
 - V / A 

This class can also trigger the computation of storage volumes, if required.
The list of arguments:

 - `-a`          : use Area in search function (default: false)
 - `-c`          : use number of Catchments in search function (default: false)
 - `-h` (`--help`) : Print help text (default: false)
 - `-i` N        : identifier of a node of interest
 - `-n` N        : number of gates to locate
 - `-oa`         : use search function over Area (default: false)
 - `-s` VAL      : the database schema
 
#### Examples 
 
Locate 3 gates in the Dübendorf schema, using the V/A heuristic:

`$ java -jar LocateGates.jar -n 3 -oa -s dubendorf`

Locate 5 gates upstream of node 42 using the V * A heuristic:

`$ java -jar LocateGates.jar -a -i 42 -n 5 -s dubendorf` 

Locate 1 gate upstream of node 42 using the V / C heuristic:

`$ java -jar LocateGates.jar -c -i 42 -n 1 -s dubendorf` 


### 7. centaur.opt/PlotGraphs.java

Plots a series of graphs showing the rankings of each network node according to
the variables used in the location algorithm. These graphs are displayed in a 
Swing based GUI. It takes as single argument the database schema. 

Example, again with the Dübendorf schema:

`$ java -jar PlotGraphs.jar dubendorf`

Licence
-------------------------------------------------------------------------------

This software is released under the EUPL 1.1 licence [1]. For further details please 
consult the LICENCE file.

[1] https://joinup.ec.europa.eu/community/eupl/og_page/eupl
