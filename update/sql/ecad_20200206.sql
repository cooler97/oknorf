exec('
ALTER view [dbo].[view_orderitem_pc_good]
as
SELECT oi.*,
	 m.name AS model_name, 
	 g.name AS good_name, g.marking AS good_marking,g.waste good_waste,
	 g.extmarking as good_extmarking,
	 me.typ measure_typ,
	 case when (oi.idgood is not null)
			then me.shortname
		  else ''шт''
	 end measure_shortname,
	me.factor measure_factor,
	gt.name goodtype_name,
	gt.idgoodtype good_idgoodtype,
(
	select isnull(sum(opc.sm),0) from view_orderpricechange opc 
	where opc.idorderitem = oi.idorderitem and opc.pricechange_typ2 = 0 
		and opc.deleted is null and fororder = 0
) pricechange_skidka,
(
	select isnull(sum(opc.sm),0) from view_orderpricechange opc 
	where opc.idorderitem = oi.idorderitem and opc.pricechange_typ2 = 1
		and opc.deleted is null and fororder = 0
) pricechange_nac,
(
	select isnull(sum(sm),0)
	from ordergood og
	where og.idorderitem = oi.idorderitem and og.deleted is null
) ordergood_sm,
(
	select case when oi.sm = 0 then 0 else isnull(sum(sm),0) / oi.sm end
	from view_orderpricechange opc
	where opc.idorderitem = oi.idorderitem and opc.pricechange_typ2 = 1
	and opc.deleted is null and fororder = 1
) pricechange_ordernac
FROM orderitem oi 
LEFT JOIN good g ON (g.idgood = oi.idgood)
left join goodtype gt on (gt.idgoodtype = g.idgoodtype)
left join measure me on (me.idmeasure = g.idmeasure)
LEFT JOIN model m ON (m.idmodel = oi.idmodel)

')

GO-----