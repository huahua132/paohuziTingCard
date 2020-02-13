TingpaiLogic = {}

function TingpaiLogic.getTingPaiList(_handPokers,res_ting_hu,huxi)
    local handPokers    = table.clone(_handPokers)
    local kindNum       = TingpaiLogic.getCountAndDelByHand(handPokers,g_phzCards.kind_CardValue)
    local xiaoQiang     = TingpaiLogic.resolvexiaoQingPai(handPokers)
    local xiaoQiangHuxi = TingpaiLogic.getxiaoQingHuxi(xiaoQiang) + huxi
    table.sort( handPokers )
    local combis = {}
    if (#handPokers < 3) then
        table.insert( combis, {})
        table.insert( combis[1], handPokers)
    else
        combis = TingpaiLogic.getAllCardCombi(handPokers,kindNum)
    end

    local markTempList = {}
    if kindNum > 0 then
		for  i = 1, #combis do	
            local lastIndex = #combis[i]
            if #combis[i][lastIndex] <= kindNum * 2 + 2 then
                markTempList = TingpaiLogic.getmarkTempl(combis[i][lastIndex])
                if #markTempList >= kindNum then
                    local kindCombis = TingpaiLogic.combinationMarkTempList(markTempList, kindNum)
                    for  k = 1, kindNum do
                        table.insert(combis[i][lastIndex],0)
                    end
                    local handSize = #combis[i][lastIndex]
                    for  j = 1, #kindCombis do
                        local kindSize = #kindCombis[j]
                        for  Q = 1, kindSize do
                            combis[i][lastIndex][handSize - Q + 1] = kindCombis[j][Q]
                        end
                        TingpaiLogic.getTingPaiList(combis[i][lastIndex], res_ting_hu, xiaoQiangHuxi)
                    end
                end
            end
		end
    else
        local tempHufen = 0
        for i,combi in ipairs(combis) do
            tempHufen = TingpaiLogic.GetvalidCombiHufen(combi) + xiaoQiangHuxi
           --[[ local logStr = ""
            for  i = 1, #combi do              --最后一组不是有效组合
                logStr = logStr .. "["
                for  LOOP = 1, #combi[i] do
                    logStr = logStr .. combi[i][LOOP] .. " "
                end
                logStr = logStr .. "]  "
            end
            print(logStr)]]
            if #combi[#combi] == 2 then
                TingpaiLogic.getchuTingPairByTwo(combi[#combi], res_ting_hu, tempHufen)
            elseif #combi[#combi] == 2 then
                TingpaiLogic.getchuTingPairByFour(combi[#combi], res_ting_hu, tempHufen)
            else
                local Logstr = "#combisCount:" .. #combi[#combi] .. "  "
                for i,v in ipairs(combi[#combi]) do
                    Logstr = Logstr .. v .. " "
                end
            end
        end

    end
     return res_ting_hu
end

function TingpaiLogic.getmarkTempl(handpokers)
    local markTempl = {}
	local pai_count = {}
	if (#handpokers == 1) then
		markTempl[handpokers[1]] = 1
    end
    for i = 1, #handpokers do
        if pai_count[handpokers[i]] == nil then
            pai_count[handpokers[i]] = 1
        else
            pai_count[handpokers[i]] = pai_count[handpokers[i]] + 1
        end
    end

	local value = 0
	local type = 0
	local count = 0
	for i = 1,#handpokers do
		type = TingpaiLogic.getPaiType(handpokers[i])
		value = TingpaiLogic.getPaiValue(handpokers[i])
		count = pai_count[handpokers[i]]
		if (count == 2)	then									   -- 101 101 101              
			markTempl[handpokers[i]] = 1
        else
            if (type == 1 and pai_count[handpokers[i] + 100] == 1) then     -- 101 201 101 
                markTempl[handpokers[i] + 100] = 1
            elseif (type == 2 and pai_count[handpokers[i] - 100] == 1) then-- 101 201 201
                markTempl[handpokers[i] - 100] = 1
            end

            if (value == 1) then
            
                if (pai_count[type * 100 + 2] == 1 and pai_count[type * 100 + 3] == nil) then--101 102 103
                
                    markTempl[type * 100 + 3] = 1
                
                elseif (pai_count[type * 100 + 3] == 1 and pai_count[type * 100 + 2] == nil) then--101 103 102
                
                    markTempl[type * 100 + 2] = 1
                end
            
            elseif (value == 2) then
            
                if (pai_count[type * 100 + 7] == 1 and pai_count[type * 100 + 10] == nil) then
                
                    markTempl[type * 100 + 10] = 1
                
                elseif (pai_count[type * 100 + 10] == 1 and pai_count[type * 100 + 7] == nil) then
                
                    markTempl[type * 100 + 7] = 1
                
                elseif (pai_count[type * 100 + 1] == 1 and pai_count[type * 100 + 3] == nil) then
                
                    markTempl[type * 100 + 3] = 1
                
                elseif (pai_count[type * 100 + 3] == 1 and pai_count[type * 100 + 1] == nil) then
                
                    markTempl[type * 100 + 1] = 1
                
                elseif (pai_count[type * 100 + 3] == 1 and pai_count[type * 100 + 4] == nil) then
                
                    markTempl[type * 100 + 4] = 1
                
                elseif (pai_count[type * 100 + 4] == 1 and pai_count[type * 100 + 3] == nil) then
                
                    markTempl[type * 100 + 3] = 1
                end
        
            elseif (value == 7) then
            
                if (pai_count[type * 100 + 2] == 1 and pai_count[type * 100 + 10] == nil) then
                
                    markTempl[type * 100 + 10] = 1
                
                elseif (pai_count[type * 100 + 10] == 1 and pai_count[type * 100 + 2] == nil) then
                
                    markTempl[type * 100 + 2] = 1
                
                elseif (pai_count[type * 100 + 5] == 1 and pai_count[type * 100 + 6] == nil) then
                
                    markTempl[type * 100 + 6] = 1
                
                elseif (pai_count[type * 100 + 6] == 1 and pai_count[type * 100 + 5] == nil) then
                
                    markTempl[type * 100 + 5] = 1
                
                elseif (pai_count[type * 100 + 8] == 1 and pai_count[type * 100 + 9] == nil) then
                
                    markTempl[type * 100 + 9] = 1
                
                elseif (pai_count[type * 100 + 9] == 1 and pai_count[type * 100 + 8] == nil) then
                
                    markTempl[type * 100 + 8] = 1
                end
            
            elseif (value == 9) then
            
                if (pai_count[handpokers[i] - 2] == 1 and pai_count[handpokers[i] - 1] == nil) then
                
                    markTempl[handpokers[i] - 1] = 1
                
                elseif (pai_count[handpokers[i] - 1] == 1 and pai_count[handpokers[i] - 2] == nil) then
                
                    markTempl[handpokers[i] - 2] = 1
                
                elseif (pai_count[handpokers[i] + 2] == 1 and pai_count[handpokers[i] + 1] == nil) then
                
                    markTempl[handpokers[i] + 1] = 1
                end
            
            elseif (value == 10) then
            
                if (pai_count[type * 100 + 2] == 1 and pai_count[type * 100 + 7] == nil) then
                
                    markTempl[type * 100 + 7] = 1
                
                elseif (pai_count[type * 100 + 7] == 1 and pai_count[type * 100 + 2] == nil) then
                
                    markTempl[type * 100 + 2] = 1
                
                elseif (pai_count[type * 100 + 8] == 1 and pai_count[type * 100 + 9] == nil) then
                
                    markTempl[type * 100 + 9] = 1
                
                elseif (pai_count[type * 100 + 9] == 1 and pai_count[type * 100 + 8] == nil) then
                
                    markTempl[type * 100 + 8] = 1
                end
            
            else
            
                if (pai_count[handpokers[i] - 2] == 1 and pai_count[handpokers[i] - 1] == nil) then
                
                    markTempl[handpokers[i] - 1] = 1
                
                elseif (pai_count[handpokers[i] - 1] == 1 and pai_count[handpokers[i] - 2] == nil) then
                
                    markTempl[handpokers[i] - 2] = 1
                
                elseif (pai_count[handpokers[i] + 2] == 1 and pai_count[handpokers[i] + 1] == nil) then
                
                    markTempl[handpokers[i] + 1] = 1
                
                elseif (pai_count[handpokers[i] + 1] == 1 and pai_count[handpokers[i] + 2] == nil) then
                
                    markTempl[handpokers[i] + 2] = 1
                end
            end
        end
	end


	local possibilityHus = {}

	for cardValue,count in pairs(markTempl) do
        table.insert(possibilityHus,cardValue)
    end
	return possibilityHus
end

function TingpaiLogic.getCountAndDelByHand(handpokers, paiValue)
    local res = 0
    for i = #handpokers, 1 , -1 do
        if handpokers[i] == paiValue then
            table.remove(handpokers,i)
            res = res + 1
        end
    end
    return res
end

function TingpaiLogic.getxiaoQingHuxi(xiaoQingPai)
    local res = 0
	local type = 0
	local size = 0
	for  i = 1, #xiaoQingPai do
	
		type = TingpaiLogic.getPaiType(xiaoQingPai[i][1])
		size = #xiaoQingPai[i]
		if (type == 1) then--小
		
			if (size == 4) then
			
				res = res + g_phzHuxi.s_qing
			
			else
			
				res = res + g_phzHuxi.s_xiao
            end
		
		else            --大
		
			if (size == 4) then
			
				res = res + g_phzHuxi.b_qing
			
			else
			
				res = res + g_phzHuxi.b_xiao
            end
		end
	end
	return res
end

function TingpaiLogic.getchuTingPairByTwo(combi,resChu_ting,pubicHuxi)   --没跑起的情况下，手里会省2张牌做门子
    if #combi ~= 2 then
		print("getchuTingPairByTwo err")
		return
    end

    local comSize = #combi
    local type = {}
    local value = {}
    table.sort(combi)
    for i,v in ipairs(combi) do
        type[i] = TingpaiLogic.getPaiType(combi[i])
		value[i] = TingpaiLogic.getPaiValue(combi[i])
    end
    TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, 1, 2, pubicHuxi)
end

function TingpaiLogic.getchuTingPairByFour(combi,resChu_ting,pubicHuxi) --跑起来了，要一对将牌
    if (#combi ~= 4) then
	
		print("getchuTingPairByFour err\n")
		return
    end
    local comSize = #combi
	local type = {}
	local value = {}
	table.sort( combi )

	for  i = 1, comSize do
		type[i] = TingpaiLogic.getPaiType(combi[i])
		value[i] = TingpaiLogic.getPaiValue(combi[i])
    end
	if (type[1] == type[2] and value[1] == value[2]) then
	    TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, 3, 4, pubicHuxi)
    end
	if type[3] == type[4] and value[3] == value[4] then
		TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, 1, 2, pubicHuxi)
    end

	local indexValue =   --三张组合 打出一张单挑情况
	{
		{0,1,2,3},
		{0,1,3,2},
		{0,2,3,1},
		{1,2,3,0}
	}
    
	local firstIndex
	for  i = 1, #indexValue do
	
		if (TingpaiLogic.isVaildCombi({ combi[indexValue[i][1]],combi[indexValue[i][2]], combi[indexValue[i][3]] })) then
		
			--既然剩2张 则是打出一张听另一张嘛
			local tempHufen = 0
			if (value[indexValue[i][1]] == 1) then
			
				if (value[indexValue[i][1]] == 1) then
				
					tempHufen = g_phzHuxi.s_chi
				
				else
				
				    tempHufen = g_phzHuxi.b_chi
                end
			
			elseif (value[indexValue[i][1]] == 2) then
			
				if (value[indexValue[i][1]] == 1) then
				
					tempHufen = g_phzHuxi.s_chi
				
				else
				
					tempHufen = g_phzHuxi.b_chi
                end
            end
            firstIndex = indexValue[i][3]
            TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex],pubicHuxi + tempHufen)
			--resChu_ting[combi[firstIndex]] = pubicHuxi + tempHufen
		end
    end
end

function TingpaiLogic.setTing_huValue(resChu_ting,ting,huxi)
    if resChu_ting[ting] == nil or huxi > resChu_ting[ting] then
        resChu_ting[ting] = huxi
    end
end
--[[
    combi: 放 n 张牌 {101 102，103 ... n}
    resChu_ting：结果 {key：听牌 ： value：胡息}
    value：牌值：102 的 2
    type：牌类型 ：102 的 1    （1为小字  2为大字）
    firstIndex，scondIndex combi的下标
    pubicHuxi：手中倾 和 笑 的胡息
]]
function TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, firstIndex, scondIndex, pubicHuxi)
    if combi[firstIndex] - combi[scondIndex] == -1 then
		if (value[firstIndex] ~= 1) then
			if (value[firstIndex] - 1 == 1) then                   --听的是1
                if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi + g_phzHuxi.s_chi)
					--resChu_ting[combi[firstIndex] - 1] = pubicHuxi + g_phzHuxi.s_chi
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi + g_phzHuxi.b_chi)
					--resChu_ting[combi[firstIndex] - 1] = pubicHuxi + g_phzHuxi.b_chi
                end
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi)
				--resChu_ting[combi[firstIndex] - 1] = pubicHuxi
            end
        end

		if (value[scondIndex] ~= 10) then
		
			if (value[scondIndex] + 1 == 3) then           --听的是3
				if (type[scondIndex] == 1) then
					--resChu_ting[combi[scondIndex] + 1] = pubicHuxi + g_phzHuxi.s_chi
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi + g_phzHuxi.s_chi)
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi + g_phzHuxi.b_chi)
					--resChu_ting[combi[scondIndex] + 1] = pubicHuxi + g_phzHuxi.b_chi
                end
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi)
				--resChu_ting[combi[scondIndex] + 1] = pubicHuxi
            end
        end

	elseif (combi[firstIndex] - combi[scondIndex] == -2) then
	
		if (value[firstIndex] + 1 == 2) then                 --听的是2
            if (type[firstIndex] == 1) then
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi + g_phzHuxi.s_chi)
				--resChu_ting[combi[firstIndex] + 1] = pubicHuxi + g_phzHuxi.s_chi
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi + g_phzHuxi.b_chi)
			    --resChu_ting[combi[firstIndex] + 1] = pubicHuxi + g_phzHuxi.b_chi
            end
		
		else
            TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi)
		    --resChu_ting[combi[firstIndex] + 1] = pubicHuxi
        end
	
	elseif (value[firstIndex] == value[scondIndex]) then
	
        --resChu_ting[value[firstIndex] + 100] = pubicHuxi
        TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 100,pubicHuxi)
        --resChu_ting[value[firstIndex] + 200] = pubicHuxi
        TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 200,pubicHuxi)
        if type[firstIndex] == type[scondIndex] then
            if type[scondIndex] == 2 then 
                TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 200,pubicHuxi + g_phzHuxi.b_xiao )
                --resChu_ting[value[firstIndex] + 200] = pubicHuxi + g_phzHuxi.b_xiao      --有可能会笑
            else        
                --resChu_ting[value[firstIndex] + 100] = pubicHuxi + g_phzHuxi.s_xiao
                TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 100,pubicHuxi + g_phzHuxi.s_xiao)
            end 
        end
	
	else
        if (type[firstIndex] == type[scondIndex]) then
		
			if (value[firstIndex] == 2 and value[scondIndex] == 7) then
                if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 3,pubicHuxi + g_phzHuxi.s_chi)
					resChu_ting[combi[scondIndex] + 3] = pubicHuxi + g_phzHuxi.s_chi
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 3,pubicHuxi + g_phzHuxi.b_chi)
					--resChu_ting[combi[scondIndex] + 3] = pubicHuxi + g_phzHuxi.b_chi
                end
            
			elseif (value[firstIndex] == 2 and value[scondIndex] == 10) then
			
				if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 5,pubicHuxi + g_phzHuxi.s_chi)
					--resChu_ting[combi[firstIndex] + 5] = pubicHuxi + g_phzHuxi.s_chi
				
				else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 5,pubicHuxi + g_phzHuxi.b_chi)
					--resChu_ting[combi[firstIndex] + 5] = pubicHuxi + g_phzHuxi.b_chi
                end
			
			elseif (value[firstIndex] == 7 and value[scondIndex] == 10) then
			
				if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 5,pubicHuxi + g_phzHuxi.s_chi)
					--resChu_ting[combi[firstIndex] - 5] = pubicHuxi + g_phzHuxi.s_chi
				else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 5,pubicHuxi + g_phzHuxi.s_chi)
					--resChu_ting[combi[firstIndex] - 5] = pubicHuxi + g_phzHuxi.b_chi
                end
			end
		end
    end
