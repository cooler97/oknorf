if(not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='orderitem' and COLUMN_NAME='isnonsupport'))
begin
	alter table orderitem add isnonsupport smallint;
end

GO-----

ALTER view [dbo].[view_orderitem] as
select oi.*,
				m.name AS model_name, 
				g.name AS good_name, 
				g.marking AS good_marking,
				g.extmarking AS good_extmarking,
				g.waste good_waste,
				g.price1 good_price1,
				me.typ measure_typ,
				isnull(me.shortname,'шт') measure_shortname,
				me.factor measure_factor,
				me.comment measure_comment,
				gt.name goodtype_name,
				gt.idgoodtype good_idgoodtype,
				g.idgoodtype2 good_idgoodtype2,
				gt.numpos goodtype_numpos,
				gt2.name goodtype_name2, 
				gt2.numpos goodtype_numpos2,
				(select top 1 name
					 from manufactdoc d, manufactdocpos dp 
					 where d.idmanufactdoc = dp.idmanufactdoc
					 and dp.idorderitem = oi.idorderitem  and dp.deleted is null and d.deleted is null
				) mdoc_name,
				(select top 1 dtdoc
					 from manufactdoc d, manufactdocpos dp 
					 where d.idmanufactdoc = dp.idmanufactdoc
					 and dp.idorderitem = oi.idorderitem and dp.deleted is null and d.deleted is null
				) mdoc_dt,
				(select sum(qu)
					 from manufactdocpos dp 
					 where dp.idorderitem = oi.idorderitem and dp.deleted is null
				) mdoc_qu,
				g.idgoodgroup good_idgoodgroup,
				g.ismy good_ismy,
				gg.name goodgroup_name,
				ps.name profsys_name,
				fs.name furnsys_name,
				ct.name constrtype_name,
				g.idcolor1 good_idcolor1,
				g.idcolor2 good_idcolor2,
				isnull(cin.name,'') colorin_name,
				isnull(cout.name,'') colorout_name,
				pt.name productiontype_name,
				pt.typ productiontype_typ,
				pt.productiontypegroup productiontype_productiontypegroup,
				0 vdfield1,
				oi.sqr * oi.qu sqrtotal 
		FROM orderitem oi LEFT JOIN 
				good g ON (g.idgood = oi.idgood) left join 
				goodtype gt on (gt.idgoodtype = g.idgoodtype) left join 
				goodtype gt2 on (gt2.idgoodtype = g.idgoodtype2) left join 
				model m ON (m.idmodel = oi.idmodel and m.deleted is null)  Left join 
				goodgroup gg on (gg.idgoodgroup = g.idgoodgroup) left join
				system ps on oi.idprofsys = ps.idsystem left join
				-- связывание по serial!
				--system fs on oi.idfurnsys = fs.idsystem  left join (as180)
				system fs on oi.idfurnsys = fs.serial left join
				constructiontype ct on ct.idconstructiontype = oi.idconstructiontype left join
				color cin on oi.idcolorin = cin.idcolor left join
				color cout on oi.idcolorout = cout.idcolor left join
				productiontype pt on oi.idproductiontype = pt.idproductiontype LEFT JOIN 
				-- measure me on (me.idmeasure = isnull(g.idmeasure,pt.idmeasure)) 
				-- ед. изменения сначала из продукции, а потом только из материала
				measure me on (me.idmeasure = isnull((select pt1.idmeasure from productiontype pt1 where pt1.idproductiontype = oi.typ), g.idmeasure))
				
GO-----
