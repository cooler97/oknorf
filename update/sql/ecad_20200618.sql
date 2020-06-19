if(not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='ordergood' and COLUMN_NAME='construction'))
begin

exec('
alter table ordergood add construction smallint;
')

end

GO-----