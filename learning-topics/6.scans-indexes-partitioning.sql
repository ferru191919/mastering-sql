-- Table scans = the database reads every row in a table to answer a query.
--               Scans are simple but expensive: 
--               if you don't need the entire database, then an index or partitioning can 
--               save a lot of I/O.

-- Index = a separate, sorted structure that lets the database find rows quickly 
--          without scanning the whole table.

-- Partitioning = Partitioning splits a big table into smaller chunks (partitions) 
--                based on a partition key, so queries can read only relevant chunks.




