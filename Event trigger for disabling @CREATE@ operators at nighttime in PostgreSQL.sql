--"Создайте в базе данных триггер, который не позволит выполнять операторы CREATE в ночное время"

create or replace function no_night_shifts() 
returns event_trigger 
as $$
declare 
    timeNow time; 
begin 
    select current_time into timeNow; 
    if (timeNow >= '00:00:00' and timeNow <= '08:00:00') 
        or (timeNow >= '22:00:00' and timeNow <= '23:59:59')   
    then raise exeption 'No creating at nighttime (21:00 - 08:00)'; 
    end if; 
end; 
$$ language plpgsql;


create event trigger night 
on ddl_command_start 
when tag in ('CREATE ACCESS METHOD', 'CREATE AGGREGATE', 'CREATE CAST', 'CREATE COLLATION', 'CREATE CONVERSION', 
'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN DATA WRAPPER', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 
'CREATE INDEX', 'CREATE LANGUAGE', 'CREATE MATERIALIZED VIEW', 'CREATE OPERATOR', 'CREATE OPERATOR CLASS', 
'CREATE OPERATOR FAMILY', 'CREATE POLICY', 'CREATE PUBLICATION', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE SEQUENCE', 
'CREATE SERVER', 'CREATE STATISTICS', 'CREATE SUBSCRIPTION', 'CREATE TABLE', 'CREATE TABLE AS', 
'CREATE TEXT SEARCH CONFIGURATION', 'CREATE TEXT SEARCH DICTIONARY', 'CREATE TEXT SEARCH PARSER', 'CREATE TEXT SEARCH TEMPLATE', 
'CREATE TRIGGER',  'CREATE TYPE',  'CREATE USER MAPPING', 'CREATE VIEW', 'SELECT INTO') 
execute procedure no_night_shifts();