end

function TingpaiLogic.GetvalidCombiHufen(combi) 
    local res = 0
	local types = {}
	local values = {}
	for  i = 1, #combi - 1 do              --最后一组不是有效组合
	
		for  LOOP = 1, #combi[i] do
			types[LOOP] = TingpaiLogic.getPaiType(combi[i][LOOP])
			values[LOOP] = TingpaiLogic.getPaiValue(combi[i][LOOP])
        end

		if (types[1] == types[2] and types[2] == types[3]) then
		
			if (values[1] == 1) then --123
			
				if (types[1] == 1) then
					res = res + g_phzHuxi.s_chi
				else
					res = res + g_phzHuxi.b_chi
                end
			elseif (values[1] == 2 and values[2] == 7) then --2 7 10
			
                if (types[1] == 1) then
                    res = res + g_phzHuxi.s_chi
                else
                    res = res + g_phzHuxi.b_chi
                end
            end
		end
	end
	return res
end

function TingpaiLogic.resolvexiaoQingPai(_handpokers)
   local res = {}
   table.sort( _handpokers )

   local paiCount = 0
	local tempVal = 0
	local left = 1
	local right = #_handpokers
	local delStartIndex = 0
	local tmpPaicount = 0
	while (left <= right) do
		if _handpokers[left] ~= tempVal or paiCount == 4 then
            if paiCount >= 3 then
                table.insert( res,{})
				delStartIndex = left - paiCount
				tmpPaicount = paiCount
                while paiCount > 0 do
                    _handpokers[delStartIndex], _handpokers[right] = _handpokers[right],_handpokers[delStartIndex]
                    paiCount = paiCount - 1
                    right = right - 1
                    delStartIndex = delStartIndex + 1
                end
				while tmpPaicount > 0 do
					table.insert(res[#res],_handpokers[#_handpokers])
                    table.remove(_handpokers,#_handpokers)
                    tmpPaicount = tmpPaicount - 1
                end
				if left > right then
                    break
                end
            end
			tempVal = _handpokers[left]
			paiCount = 1
		else
			paiCount = paiCount + 1
        end
        left = left + 1
    end
    
	if paiCount >= 3 then
	
        table.insert( res,{})
        while paiCount > 0 do
			table.insert(res[#res],_handpokers[#_handpokers])
            table.remove(_handpokers,#_handpokers)
            paiCount = paiCount - 1
		end
	end

	return res
end

function TingpaiLogic.getAllCardCombi(handPokers,kindNum)
    local comsize = math.floor( (#handPokers + kindNum) / 3 ) - 1
    if (#handPokers + kindNum) % 3 == 2 then
        comsize = comsize + 1
    end
    comsize = comsize - kindNum
    local vaildcombis = TingpaiLogic.combinationZhuhe(handPokers,3,TingpaiLogic.isVaildCombi)

    local tempcombss = {}

    local pai_count = {}

    for i,paiValue in ipairs(handPokers) do
        if pai_count[paiValue] == nil then
            pai_count[paiValue] = 1
        else
            pai_count[paiValue] = pai_count[paiValue] + 1
        end
    end
    
    for i = comsize, (comsize + kindNum) do
        if #vaildcombis >= i then
            TingpaiLogic.combinationZhuheList(pai_count,vaildcombis, i,tempcombss)
        end
    end

    for i,combis in ipairs(tempcombss) do
        local tempMenzi = TingpaiLogic.getMenzi(combis,handPokers)
        table.insert( combis, tempMenzi )
    end

    return tempcombss
end

function TingpaiLogic.getMenzi(combis,handpokers)
    local pai_Index = {}
    for i = 1,#handpokers do
        if pai_Index[handpokers[i]] == nil then
            pai_Index[handpokers[i]] = {}
        end
        table.insert(pai_Index[handpokers[i]],i)
    end

    for i,com in ipairs(combis) do
        for k,pai in ipairs(com) do
            table.remove(pai_Index[pai],#pai_Index[pai])
        end
    end

    local res = {}
    for pai,combindex in pairs(pai_Index) do
        if #combindex ~= 0 then
            for i,index in ipairs(combindex) do
                table.insert(res,handpokers[index])
            end
        end
    end
	return res;
end

function TingpaiLogic.getPaiType(paiNum)
    return math.floor( paiNum / 100 )
end

function TingpaiLogic.getPaiValue(paiNum)
    return paiNum % 100
end

function TingpaiLogic.isVaildCombi(combi)
    local type = {0,0,0}
	local value = {0,0,0}

	for  i = 1, #combi do
		type[i] = TingpaiLogic.getPaiType(combi[i])
		value[i] = TingpaiLogic.getPaiValue(combi[i])
    end

	if combi[1] - combi[2] == -1 and combi[2] - combi[3] == -1 then
		return true
	elseif (value[1] == value[2] and value[2] == value[3]) then
		return true
	elseif (value[1] == 2 and value[2] == 7 and value[3] == 10 and type[1] == type[2] and type[2] == type[3]) then
        return true
    end

	return false
end

function TingpaiLogic.combinationZhuhe(sumList,nComLen,func)
    local retList = {}
    nComLen = nComLen > #sumList and #sumList or nComLen
	if nComLen == 0 then
		return retList
    end
    local pai_count = {}
    local key_value = {}
    for i,v in ipairs(sumList) do
        if pai_count[v] == nil then
            pai_count[v] = 1
        else
            pai_count[v] = pai_count[v] + 1
        end
    end

    local nSumIndex = {}

    for i = 1,nComLen+1 do
        nSumIndex[i] = i - 1
    end

    local flag = true
    local nPos = nComLen + 1

    while nSumIndex[1] == 0 do
        if flag then
            local nSumCount = {}
            local key = ""
            for i = 2,nComLen+1 do
                nSumCount[i - 1] = sumList[nSumIndex[i]]
                key = key .. sumList[nSumIndex[i]]
            end
            if func == nil or func(nSumCount) == true then
                
                if key_value[key] == nil then
                    key_value[key] = 1
                    table.insert( retList,nSumCount)
                elseif key_value[key] == 1 then
                    if nSumCount[1] % 100 ~= nSumCount[2] % 100 and pai_count[nSumCount[1]] == 2 and pai_count[nSumCount[2]] == 2 and pai_count[nSumCount[3]] == 2 then
						key_value[key] = 2
						table.insert( retList,nSumCount)
					end
                end
            end
            flag = false
        end

        local isContinue = false
        nSumIndex[nPos] = nSumIndex[nPos] + 1
        if nSumIndex[nPos] > #sumList then
            nSumIndex[nPos] = 0
            nPos = nPos - 1
            isContinue = true
        end

        if isContinue == false and nPos < nComLen + 1 then
            nPos = nPos + 1
            nSumIndex[nPos] = nSumIndex[nPos - 1]
            isContinue = true
        end

        if isContinue == false and nPos == nComLen + 1 then
            flag = true
        end
    end

    return retList
end


function TingpaiLogic.combinationZhuheList(pai_Count,sumList, nComLen,retList)
    nComLen = nComLen > #sumList and #sumList or nComLen
	if nComLen == 0 then
		return retList
    end
    local nSumIndex = {}

    for i = 1,nComLen+1 do
        nSumIndex[i] = i - 1
    end

    local flag = true
    local nPos = nComLen + 1

    while nSumIndex[1] == 0 do
        if flag then
            local nSumCount = {}
            local key_value = {}
            local isVaild = true
            for i = 2,nComLen+1 do
                nSumCount[i - 1] = sumList[nSumIndex[i]]
                for k,v in ipairs(sumList[nSumIndex[i]]) do
                    if key_value[v] == nil then
                        key_value[v] = 1
                    else
                        key_value[v] = key_value[v] + 1
                    end
                    if key_value[v] > pai_Count[v] then
                        isVaild = false
                        break
                    end
                end
                if isVaild == false then
                    break
                end
            end
            if isVaild then
                table.insert( retList,nSumCount)
            end
            flag = false
        end

        local isContinue = false
        nSumIndex[nPos] = nSumIndex[nPos] + 1
        if nSumIndex[nPos] > #sumList then
            nSumIndex[nPos] = 0
            nPos = nPos - 1
            isContinue = true
        end

        if isContinue == false and nPos < nComLen + 1 then
            nPos = nPos + 1
            nSumIndex[nPos] = nSumIndex[nPos - 1]
            isContinue = true
        end

        if isContinue == false and nPos == nComLen + 1 then
            flag = true
        end
    end

    return retList
end

function TingpaiLogic.combinationMarkTempList(sumList, nComLen)
    local retList = {}
    nComLen = nComLen > #sumList and #sumList or nComLen
	if nComLen == 0 then
		return retList
    end
    local nSumIndex = {}

    for i = 1,nComLen+1 do
        nSumIndex[i] = i - 1
    end

    local flag = true
    local nPos = nComLen + 1

    while nSumIndex[1] == 0 do
        if flag then
            local nSumCount = {}
            for i = 2,nComLen+1 do
                nSumCount[i - 1] = sumList[nSumIndex[i]]
            end
            table.insert( retList,nSumCount)
            flag = false
        end

        local isContinue = false
        nSumIndex[nPos] = nSumIndex[nPos] + 1
        if nSumIndex[nPos] > #sumList then
            nSumIndex[nPos] = 0
            nPos = nPos - 1
            isContinue = true
        end

        if isContinue == false and nPos < nComLen + 1 then
            nPos = nPos + 1
            nSumIndex[nPos] = nSumIndex[nPos - 1]
            isContinue = true
        end

        if isContinue == false and nPos == nComLen + 1 then
            flag = true
        end
    end

    return retList
end