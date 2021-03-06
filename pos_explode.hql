insert overwrite table itdatastore_curated.network_ip_list partition (report_date='${hivevar:report_date}')
select
        a.type,
        a.subnet_zone,
        a.location,
        a.owner_manager,
        a.building,
        a.building_floor,
        a.room_area,
        a.address_1,
        a.address_2,
        a.city,
        a.state_province,
        a.postal_code,
        a.country,
        a.scan,
        a.address_begin,
        a.address_end,
        concat_ws('.',cast(a.octet1 as string),cast(a.octet2 as string),cast(a.octet3 as string),cast(a.octet4 as string)) as ip,
        a.cidr,
        a.subnet,
        a.comment,
        a.description,
        current_timestamp create_ts,
        a.subnet_begin,
        a.contact,
        a.subnet_end
from
(select
        b.type,
        b.subnet_zone,
        b.location,
        b.owner_manager,
        b.building,
        b.building_floor,
        b.room_area,
        b.address_1,
        b.address_2,
        b.city,
        b.state_province,
        b.postal_code,
        b.country,
        b.scan,
        b.address_begin,
        b.address_end,
        b.create_ts,
        CAST((b.ip_int / 16777216) as bigint) as octet1,
        CAST(((b.ip_int - CAST((b.ip_int / 16777216) as bigint) * 16777216) / 65536) as bigint)  as octet2,
        CAST(((b.ip_int - (CAST((b.ip_int / 16777216) as bigint) * 16777216) - (CAST(((b.ip_int - CAST((b.ip_int / 16777216) as bigint) * 16777216) / 65536) as bigint)) * 65536) / 256) as int) as octet3,
CAST(((b.ip_int - (CAST((b.ip_int / 16777216) as bigint) * 16777216) - (CAST(((b.ip_int - CAST((b.ip_int / 16777216) as bigint) * 16777216) / 65536) as bigint)) * 65536) - CAST(((b.ip_int - (CAST((b.ip_int / 16777216) as bigint) * 16777216) - (CAST(((b.ip_int - CAST((b.ip_int / 16777216) as bigint) * 16777216) / 65536) as bigint)) * 65536) / 256) as int) * 256) as bigint) as octet4,
        b.report_date,
        b.cidr,
        b.subnet,
        b.comment,
        b.description,
        b.subnet_begin,
        b.contact,
        b.subnet_end
from
(select
        t.type,
        t.subnet_zone,
        t.location,
        t.owner_manager,
        t.building,
        t.building_floor,
        t.room_area,
        t.address_1,
        t.address_2,
        t.city,
        t.state_province,
        t.postal_code,
        t.country,
        t.address_begin,
        t.address_end,
        t.scan,
        to_date(t.report_date) report_date,
        t.create_ts,
        t.address_begin_int + pe.i as ip_int,
        t.cidr,
        t.subnet,
        t.comment,
        t.description,
        t.subnet_begin,
        t.contact,
        t.subnet_end
from
(
        select
                type,
                subnet_zone,
                location,
                owner_manager,
                building,
                `floor` building_floor,
                room_area,
                address_1,
                address_2,
                city,
                state_provice state_province,
                postal_code,
                country,
                scan,
                report_date,
                current_timestamp create_ts,
                address_begin,
                address_end,
                (split(address_begin,'[\.]')[0]*16777216 + split(address_begin,'[\.]')[1]*65536 + split(address_begin,'[\.]')[2]*256 + split(address_begin,'[\.]')[3]) as address_begin_int,
                (split(address_end,'[\.]')[0]*16777216 + split(address_end,'[\.]')[1]*65536 + split(address_end,'[\.]')[2]*256 + split(address_end,'[\.]')[3]) as address_end_int,
                subnet,
                cidr,
                comment,
                description,
                subnet_begin,
                contact,
                subnet_end
from
        itdatastore_typed.network_location
where
                to_date(report_date)='${hivevar:report_date}'
) t
                lateral view posexplode(split(space(cast((t.address_end_int - t.address_begin_int) as int)),' ')) pe as i,s) b) a;
