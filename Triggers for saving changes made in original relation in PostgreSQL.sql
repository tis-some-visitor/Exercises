--"Вспомогательная таблица и триггеры для аудита изменений в таблице авиарейсов"

create table flights_backup(like flights);


alter table flights_backup add start timestamp, add fin timestamp;


create or replace function history_in() 
returns trigger 
as $$ 
begin 
    execute format('insert into %I select ($1).*, current_timestamp, null', tg_table_name||'_backup') using new; 
    return new; 
end; 
$$ language plpgsql;


create or replace function history_out() 
returns trigger 
as $$ 
begin 
    execute format('update %I set fin = current_timestamp where flight_id = $1 and fin is null', tg_table_name||'_backup') using old.flight_id; 
    return old; 
end; 
$$ language plpgsql;


create trigger flights_history_update_in 
after insert or update 
on flights 
for each row 
execute procedure history_in();


create trigger flights_history_update_out 
after update or delete 
on flights 
for each row 
execute procedure history_out();



