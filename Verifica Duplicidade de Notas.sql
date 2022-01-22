alter procedure verifica_notas (@id_equipamento varchar(20),@emissaode date,@emissaoate date)
as 

declare @max int, @curr int 

--preenche variaveis
--set @id_equipamento='180749'
--set @emissaode= '20180101'
--set @emissaoate= '20180131'


select @max= (select max(convert(int,CF_NUMERO))
from LOJA_CF_SAT
where 
emissao between @emissaode and @emissaoate
--and CF_NUMERO between '11381' and '11385'
and id_equipamento=@id_equipamento
)

--max(convert (int,numero)) from lojanotafiscal
--where filial ='000006'
--and modelo ='cfe'
--and serie ='000404884'
--and convert (date,emissao )between '20180101' and '20180313'
--print @max
set @curr = (select min(convert(int,CF_NUMERO))
				from LOJA_CF_SAT
				where
				emissao between @emissaode and @emissaoate
				--and CF_NUMERO between '11381' and '11385'
				and ID_EQUIPAMENTO=@id_equipamento)
				
while @curr < @max
begin
set @curr = @curr + 1

if(not EXISTS(select (convert(int,CF_NUMERO))
from LOJA_CF_SAT
where 
emissao between @emissaode and @emissaoate
--and CF_NUMERO between '11381' and '11385'
and id_equipamento=@id_equipamento and CF_NUMERO =@curr))

begin
declare @table_dados table (
id_equipamento_sat varchar(20),
Cf_numero varchar(30),
observacao varchar(100) 
)

insert into @table_dados (id_equipamento_sat,Cf_numero,observacao)
select @id_equipamento, cast(@curr as char(10)), 'Cfe não Encontrado verificar inconsistencia!'
	--print 'Código ' + cast(@curr as char(10)) + ' não encontrado.'
end

end

if exists (select * from sys.tables where name = 'tmpnota')
begin 
drop table tmpnota 
end


select * into tmpnota from @table_dados

if exists (select top 1 CF_NUMERO  from (select data_saida,CF_NUMERO,VALOR_TOTAL_ITENS 
from LOJA_CF_SAT where CF_NUMERO in(
select (cf_numero-1) from tmpnota) and ID_EQUIPAMENTO=@id_equipamento) a
group by CF_NUMERO
having COUNT(0)>1)
		begin
		insert into tmpnota
		select @id_equipamento ,CF_NUMERO ,'Encontrado mais de uma vez !' from (select data_saida,CF_NUMERO,VALOR_TOTAL_ITENS 
		from LOJA_CF_SAT where CF_NUMERO in(
		select (cf_numero-1) from tmpnota) and ID_EQUIPAMENTO=@id_equipamento) a
		group by CF_NUMERO
		having COUNT(0)>1

		end
if exists (select * from sys.tables where name = 'tmpresultado')
begin drop table tmpresultado 
end
select * into tmpresultado from (select b.emissao Provavel_Emissao, id_equipamento_sat, a.cf_numero Cf_Nao_Encontrado, 
(a.cf_numero-1)Cf_Em_Duplicidade, 
'Verificar Valores'  Valor_nota_em_Duplicidade,
'(gravado errado no banco) -Cf numero não encontrado pois a nota anterior foi gravada errada na base' observacao 
from tmpnota a
join LOJA_CF_SAT b on (a.cf_numero -1) = b.CF_NUMERO and id_equipamento_sat = b.ID_EQUIPAMENTO
where observacao ='Cfe não Encontrado verificar inconsistencia!'
and (a.cf_numero -1) in(
select cf_numero from tmpnota
where observacao ='Encontrado mais de uma vez !'
) -- numero de nota faltando mais a nota anterior foi gravada errada no banco
group by b.emissao, id_equipamento_sat, a.cf_numero

union all
-- notas emitidas em duplicidade real

select b.emissao Provavel_Emissao,id_equipamento_sat,
 a.cf_numero Cf_Nao_Encontrado, (a.cf_numero+1)Cf_Em_Duplicidade,
 convert(varchar(20),b.VALOR_TOTAL_ITENS) Valor_nota_em_Duplicidade,
' (duplicidade)-Cfe não encontrado, provavel emissão em duplicidade pelo sat! 
Verifique esta nota no sefaz e o numero na sequencia acima dela deve esta em duplicidade'
from tmpnota a
join LOJA_CF_SAT b on (a.cf_numero +1 ) = b.CF_NUMERO and id_equipamento_sat = b.ID_EQUIPAMENTO
where a.cf_numero not in(
select cf_numero from tmpnota
where observacao ='Cfe não Encontrado verificar inconsistencia!'
and (cf_numero -1) in(
select cf_numero from tmpnota
where observacao ='Encontrado mais de uma vez !'
) 
) and observacao <> 'Encontrado mais de uma vez !') result

select * from tmpresultado





-- insertir id equipamento sat, emissão de , emissão até
exec verifica_notas '180749','20180301','20180331' 