TingpaiLogic = {}

TingpaiLogic.AllPaiValue = 
{
	101,102,103,104,105,106,107,108,109,110,
	201,202,203,204,205,206,207,208,209,210
};

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
            if #combis[i][lastIndex] < kindNum * 2 then                                    
				local tempHufen = TingpaiLogic.GetvalidCombiHufen(combis[i]) + xiaoQiangHuxi
                table.sort(combis[i][lastIndex])
				TingpaiLogic.getKindPai_ting_hu(combis[i][lastIndex],res_ting_hu, kindNum, tempHufen)
            elseif #combis[i][lastIndex] <= kindNum * 2 + 2 then
                markTempList = TingpaiLogic.getmarkTempl(combis[i][lastIndex])
                if #markTempList >= kindNum then
                    TingpaiLogic.markDnfTingCard(markTempList,combis[i][lastIndex],res_ting_hu,kindNum,xiaoQiangHuxi)
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

function TingpaiLogic.getKindPai_ting_hu(handpokers,res_ting_hu, kindNum, tempHuxi)
    local handSize = #handpokers + kindNum;
	if handSize % 3 == 1 then    --单钓
        if kindNum == 1 then
            TingpaiLogic.DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        elseif kindNum == 2 then
            TingpaiLogic.DTwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        elseif kindNum == 3 then
            TingpaiLogic.DThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        elseif kindNum == 4 then
            TingpaiLogic.DFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        end

    else
        if kindNum == 1 then
            TingpaiLogic.SOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        elseif kindNum == 2 then
            TingpaiLogic.STwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        elseif kindNum == 3 then
            TingpaiLogic.SThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        elseif kindNum == 4 then
            TingpaiLogic.SFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
        end
    end
end

function TingpaiLogic.DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
        TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi)
    end
end

function TingpaiLogic.DTwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    --王 王  一 一 一 二 三 四   五 六  王是3个，到这里手牌数肯定是模除3余2
	local tempChuTing = {}
	local type = {0,0}
	local value = {0,0}
	for i = 1, #handpokers do
		type[i] = TingpaiLogic.getPaiType(handpokers[i])
		value[i] = TingpaiLogic.getPaiValue(handpokers[i])
    end
    TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, 1, 2, 0)
    local size = 0
    for i,v in pairs(tempChuTing) do
        size = 1
    end
	if size > 0 then
        --一个赖子可以解决一对
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempChuTing[paiValue])
        end
	else
		local temComs1 = {handpokers[1], handpokers[1]}
		local temComs2 = {handpokers[2],handpokers[2]}
		local type1 = {TingpaiLogic.getPaiType(handpokers[1]), TingpaiLogic.getPaiType(handpokers[1])}
		local value1 = {TingpaiLogic.getPaiValue(handpokers[1]),TingpaiLogic.getPaiValue(handpokers[1])} 
		local type2 = {TingpaiLogic.getPaiType(handpokers[2]), TingpaiLogic.getPaiType(handpokers[2])}
		local value2 = {TingpaiLogic.getPaiValue(handpokers[2]),TingpaiLogic.getPaiValue(handpokers[2])} 
		TingpaiLogic.setChuTingCard(temComs1, res_ting_hu, value1, type1, 1, 2, tempHuxi)
		TingpaiLogic.setChuTingCard(temComs2, res_ting_hu, value2, type2, 1, 2, tempHuxi)
    end
end

