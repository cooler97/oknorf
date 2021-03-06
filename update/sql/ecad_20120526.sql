if(exists(select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME='f_getorderpricechange'))
begin
	drop function f_getorderpricechange
end

GO-----

CREATE function [dbo].[f_getorderpricechange] (@idpeople int,@idorder int)
returns table
as return
(
	select op.*, 
			(case when gr.idpricechange is null then 0 else 1 end) _grant,
			gr.pricechangegroup_fullname,
			gr._isedit,
			gr.numpos pricechange_numpos
	from view_orderpricechange op left join
		 f_getpricechange (@idpeople) gr on op.idpricechange = gr.idpricechange
	where op.idorder = @idorder and gr.deleted is null and op.deleted is null
)

GO-----

--EXEC dbo.sys_refresh_view

GO-----