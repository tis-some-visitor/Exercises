--"Создайте событийный триггер, автоматически создающий для новых таблиц обычные триггеры для аудита изменений в этих таблицах"


create or replace function 
history_of_insert_and_update() 
returns trigger 
as $$ 
begin 
    execute format('insert into %I select ($1).*, %L, current_timestamp', tg_table_name||'_backup', tg_op) 
    using new; 
    return new;
end; 
$$ language plpgsql;


create or replace function 
history_of_delete() 
returns trigger 
as $$ 
begin 
    execute format('insert into %I select ($1).*, %L, current_timestamp', tg_table_name||'_backup', tg_op) 
    using old; 
    return old;
end; 
$$ language plpgsql;


create or replace function backup_tables_and_triggers_creation() 
returns event_trigger 
as $$ 
declare 
    et_commands record;
begin 
    select * from pg_event_trigger_ddl_commands() into et_commands;

    if obj.object_identity not like '%backup' then

        execute format('create table %s_backup (like %I)', et_commands.object_identity, et_commands.objid::regclass);

        execute format('alter table %s_backup add operation text, add time timestamp', et_commands.object_identity);

        execute format('create trigger auto_save_insert_update after insert or update on %I for each row execute procedure history_of_insert_and_update()', et_commands.objid::regclass);

        execute format('create trigger auto_save_delete after delete on %I for each row execute procedure history_of_delete()', et_commands.objid::regclass);

        execute format('insert into %s_backup select * from %I', et_commands.object_identity, et_commands.objid::regclass);

        execute format('update %s_backup set operation = ''INSERT'', time = current_timestamp', et_commands.object_identity, et_commands.objid::regclass);

    end if;
end;
$$ language plpgsql;


create event trigger backups_for_new_tables 
on ddl_command_end 
when tag in ('create table', 'select into') 
execute procedure backup_tables_and_triggers_creation();