function TingpaiLogic.DThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    --王 王 王 一 一 一 二 三 四 五  王是3个，到这里手牌数肯定是模除3余1
	local handSize = #handpokers
	local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
	local type = 0
    if handSize == 1 then
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type])
        end
    elseif handSize == 4 then
        local indexValue =   --三张组合 打出一张单挑情况
		{
			{1,2,3,4},
			{1,3,2,4},
			{1,4,2,3}
        }
        local type = {0,0,0,0}
		local value = {0,0,0,0}
        for i = 1, #handpokers do
			type[i] = TingpaiLogic.getPaiType(handpokers[i])
			value[i] = TingpaiLogic.getPaiValue(handpokers[i])
		end
		for i = 1, #handpokers do
			type[i] = TingpaiLogic.getPaiType(handpokers[i])
			value[i] = TingpaiLogic.getPaiValue(handpokers[i])
        end

		for i,comb in ipairs(indexValue) do
			local tempChuTing1 = {} 
			local tempChuTing2 = {}
			TingpaiLogic.setChuTingCard(handpokers, tempChuTing1, value, type, comb[1], comb[2], 0);
            TingpaiLogic.setChuTingCard(handpokers, tempChuTing2, value, type, comb[3], comb[4], 0);
            local size1 = 0
            local size2 = 0
            for ting1,hu1 in pairs(tempChuTing1) do
                size1 = 1
                break
            end
            for ting2,hu2 in pairs(tempChuTing2) do
                size2 = 1
                break
            end
		
			if size1 > 0 and size2 > 0 then     --能解决2对
                for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
                    tempChuTing1[paiValue] = tempChuTing1[paiValue] or 0
                    tempChuTing2[paiValue] = tempChuTing2[paiValue] or 0 
                    TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type] + tempChuTing1[paiValue] + tempChuTing2[paiValue])
                end
				break
			end
		
			if size1 > 0 then
				local temComs1 = {handpokers[comb[3]],handpokers[comb[3]]}
				local temComs2 = {handpokers[comb[4]],handpokers[comb[4]]}
                local type1 = {TingpaiLogic.getPaiType(handpokers[comb[3]]),TingpaiLogic.getPaiType(handpokers[comb[3]])}
				local value1 = {TingpaiLogic.getPaiValue(handpokers[comb[3]]),TingpaiLogic.getPaiValue(handpokers[comb[3]])}
                local type2 = {TingpaiLogic.getPaiType(handpokers[comb[4]]),TingpaiLogic.getPaiType(handpokers[comb[4]])}
				local value2 = {TingpaiLogic.getPaiValue(handpokers[comb[4]]),TingpaiLogic.getPaiValue(handpokers[comb[4]])}
				TingpaiLogic.setChuTingCard(temComs1, res_ting_hu, value1, type1, 1, 2, tempHuxi)
				TingpaiLogic.setChuTingCard(temComs2, res_ting_hu, value2, type2, 1, 2, tempHuxi)
			elseif size2 > 0 then
				local temComs1 = {handpokers[comb[1]],handpokers[comb[1]]}
				local temComs2 = {handpokers[comb[2]],handpokers[comb[2]]}
                local type1 = {TingpaiLogic.getPaiType(handpokers[comb[1]]),TingpaiLogic.getPaiType(handpokers[comb[1]])}
				local value1 = {TingpaiLogic.getPaiValue(handpokers[comb[1]]),TingpaiLogic.getPaiValue(handpokers[comb[1]])}
                local type2 = {TingpaiLogic.getPaiType(handpokers[comb[2]]),TingpaiLogic.getPaiType(handpokers[comb[2]])}
				local value2 = {TingpaiLogic.getPaiValue(handpokers[comb[2]]),TingpaiLogic.getPaiValue(handpokers[comb[2]])}
				TingpaiLogic.setChuTingCard(temComs1, res_ting_hu, value1, type1, 1, 2, tempHuxi)
				TingpaiLogic.setChuTingCard(temComs2, res_ting_hu, value2, type2, 1, 2, tempHuxi)
            end
        end
    end
end

function TingpaiLogic.DFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    --王 王 王 王 一 一 一 二 三 四  王是4个，到这里手牌数肯定是模除3余0
	local handSize = #handpokers
	local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
	local type = 0
    if handSize == 0 then
        TingpaiLogic.DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi + tempTypeHuxi[2] )
    elseif handSize == 3 then
        local indexValue = --三张组合 打出一张单挑情况
		{
			{1,2,3},
			{1,3,2},
			{2,3,1}
		}

		local type = {0,0,0}
		local value = {0,0,0}

		for i = 1, #handpokers do
			type[i] = TingpaiLogic.getPaiType(handpokers[i])
			value[i] = TingpaiLogic.getPaiValue(handpokers[i])
        end

		for i,comb in ipairs(indexValue) do
			local tempChuTing = {}
            TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, comb[1], comb[2], 0)
            local size = 0
            for ting,hu in pairs(tempChuTing) do
                size = 1
            end
			if size > 0 then
                for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
                    TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempChuTing[paiValue] + tempTypeHuxi[type[comb[3]]])
                end
			end
			TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[comb[3]], tempHuxi + tempTypeHuxi[type[comb[1]]] + tempTypeHuxi[type[comb[2]]]);
		end
    elseif handSize == 6 then
        local kindNum = 3
		local tempHandPoker = table.clone(handpokers)
		local markTempl = TingpaiLogic.getmarkTempl(tempHandPoker)
        if #markTempl >= kindNum then
            table.insert(tempHandPoker,g_phzCards.kind_CardValue)
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi)
        end
    end
end

