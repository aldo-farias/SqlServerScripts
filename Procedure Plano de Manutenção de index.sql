
ALTER procedure [dbo].[sp_IndexMaintenance] as
begin
	set nocount on
	declare @tablename sysname, @indexname sysname, @fragmentation float

	declare cur cursor local fast_forward for
		select object_name(a.object_id), b.name, a.avg_fragmentation_in_percent
			from sys.dm_db_index_physical_stats(db_id(), 0, -1, null, null) a 
				join sys.indexes b on a.object_id = b.object_id and a.index_id = b.index_id
			where index_level = 0
				and b.name is not null
				and a.avg_fragmentation_in_percent > 5
			order by a.object_id, a.index_id
	open cur
	fetch next from cur into @tablename, @indexname, @fragmentation
	while @@FETCH_STATUS = 0
	begin
		if @fragmentation > 40
		begin
			exec ('ALTER INDEX [' + @indexname + '] on [' + @tablename + '] REBUILD')
			print 'rebuild em index ' + @indexname + ' para ' + @tablename 
			end
		else
		begin
			exec ('ALTER INDEX [' + @indexname + '] on [' + @tablename + '] REORGANIZE')
			print 'reorganize em index ' + @indexname + ' para ' + @tablename 
			end
		fetch next from cur into @tablename, @indexname, @fragmentation
	end
	close cur
	deallocate cur

end
