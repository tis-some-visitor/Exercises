--"Создайте триггер, реализующий правило целостности в демонстрационной базе: рейсы могут совершать только те типы самолетов, максимальная дальность полета которых превышает расстояние между аэропортами"

create or replace function aircraft_range_to_flight_distance_check()
returns trigger 
as $$

declare 
	distance float8;
	aircraft_range integer;

begin
	select sec_to_gc(earth_distance(ll_to_earth(air.coord1[0], air.coord1[1]), ll_to_earth(air.coord2[0], air.coord2[1]))), air.f_range 
    into dist, aircraft_range 
    from
        (select dep.coordinates as coord1, arr.coordinates as coord2, c.range as f_range 
        from flights f 
        join airports_data dep 
        on f.departure_airport = dep.airport_code 
        join airports_data arr on f.arrival_airport = arr.airport_code 
        join aircrafts_data c on f.aircraft_code = c.aircraft_code 
        where f.flight_id = new.flight_id) as air;

    if dist > cast(aircraft_range as float8) * 1000 then
    raise exception 'Aircraft % has shorter flight range than needed for this flight', new.aircraft_code;

    end if;
    return new;

end;

$$ LANGUAGE plpgsql;



create trigger rangecheck 
after insert or update 
on flights 
for each row execute procedure aircraft_range_to_flight_distance_check(); 