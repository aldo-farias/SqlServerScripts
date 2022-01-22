SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GenerateInsertScript] (@table varchar(128), @preventduplication bit = 0)
as
begin

	if not exists(select 0 from sys.columns where object_name(object_id) = @table)
	begin
		print 'Tabela não encontrada no banco de dados'
		return
	end
		
	declare @script varchar(max)
	if @preventduplication = 1
		set @script = 'set nocount on select replace(''if not exists(select 0 from['+@table+']where id=''''''+convert(varchar(128),ID)+'''''')insert[' + @table + ']('
	else
		set @script = 'set nocount on select replace(''insert[' + @table + ']('

	select @script = @script + '[' + name + '],' from sys.columns where object_name(object_id) = @table order by column_id
	set @script = substring(@script, 1, len(@script) - 1) + ')values(''''''+'
	select @script = @script + 'coalesce(replace(convert(varchar(max),[' + name + ']), '''''''', ''''''''''''), ''null'')+'''''',''''''+' from sys.columns where object_name(object_id) = @table order by column_id
	set @script = substring(@script, 1, len(@script) - 9) + '+'''''')'', ''''''null'''''', ''null'') from [' + @table + ']'
	print @script
	exec (@script)
end