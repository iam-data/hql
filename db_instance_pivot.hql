select  
    segment, 
    technology technology,
    sum(case when percentage >= 100 then 1
    else 0
    end ) as `100%`,
    sum(case when percentage between 90 and 99.99 then 1
    else 0
    end)  as `90%-99%`,
    sum(case when percentage between 80 and 89.99 then 1
    else 0
    end)   as `80%-89%`,
    sum(case when percentage between  0 and 79.99 then 1
    else 0
    end)  as `0%-79%`,
    count(instance) total
from
(
select  distinct
        segment, 
        bu,
        instance,
        case 
            when platform = "Oracle Database for Windows" and technology = "Oracle 12c" then "Oracle DB 12c for Windows"
            when platform = "Oracle Database for Linux" and technology =  "Oracle 12c" then "Oracle DB 12c for UNIX/Linux"
            when platform = "Oracle for Linux" and technology =  "Oracle 12c" then "Oracle DB 12c for UNIX/Linux"
        else technology
        end technology,
        percentage
from vmar_dataset.pc_instance
where 
report_date = current_date
and technology in 
('IBM DB2 10.x', 'IBM DB2 11.x', 
'Microsoft SQL Server 2014',
'Microsoft SQL Server 2016',
'Microsoft SQL Server 2017',
'Oracle 12c')
order by instance asc
) t1
group by segment, technology
order by segment, technology asc