function TingpaiLogic.SOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
	--到这肯定是 1张王 和 剩一张牌
	local type = TingpaiLogic.getPaiType(handpokers[1])
	local value = TingpaiLogic.getPaiValue(handpokers[1])

	if (value > 1) then
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] - 1, tempHuxi)
    end

	if (value > 2) then
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] - 2, tempHuxi)
    end

	if (value < 10) then
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] + 1, tempHuxi)
    end

	if (value < 9) then
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] + 2, tempHuxi)
    end

	TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1], tempHuxi + tempTypeHuxi[type])
	if (type == 1) then
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] + 100, tempHuxi)
	else
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] - 100, tempHuxi)
    end

	--看能否听二七十
	if (value == 2) then
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 7, tempHuxi + tempTypeHuxi[type])
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 10, tempHuxi + tempTypeHuxi[type])
	elseif (value == 7) then
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 2, tempHuxi + tempTypeHuxi[type])
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 10, tempHuxi + tempTypeHuxi[type])
	elseif (value == 10) then
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 2, tempHuxi + tempTypeHuxi[type])
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 7, tempHuxi + tempTypeHuxi[type])
    end
end

function TingpaiLogic.STwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    local handSize = #handpokers
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
    if handSize == 0 then
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            local type = TingpaiLogic.getPaiType(paiValue)
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type])
        end
    elseif handSize == 3 then
        local indexValue =  --三张组合 打出一张单挑情况
		{
            {1,2,3},
			{1,3,2},
			{2,3,1}
        }
		local type = {0,0,0}
		local value = {0,0,0}

		for  i = 1, #handpokers do
			type[i] = TingpaiLogic.getPaiType(handpokers[i])
			value[i] = TingpaiLogic.getPaiValue(handpokers[i])
        end

		for i,comb in ipairs(indexValue) do
			local tempChuTing = {}
            TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, comb[1], comb[2], 0)
            local maxTempHuxi = 0
            local size = 0
            for ting,hu in pairs(tempChuTing) do
                if hu > maxTempHuxi then
                    maxTempHuxi = hu
                end
                size = 1
            end
			if (size > 0) then
				local temp ={ handpokers[comb[3]] }
				TingpaiLogic.SOneKindPaiTingRes(temp, res_ting_hu, tempHuxi + maxTempHuxi)
            end
		end
    end
end

function TingpaiLogic.SThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
    local handSise = #handpokers
    local type = {}
	local value = {}

    for  i = 1, #handpokers do
        table.insert(type,TingpaiLogic.getPaiType(handpokers[i]))
        table.insert(value,TingpaiLogic.getPaiValue(handpokers[i]))
    end

    if handSise == 2 then
        local tempChuTing = {}
        TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, 1, 2, 0)
        local size = 0
        local maxTempHuxi = 0
        for ting,hu in pairs(tempChuTing) do
            if hu > maxTempHuxi then
                maxTempHuxi = hu
            end
            size = 1
        end

		if (size > 0) then
			for i,paiValue in ipairs (TingpaiLogic.AllPaiValue) do
				local temptype = TingpaiLogic.getPaiType(paiValue)
				TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + maxTempHuxi + tempTypeHuxi[temptype])
            end
		end
		
		local tempHand1 = {handpokers[1]}
		local tempHand2 = {handpokers[2]}

		TingpaiLogic.SOneKindPaiTingRes(tempHand1, res_ting_hu, tempHuxi + tempTypeHuxi[type[1]])
		TingpaiLogic.SOneKindPaiTingRes(tempHand2, res_ting_hu, tempHuxi + tempTypeHuxi[type[2]])
    elseif handSise == 5 then
        local kindNum = 2
		local tempHandPoker = table.clone(handpokers)
		local markTempl = TingpaiLogic.getmarkTempl(tempHandPoker)
		if (#markTempl >= kindNum) then
            table.insert(tempHandPoker,g_phzCards.kind_CardValue)
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi)
        end
    end
end

function TingpaiLogic.SFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi)
    --四张王 剩 1 4 7
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
    local handSise = #handpokers

    local type = {}
	local value = {}

    for  i = 1, #handpokers do
        table.insert(type,TingpaiLogic.getPaiType(handpokers[i]))
        table.insert(value,TingpaiLogic.getPaiValue(handpokers[i]))
    end

    local tempHandPoker = table.clone(handpokers)
    local markTempl = TingpaiLogic.getmarkTempl(tempHandPoker)
    
    if handSise == 1 then
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            local type = TingpaiLogic.getPaiType(paiValue)
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type])
        end
    elseif handSise == 4 then
        local kindNum = 2
        table.insert(tempHandPoker,g_phzCards.kind_CardValue)
        table.insert(tempHandPoker,g_phzCards.kind_CardValue)
		if (#markTempl >= kindNum) then
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi)
		elseif (#markTempl >= kindNum - 1) then
			table.insert(tempHandPoker,g_phzCards.kind_CardValue)
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 1, tempHuxi)
        end
    elseif handSise == 7 then
        local kindNum = 3
		table.insert(tempHandPoker,g_phzCards.kind_CardValue)
		if #markTempl >= kindNum then
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi)
		elseif (#markTempl >= kindNum - 1) then
			table.insert(tempHandPoker,g_phzCards.kind_CardValue)
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 1, tempHuxi)
		elseif (#markTempl >= kindNum - 2) then
			table.insert(tempHandPoker,g_phzCards.kind_CardValue)
			table.insert(tempHandPoker,g_phzCards.kind_CardValue)
			TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 2, tempHuxi)
        end
    end
