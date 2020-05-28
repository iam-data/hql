--- Segment Level Rollup
select 
    segment,
    technology,
    sum(`# of Instances`) ,
    sum(`# of instance Hardened`) `# of instance Hardened`,
    sum(`# of instance Hardened`)/ sum(`# of Instances`) * 100 `% of Completion`
from
(
select 
    'overall' segment,
    'overall' Technology,
    sum(`# of Instances`) `# of Instances`,
    sum(`# of instance Hardened`) `# of instance Hardened`,
    sum(`# of instance Hardened`)/ sum(`# of Instances`) `% of Completion`
from
(
select  
    segment,
    case 
        when technology like '%Oracle%' then 'Oracle'
        when technology like '%Microsoft%' then 'MS SQL'
        when technology like '%IBM DB2%' then 'DB LUW'
    end Technology,
    count(instance) `# of Instances`,
    sum(case when percentage >= 100 then 1
    else 0
    end ) as `# of instance Hardened`,
    sum(case when percentage >= 100 then 1
    else 0
    end ) / count(instance) `% of Completion`
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
report_date = date_sub(current_date,1)
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
) T2
) T3
group by  segment,technology
union all
select 
    segment,
    Technology,
    sum(`# of Instances`) `# of Instances`,
    sum(`# of instance Hardened`) `# of instance Hardened`,
    sum(`# of instance Hardened`)/ sum(`# of Instances`) * 100 `% of Completion`
from
(
select  
    segment,
    case 
        when technology like '%Oracle%' then 'Oracle'
        when technology like '%Microsoft%' then 'MS SQL'
        when technology like '%IBM DB2%' then 'DB LUW'
    end Technology,
    count(instance) `# of Instances`,
    sum(case when percentage >= 100 then 1
    else 0
    end ) as `# of instance Hardened`,
    sum(case when percentage >= 100 then 1
    else 0
    end ) / count(instance) `% of Completion`
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
report_date = date_sub(current_date,1)
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
) T2
group by technology, segment