end

function TingpaiLogic.markDnfTingCard(markTempl,tempHandPoker,res_ting_hu,kindNum,tempHuxi)
    local kindCombis = TingpaiLogic.combinationMarkTempList(markTempl, kindNum)
    for k = 1, kindNum do
        table.insert(tempHandPoker,0)
    end
	local handSize = #tempHandPoker
	for j = 1, #kindCombis do
		local kindSize = #kindCombis[j]
		for Q = 1, kindSize do
			tempHandPoker[handSize - Q + 1] = kindCombis[j][Q];
        end
		TingpaiLogic.getTingPaiList(tempHandPoker, res_ting_hu, tempHuxi);
	end
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
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi + g_phzHuxi.b_chi)
                end
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi)
            end
        end

		if (value[scondIndex] ~= 10) then
		
			if (value[scondIndex] + 1 == 3) then           --听的是3
				if (type[scondIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi + g_phzHuxi.s_chi)
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi + g_phzHuxi.b_chi)
                end
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi)
            end
        end

	elseif (combi[firstIndex] - combi[scondIndex] == -2) then
	
		if (value[firstIndex] + 1 == 2) then                 --听的是2
            if (type[firstIndex] == 1) then
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi + g_phzHuxi.s_chi)
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi + g_phzHuxi.b_chi)
            end
		
		else
            TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi)
        end
	
	elseif (value[firstIndex] == value[scondIndex]) then
        TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 100,pubicHuxi)
        TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 200,pubicHuxi)
        if type[firstIndex] == type[scondIndex] then
            if type[scondIndex] == 2 then 
                TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 200,pubicHuxi + g_phzHuxi.b_xiao )
            else        
                TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 100,pubicHuxi + g_phzHuxi.s_xiao)
            end 
        end
	
	else
        if (type[firstIndex] == type[scondIndex]) then
		
			if (value[firstIndex] == 2 and value[scondIndex] == 7) then
                if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 3,pubicHuxi + g_phzHuxi.s_chi)
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 3,pubicHuxi + g_phzHuxi.b_chi)
                end
            
			elseif (value[firstIndex] == 2 and value[scondIndex] == 10) then
			
				if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 5,pubicHuxi + g_phzHuxi.s_chi)
				else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 5,pubicHuxi + g_phzHuxi.b_chi)
                end
			
			elseif (value[firstIndex] == 7 and value[scondIndex] == 10) then
			
				if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 5,pubicHuxi + g_phzHuxi.s_chi)
				else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 5,pubicHuxi + g_phzHuxi.s_chi)
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
    local tempNum = 1
    if (#handPokers + kindNum) % 3 == 2 then
        comsize = comsize + 1
        tempNum = 0 
    end
    comsize = comsize - kindNum
    local vaildcombis = TingpaiLogic.combinationZhuhe(handPokers,3,TingpaiLogic.isVaildCombi)

    local tempcombss = {}

    local pai_count = {}
    local tempComSize = comsize + kindNum + tempNum

    for i,paiValue in ipairs(handPokers) do
        if pai_count[paiValue] == nil then
            pai_count[paiValue] = 1
        else
            pai_count[paiValue] = pai_count[paiValue] + 1
        end
    end
    
    for i = tempComSize, comsize, -1 do
        if #vaildcombis >= i then
            TingpaiLogic.combinationZhuheList(pai_count,vaildcombis, i,tempcombss)
        end
        --if #tempcombss > 0 then break end
    end

    for i,combis in ipairs(tempcombss) do
        local tempMenzi = TingpaiLogic.getMenzi(combis,handPokers)
        table.insert( combis, tempMenzi )
    end

    if ((kindNum * 2) + 2 >= #handPokers) then
        local tempHandPokers = {handPokers}
        table.insert(tempcombss,tempHandPokers)
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