TingpaiLogic = {}

TingpaiLogic.AllPaiValue = 
{
	101,102,103,104,105,106,107,108,109,110,
	201,202,203,204,205,206,207,208,209,210
}

TingpaiLogic.resIndex =
{
    huxi = 1,
    combi = 2
}
g_phzCards = {}
g_phzCards.kind_CardValue = 555
g_phzHuxi = {}
g_phzHuxi.b_xiao = 6
g_phzHuxi.s_xiao = 3
g_phzHuxi.b_qing = 12
g_phzHuxi.s_qing = 9
g_phzHuxi.b_pao = 9
g_phzHuxi.s_pao = 6
g_phzHuxi.s_chi = 3
g_phzHuxi.b_chi = 6
g_phzHuxi.s_peng = 1
g_phzHuxi.b_peng = 3
g_phzHuxi.s_wei = 3
g_phzHuxi.b_wei = 6
--tihuFunc 用与牌桌 碰 喂 提胡听牌
--tihuFuncParame3   tihuFunc需要用的参数
function TingpaiLogic.getTingPaiRes(_handPokers,tihuFunc,tihuFuncParame3)
    local res_ting_hu = {}
    local res = TingpaiLogic.getTingPaiList(_handPokers,res_ting_hu,0,{})
    if res.isCantihu == true then
        if type(tihuFunc) == "function" then
            tihuFunc(res_ting_hu,res.huxi,res.tiHuCombi,tihuFuncParame3)
        end
    end
    return res_ting_hu
end

function TingpaiLogic.newTingPaiResStruct()
    local ret = {}
    ret.isCanTing = false
    ret.isCantihu = false
    ret.maxTempHuxi = -1
    ret.tiHuCombi = {}
    return ret
end

function TingpaiLogic.updateTingPaiResStruct(oldres,newres)
    oldres.isCanTing = oldres.isCanTing or newres.isCanTing
    oldres.isCantihu = oldres.isCantihu or newres.isCantihu
    if newres.maxTempHuxi > oldres.maxTempHuxi then
        oldres.maxTempHuxi = newres.maxTempHuxi
        oldres.tiHuCombi = newres.tiHuCombi
    end
    return oldres
end

function TingpaiLogic.getTingPaiList(_handPokers,res_ting_hu,huxi,headcombi) --headcombi {{101,101,101},{202,202,202}}

    local handPokers    = table.clone(_handPokers)
    local kindNum       = TingpaiLogic.getCountAndDelByHand(handPokers,g_phzCards.kind_CardValue)
    local xiaoQiang     = TingpaiLogic.resolvexiaoQingPai(handPokers)
    local xiaoQiangHuxi = TingpaiLogic.getxiaoQingHuxi(xiaoQiang) + huxi
    local res = TingpaiLogic.newTingPaiResStruct()
    local newHeadCombi = {}
    newHeadCombi = TingpaiLogic.GetNewconnectCombis(xiaoQiang,headcombi)  --python_zhushi
    local combis = {}
    if (#handPokers < 3) then
        combis[#combis + 1] = {}
        combis[1][#combis[1] + 1] = handPokers
    else
        combis = TingpaiLogic.getAllCardCombi(handPokers,kindNum)
    end

    local markTempList = {}
    if kindNum > 0 then
        local tempRet = TingpaiLogic.kindPaiBuTiPai(_handPokers,res_ting_hu,xiaoQiang,kindNum,huxi,headcombi)
        TingpaiLogic.updateTingPaiResStruct(res,tempRet)
        for  i = 1, #combis do
            local lastIndex = #combis[i]
            local tempNewHeadCombi = {}
            tempNewHeadCombi = TingpaiLogic.GetNewconnectCombis(newHeadCombi,combis[i])
            table.remove(tempNewHeadCombi,#tempNewHeadCombi)               --最后一组不是有效的
            if #combis[i][lastIndex] < kindNum * 2 then                                    
				local tempHufen = TingpaiLogic.GetvalidCombiHufen(combis[i]) + xiaoQiangHuxi
                table.sort(combis[i][lastIndex])
                local tempRet = TingpaiLogic.getKindPai_ting_hu(combis[i][lastIndex],res_ting_hu, kindNum, tempHufen,tempNewHeadCombi)
                TingpaiLogic.updateTingPaiResStruct(res,tempRet)
            elseif #combis[i][lastIndex] <= kindNum * 2 + 4 then
               local tempRet = TingpaiLogic.replaceKindPaiDnfTingpai(combis[i][lastIndex],res_ting_hu,kindNum,xiaoQiangHuxi,tempNewHeadCombi)
                TingpaiLogic.updateTingPaiResStruct(res,tempRet)
            end
		end
    else
        local tempHufen = 0
        for i,combi in ipairs(combis) do
            local tempNewHeadCombi = TingpaiLogic.GetNewconnectCombis(newHeadCombi,combis[i])
            table.remove(tempNewHeadCombi,#tempNewHeadCombi)               --最后一组不是有效的
            tempHufen = TingpaiLogic.GetvalidCombiHufen(combi) + xiaoQiangHuxi
            if #combi[#combi] == 2 then
                local tempisCanTing = TingpaiLogic.getchuTingPairByTwo(combi[#combi], res_ting_hu, tempHufen,tempNewHeadCombi)
                res.isCanTing = res.isCanTing or tempisCanTing
                if combi[#combi][1] == combi[#combi][2] and #xiaoQiang >= 1 then --做将提胡的情况 网友新加
                    res.isCantihu = true
                    if tempHufen > res.maxTempHuxi then
                        res.maxTempHuxi = tempHufen
                        tempNewHeadCombi[#tempNewHeadCombi + 1] = {combi[#combi][1],combi[#combi][1]}
                        res.tiHuCombi = tempNewHeadCombi
                    end
                end
            elseif #combi[#combi] == 4 then
                local tempisCanTing = TingpaiLogic.getchuTingPairByFour(combi[#combi], res_ting_hu, tempHufen,tempNewHeadCombi)
                res.isCanTing = res.isCanTing or tempisCanTing
            elseif #combi[#combi] == 1 then
                local tempisCanTing = TingpaiLogic.getchuTingPairByOne(combi[#combi], res_ting_hu, tempHufen,tempNewHeadCombi)
                res.isCanTing = res.isCanTing or tempisCanTing
            else
                -- local Logstr = "#combisCount:" .. #combi[#combi] .. "  "
                -- for i,v in ipairs(combi[#combi]) do
                --     Logstr = Logstr .. v .. " "
                -- end
                -- print(Logstr)
            end
        end

    end

    if res.isCantihu then
        for _indexXiao,_valueXiao in ipairs(xiaoQiang) do
            if #_valueXiao == 3 then
                if TingpaiLogic.getPaiType(_valueXiao[1]) == 2 then
                    TingpaiLogic.setTing_huValue(res_ting_hu,_valueXiao[1],res.maxTempHuxi + (g_phzHuxi.b_qing - g_phzHuxi.b_xiao),res.tiHuCombi)
                    res.isCanTing = true
                else
                    TingpaiLogic.setTing_huValue(res_ting_hu,_valueXiao[1],res.maxTempHuxi + (g_phzHuxi.s_qing - g_phzHuxi.s_xiao),res.tiHuCombi)
                    res.isCanTing = true
                end
            end
        end
    end
     return res
end

function TingpaiLogic.GetNewconnectCombis(combione,combitwo)
    local tempCombi = table.clone(combione)
    for i,v in ipairs(combitwo) do
        tempCombi[#tempCombi + 1] = v
    end
    return tempCombi or {}
end

function TingpaiLogic.kindPaiBuTiPai(handPokers,res_ting_hu,xiaoQiang,kindNum,huxi,headcombi)
    local res = TingpaiLogic.newTingPaiResStruct()
    if #xiaoQiang == 0 then
        return res
    end
    local temphandpokers = table.clone(handPokers)
    local xiaoPaiValue = {}
    table.sort(temphandpokers)
    for _index,paiCombi in ipairs(xiaoQiang) do
        if #paiCombi == 3 then
            if TingpaiLogic.getPaiType(paiCombi[1]) == 1 then
                xiaoPaiValue[#xiaoPaiValue + 1] = paiCombi[1]
            else
                xiaoPaiValue[#xiaoPaiValue + 1] = paiCombi[1]
            end
        end
    end
    local kindStartPos = #handPokers - kindNum + 1   --王赖开始下标，这样用，handpokers必须是升序，kindpaivalue大于其他牌值
    for _index, paivalue in ipairs(xiaoPaiValue) do
        if kindNum > 0 then
            temphandpokers[kindStartPos] = paivalue
            kindNum = kindNum - 1
            kindStartPos = kindStartPos + 1
            local tempRet = TingpaiLogic.getTingPaiList(temphandpokers,res_ting_hu,huxi,headcombi)
            TingpaiLogic.updateTingPaiResStruct(res,tempRet)
            if tempRet.isCanTing == false then    --如果一个王替一个提不能胡替2个肯定也不行了
                break
            end
        end
    end
    return res
end

function TingpaiLogic.getKindPai_ting_hu(handpokers,res_ting_hu, kindNum, tempHuxi,headcombi)
    local handSize = #handpokers + kindNum;
	if handSize % 3 == 1 then    --单钓
        if kindNum == 1 then
            return TingpaiLogic.DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        elseif kindNum == 2 then
            return TingpaiLogic.DTwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        elseif kindNum == 3 then
            return TingpaiLogic.DThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        elseif kindNum == 4 then
            return TingpaiLogic.DFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        end

    else
        if kindNum == 1 then
            return TingpaiLogic.SOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        elseif kindNum == 2 then
            return TingpaiLogic.STwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        elseif kindNum == 3 then
            return TingpaiLogic.SThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        elseif kindNum == 4 then
            return TingpaiLogic.SFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
        end
    end
end

function TingpaiLogic.DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    headcombi[#headcombi + 1] = {}
    for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
        headcombi[#headcombi] = {paiValue}
        TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi,headcombi)
    end
    local res = TingpaiLogic.newTingPaiResStruct()
    res.isCanTing = true
    return res
end

function TingpaiLogic.DTwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    --王 王  一 一 一 二 三 四   五 六  王是2个，到这里手牌数肯定是模除3余2
	local tempChuTing = {}
	local type = {0,0}
	local value = {0,0}
    local res = TingpaiLogic.newTingPaiResStruct()
	for i = 1, #handpokers do
		type[i] = TingpaiLogic.getPaiType(handpokers[i])
		value[i] = TingpaiLogic.getPaiValue(handpokers[i])
    end
    TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, 1, 2, 0,{})
    local size = 0
    local maxTempHuxi = -1
    local maxKindTipai = 0
    for i,v in pairs(tempChuTing) do
        size = 1
        if v[TingpaiLogic.resIndex.huxi] > maxTempHuxi then
            maxTempHuxi = v[TingpaiLogic.resIndex.huxi]
            maxKindTipai = i
        end
    end

	if size > 0 then
        handpokers[#handpokers + 1] = maxKindTipai
        table.sort(handpokers)
        headcombi[#headcombi + 1] = handpokers
        headcombi[#headcombi + 1] = {}
        --一个赖子可以解决一对就单挑所以牌
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            headcombi[#headcombi][1] = paiValue
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + maxTempHuxi,headcombi)
        end
        res.isCanTing = true
	else
        headcombi[#headcombi + 1] = {}
		local temComs1 = {handpokers[2]}
		local temComs2 = {handpokers[1]}
        headcombi[#headcombi] = {handpokers[1],handpokers[1]}  --一个赖子和一个牌作将，剩一张牌 一个赖
        TingpaiLogic.SOneKindPaiTingRes(temComs1,res_ting_hu,tempHuxi,headcombi)
        headcombi[#headcombi] = {handpokers[2],handpokers[2]}
        TingpaiLogic.SOneKindPaiTingRes(temComs2,res_ting_hu,tempHuxi,headcombi)
        res.isCanTing = true
    end
    return res
end

function TingpaiLogic.DThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    --王 王 王 一 一 一 二 三 四 五  王是3个，到这里手牌数肯定是模除3余1
	local handSize = #handpokers
	local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
	local type = 0
    local res = TingpaiLogic.newTingPaiResStruct()
    if handSize == 1 then
        headcombi[#headcombi + 1] = {}
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            headcombi[#headcombi][1] = paiValue
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type],headcombi)
        end
        res.isCanTing = true
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
        headcombi[#headcombi + 1] = {}
        headcombi[#headcombi + 1] = {}

		for i,comb in ipairs(indexValue) do
			local tempChuTing1 = {} 
			local tempChuTing2 = {}
			TingpaiLogic.setChuTingCard(handpokers, tempChuTing1, value, type, comb[1], comb[2], 0,{});
            TingpaiLogic.setChuTingCard(handpokers, tempChuTing2, value, type, comb[3], comb[4], 0,{});
            local size1 = 0
            local maxTempHuxi1 = -1
            local maxKindtiPai1 = 0
            local size2 = 0
            local maxTempHuxi2 = -1
            local maxKindtiPai2 = 0
            for ting1,hu1 in pairs(tempChuTing1) do
                size1 = 1
                if hu1[TingpaiLogic.resIndex.huxi] > maxTempHuxi1 then
                    maxTempHuxi1 = hu1[TingpaiLogic.resIndex.huxi]
                    maxKindtiPai1 = ting1
                end
            end
            for ting2,hu2 in pairs(tempChuTing2) do
                size2 = 1
                if hu2[TingpaiLogic.resIndex.huxi] > maxTempHuxi2 then
                    maxTempHuxi2 = hu2[TingpaiLogic.resIndex.huxi]
                    maxKindtiPai2 = ting2
                end
            end

            if size1 > 0 and size2 > 0 then     --能解决2对 剩一张赖子听所有牌
                headcombi[#headcombi + 1] = {}
                headcombi[#headcombi - 2] = {handpokers[comb[1]], handpokers[comb[2]],maxKindtiPai1}
                headcombi[#headcombi - 1] = {handpokers[comb[3]], handpokers[comb[4]],maxKindtiPai2}
                for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
                    headcombi[#headcombi][1] = paiValue
                    TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + maxTempHuxi1 + maxTempHuxi2,headcombi)
                end
                res.isCanTing = true
                table.remove(headcombi,#headcombi)
            end

            if size1 > 0 then
                headcombi[#headcombi - 1] = {handpokers[comb[1]], handpokers[comb[2]],maxKindtiPai1}
                local temComs1 = {handpokers[comb[4]]}
                local temComs2 = {handpokers[comb[3]]}
                headcombi[#headcombi] = {handpokers[comb[3]],handpokers[comb[3]]}
                TingpaiLogic.SOneKindPaiTingRes(temComs1,res_ting_hu,tempHuxi,headcombi)
                headcombi[#headcombi] = {handpokers[comb[4]],handpokers[comb[4]]}
                TingpaiLogic.SOneKindPaiTingRes(temComs2,res_ting_hu,tempHuxi,headcombi)
                res.isCanTing = true
            end
			if size2 > 0 then
                headcombi[#headcombi - 1] = {handpokers[comb[3]], handpokers[comb[4]],maxKindtiPai2}
                local temComs1 = {handpokers[comb[2]]}
                local temComs2 = {handpokers[comb[1]]}
                headcombi[#headcombi] = {handpokers[comb[1]],handpokers[comb[1]]}
                TingpaiLogic.SOneKindPaiTingRes(temComs1,res_ting_hu,tempHuxi,headcombi)
                headcombi[#headcombi] = {handpokers[comb[2]],handpokers[comb[2]]}
                TingpaiLogic.SOneKindPaiTingRes(temComs2,res_ting_hu,tempHuxi,headcombi)
                res.isCanTing = true
            end
        end
    end
    return res
end

function TingpaiLogic.DFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    --王 王 王 王 一 一 一 二 三 四  王是4个，到这里手牌数肯定是模除3余0
	local handSize = #handpokers
	local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
    local res = TingpaiLogic.newTingPaiResStruct()
	local type = 0
    if handSize == 0 then
        TingpaiLogic.DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi + tempTypeHuxi[2] )
        res.isCanTing = true
    elseif handSize == 3 then
        local indexValue = --三张组合 打出一张单挑情况
		{
			{1,2,3},
			{1,3,2},
			{2,3,1}
		}

		local type = {0,0,0}
		local value = {0,0,0}
        headcombi[#headcombi + 1] = {}
        headcombi[#headcombi + 1] = {}
        headcombi[#headcombi + 1] = {}

        for i = 1, #handpokers do
			type[i] = TingpaiLogic.getPaiType(handpokers[i])
			value[i] = TingpaiLogic.getPaiValue(handpokers[i])
        end

		for i,comb in ipairs(indexValue) do
			local tempChuTing = {}
            TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, comb[1], comb[2], 0)
            local size = 0
            local maxTempHuxi = -1
            local maxKindtiPai = 0
            for ting,hu in pairs(tempChuTing) do
                size = 1
                if hu[TingpaiLogic.resIndex.huxi] > maxTempHuxi then
                    maxTempHuxi = hu[TingpaiLogic.resIndex.huxi]
                    maxKindtiPai = ting
                end
            end
			if size > 0 then
                headcombi[#headcombi - 2] = { handpokers[comb[1]], handpokers[comb[2]],maxKindtiPai}
                headcombi[#headcombi - 1] = { handpokers[comb[3]], handpokers[comb[3]],handpokers[comb[3]]}
                for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
                    headcombi[#headcombi] = {paiValue}
                    TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + maxTempHuxi + tempTypeHuxi[type[comb[3]]],headcombi)
                end
			end
            headcombi[#headcombi - 2] = { handpokers[comb[1]], handpokers[comb[1]],handpokers[comb[1]]}
            headcombi[#headcombi - 1] = { handpokers[comb[2]], handpokers[comb[2]],handpokers[comb[2]]}
            headcombi[#headcombi] = { handpokers[comb[3]]}
			TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[comb[3]], tempHuxi + tempTypeHuxi[type[comb[1]]] + tempTypeHuxi[type[comb[2]]],headcombi)
		end
        res.isCanTing = true
    elseif handSize == 6 then
        local kindNum = 3
		local tempHandPoker = table.clone(handpokers)
		local markTempl = TingpaiLogic.getmarkTempl(tempHandPoker)
        if #markTempl >= kindNum then
            tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi,headcombi)
        end
    end
    return res
end

function TingpaiLogic.SOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,_headcombi)
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
	--到这肯定是 1张王 和 剩一张牌
	local type = TingpaiLogic.getPaiType(handpokers[1])
	local value = TingpaiLogic.getPaiValue(handpokers[1])
    local headcombi = table.clone(_headcombi)
    headcombi[#headcombi + 1] = {handpokers[1],0}

	if (value > 1) then
        headcombi[#headcombi][2] = handpokers[1] + 1      --value = 3 听 2 补 4
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] - 1, tempHuxi,headcombi)
    end

	if (value > 2) then
        headcombi[#headcombi][2] = handpokers[1] - 1      --value = 3 听 1 补 2
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] - 2, tempHuxi,headcombi)
    end

	if (value < 10) then
        headcombi[#headcombi][2] = handpokers[1] + 2      --value = 3 听 4 补 5
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] + 1, tempHuxi,headcombi)
    end

	if (value < 9) then
        headcombi[#headcombi][2] = handpokers[1] + 1      --value = 3 听 5 补 4
		TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] + 2, tempHuxi,headcombi)
    end

	--看能否听二七十
	if (value == 2) then
        headcombi[#headcombi][2] = type * 100 + 10              --value = 2 听 7 补 10
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 7, tempHuxi + tempTypeHuxi[type],headcombi)
        headcombi[#headcombi][2] = type * 100 + 7              --value = 2 听 10 补 7
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 10, tempHuxi + tempTypeHuxi[type],headcombi)
	elseif (value == 7) then
        headcombi[#headcombi][2] = type * 100 + 10              --value = 7 听 2 补 10
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 2, tempHuxi + tempTypeHuxi[type],headcombi)
        headcombi[#headcombi][2] = type * 100 + 2              --value = 7 听 10 补 2
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 10, tempHuxi + tempTypeHuxi[type],headcombi)
	elseif (value == 10) then
        headcombi[#headcombi][2] = type * 100 + 7              --value = 10 听 2 补 7
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 2, tempHuxi + tempTypeHuxi[type],headcombi)
        headcombi[#headcombi][2] = type * 100 + 2              --value = 10 听 7 补 2
		TingpaiLogic.setTing_huValue(res_ting_hu, type * 100 + 7, tempHuxi + tempTypeHuxi[type],headcombi)
    end

    headcombi[#headcombi][2] = handpokers[1]              --value = 3 听 3 补 3
    TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1], tempHuxi + tempTypeHuxi[type],headcombi)
    if (type == 1) then
        TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] + 100, tempHuxi,headcombi)
    else
        TingpaiLogic.setTing_huValue(res_ting_hu, handpokers[1] - 100, tempHuxi,headcombi)
    end
    local res = TingpaiLogic.newTingPaiResStruct()
    res.isCanTing = true
    res.isCantihu = true
    res.maxTempHuxi = tempHuxi
    res.tiHuCombi = headcombi
    return res
end

function TingpaiLogic.STwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    local handSize = #handpokers
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
    local res = TingpaiLogic.newTingPaiResStruct()
    if handSize == 0 then
        headcombi[#headcombi + 1] = {0,0}
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            local type = TingpaiLogic.getPaiType(paiValue)
            headcombi[#headcombi][1] = paiValue
            headcombi[#headcombi][2] = paiValue
            TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type],headcombi)
        end
        return { isCanTing = true,isCantihu = true, maxTempHuxi = tempHuxi,tiHuCombi = headcombi }
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
        headcombi[#headcombi + 1] = {}
		for i,comb in ipairs(indexValue) do
			local tempChuTing = {}
            TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, comb[1], comb[2], 0,{})
            local maxTempHuxi = -1
            local maxKindtiPai = 0
            local size = 0
            for ting,hu in pairs(tempChuTing) do
                if hu[TingpaiLogic.resIndex.huxi] > maxTempHuxi then
                    maxTempHuxi = hu[TingpaiLogic.resIndex.huxi]
                    maxKindtiPai = ting
                end
                size = 1
            end

			if (size > 0) then
                headcombi[#headcombi] = {handpokers[comb[1]], handpokers[comb[2]],maxKindtiPai}
				local temp ={ handpokers[comb[3]] }
				local tempRet = TingpaiLogic.SOneKindPaiTingRes(temp, res_ting_hu, tempHuxi + maxTempHuxi,headcombi)
                TingpaiLogic.updateTingPaiResStruct(res,tempRet)
            end
		end
    end

    return res
end

function TingpaiLogic.SThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    local tempTypeHuxi = { g_phzHuxi.s_xiao,g_phzHuxi.b_xiao}
    local handSise = #handpokers
    local type = {}
	local value = {}

    for  i = 1, #handpokers do
        type[#type + 1] = TingpaiLogic.getPaiType(handpokers[i])
        value[#value + 1] = TingpaiLogic.getPaiType(handpokers[i])
    end
    if handSise == 2 then
        headcombi[#headcombi + 1] = {}
        headcombi[#headcombi + 1] = {}

        local tempChuTing = {}
        TingpaiLogic.setChuTingCard(handpokers, tempChuTing, value, type, 1, 2, 0,{})
        local size = 0
        local maxTempHuxi = -1
        local maxKindtiPai = 0
        for ting,hu in pairs(tempChuTing) do
            if hu[TingpaiLogic.resIndex.huxi] > maxTempHuxi then
                maxTempHuxi = hu[TingpaiLogic.resIndex.huxi]
                maxKindtiPai = ting
            end
            size = 1
        end

		if (size > 0) then
            headcombi[#headcombi - 1] = {handpokers[1],handpokers[2],maxKindtiPai}
			for i,paiValue in ipairs (TingpaiLogic.AllPaiValue) do
				local temptype = TingpaiLogic.getPaiType(paiValue)
                headcombi[#headcombi] = {paiValue,paiValue}
                TingpaiLogic.setTing_huValue(res_ting_hu, paiValue, tempHuxi + maxTempHuxi + tempTypeHuxi[temptype],headcombi)
            end
		end
        table.remove(headcombi,#headcombi)
		local tempHand1 = {handpokers[2]}
		local tempHand2 = {handpokers[1]}
        headcombi[#headcombi] = {handpokers[1],handpokers[1],handpokers[1]}
		TingpaiLogic.SOneKindPaiTingRes(tempHand1, res_ting_hu, tempHuxi + tempTypeHuxi[type[1]],headcombi)
        headcombi[#headcombi] = {handpokers[2],handpokers[2],handpokers[2]}
		TingpaiLogic.SOneKindPaiTingRes(tempHand2, res_ting_hu, tempHuxi + tempTypeHuxi[type[2]],headcombi)

        if tempTypeHuxi[type[1]] > tempTypeHuxi[type[2]] then
            headcombi[#headcombi] = {handpokers[1],handpokers[1],handpokers[1]}
            headcombi[#headcombi + 1] = {handpokers[2],handpokers[2]}
            maxTempHuxi = tempTypeHuxi[type[1]]
        else
            headcombi[#headcombi] = {handpokers[2],handpokers[2],handpokers[2]}
            headcombi[#headcombi + 1] = {handpokers[1],handpokers[1]}
            maxTempHuxi = tempTypeHuxi[type[2]]
        end
        return {isCanTing = true,isCantihu = true, maxTempHuxi = tempHuxi + maxTempHuxi,tiHuCombi = headcombi}

    elseif handSise == 5 then
        local kindNum = 2
		local tempHandPoker = table.clone(handpokers)
		local markTempl = TingpaiLogic.getmarkTempl(tempHandPoker)
		if (#markTempl >= kindNum) then
            tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi,headcombi)
        end
    end
    return TingpaiLogic.newTingPaiResStruct()
end

function TingpaiLogic.SFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi,headcombi)
    --四张王 剩 1 4 7
    local tempTypeHuxi = {g_phzHuxi.s_qing,g_phzHuxi.b_qing}
    local handSise = #handpokers

    local type = {}
	local value = {}

    for  i = 1, #handpokers do
        type[#type + 1] = TingpaiLogic.getPaiType(handpokers[i])
        value[#value + 1] = TingpaiLogic.getPaiType(handpokers[i])
    end

    local tempHandPoker = table.clone(handpokers)
    local markTempl = TingpaiLogic.getmarkTempl(tempHandPoker)
    
    if handSise == 1 then
        headcombi[#headcombi + 1] = {g_phzCards.kind_CardValue,g_phzCards.kind_CardValue,g_phzCards.kind_CardValue}
        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do
            TingpaiLogic.SOneKindPaiTingRes({paiValue},res_ting_hu,tempHuxi + g_phzHuxi.b_xiao,headcombi)
        end
        headcombi[#headcombi] = {handpokers[1],handpokers[1]}
        headcombi[#headcombi + 1] = {0,0,0}

        for i,paiValue in ipairs(TingpaiLogic.AllPaiValue) do            --这里可以提胡所有牌
            headcombi[#headcombi][1] = paiValue
            headcombi[#headcombi][2] = paiValue
            headcombi[#headcombi][3] = paiValue
            local type = TingpaiLogic.getPaiType(paiValue)
            TingpaiLogic.setTing_huValue(res_ting_hu,paiValue,tempHuxi + tempTypeHuxi[type],headcombi)
        end

        return {isCanTing = true,isCantihu = false, maxTempHuxi = tempHuxi + tempTypeHuxi[2],tiHuCombi = headcombi} --已经提胡所有牌了这里就没必要返回true了
    elseif handSise == 4 then
        local kindNum = 2
        tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
        tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
		if (#markTempl >= kindNum) then
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi,headcombi)
		elseif (#markTempl >= kindNum - 1) then
            tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 1, tempHuxi,headcombi)
        end
    elseif handSise == 7 then
        local kindNum = 3
        tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
		if #markTempl >= kindNum then
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi,headcombi)
		elseif (#markTempl >= kindNum - 1) then
            tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 1, tempHuxi,headcombi)
		elseif (#markTempl >= kindNum - 2) then
            tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
            tempHandPoker[#tempHandPoker + 1] = g_phzCards.kind_CardValue
			return TingpaiLogic.markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 2, tempHuxi,headcombi)
        end
    end
    return TingpaiLogic.newTingPaiResStruct()
end

function TingpaiLogic.markDnfTingCard(markTempl,tempHandPoker,res_ting_hu,kindNum,tempHuxi,headcombi)
    local kindCombis = TingpaiLogic.combinationMarkTempList(markTempl, kindNum)

    local tingRet = TingpaiLogic.newTingPaiResStruct()
    for k = 1, kindNum do
        tempHandPoker[#tempHandPoker + 1] = 0
    end
	local handSize = #tempHandPoker
	for j = 1, #kindCombis do
		local kindSize = #kindCombis[j]
		for Q = 1, kindSize do
			tempHandPoker[handSize - Q + 1] = kindCombis[j][Q]
        end
        local tempRet = TingpaiLogic.getTingPaiList(tempHandPoker, res_ting_hu, tempHuxi,headcombi)
        TingpaiLogic.updateTingPaiResStruct(tingRet,tempRet)
	end
    return tingRet
end

function TingpaiLogic.replaceKindPaiDnfTingpai(handpokers,res_ting_hu,kindNum,tempHuxi,headcombi)
    local markTempList = TingpaiLogic.getmarkTempl(handpokers)
    local tempHandPoker = table.clone(handpokers)
    local tingRet = TingpaiLogic.newTingPaiResStruct()
    local kindCombis = {}
    if #markTempList >= kindNum then
        kindCombis = TingpaiLogic.combinationMarkTempList(markTempList, kindNum)
    end

    for k = 1, kindNum do
        tempHandPoker[#tempHandPoker + 1] = 0
    end

    if #kindCombis > 0 then
        local handSize = #tempHandPoker
        for j = 1, #kindCombis do
            local kindSize = #kindCombis[j]
            for Q = 1, kindSize do
                tempHandPoker[handSize - Q + 1] = kindCombis[j][Q]
            end
            local tempRet = TingpaiLogic.getTingPaiList(tempHandPoker, res_ting_hu, tempHuxi,headcombi)
            TingpaiLogic.updateTingPaiResStruct(tingRet,tempRet)
        end
    end

    if kindNum > 1 and tingRet.isCanTing then
        local handSize = #tempHandPoker
        for j = 1, #handpokers do
            local kindSize = 2
            for Q = 1, kindSize do
                tempHandPoker[handSize - Q + 1] = tempHandPoker[j]
            end
            for kStart = kindSize + 1,kindNum do
                tempHandPoker[handSize - kStart + 1] = g_phzCards.kind_CardValue
            end
            local tempRet = TingpaiLogic.getTingPaiList(tempHandPoker, res_ting_hu, tempHuxi,headcombi)
            TingpaiLogic.updateTingPaiResStruct(tingRet,tempRet)
        end
    end

    return tingRet
end

function TingpaiLogic.getmarkTempl(handpokers)
    local markTempl = {}
	local pai_count = {}
    local possibilityHus = {}
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
            
                if (pai_count[type * 100 + 2] == 1 and pai_count[type * 100 + 3] == nil) then--101 102 补 103

                    markTempl[type * 100 + 3] = 1
                
                elseif (pai_count[type * 100 + 3] == 1 and pai_count[type * 100 + 2] == nil) then--101 103 补 102
                
                    markTempl[type * 100 + 2] = 1
                end
            
            elseif (value == 2) then
            
                if (pai_count[type * 100 + 7] == 1 and pai_count[type * 100 + 10] == nil) then -- 2 7 补 10
                
                    markTempl[type * 100 + 10] = 1
                
                elseif (pai_count[type * 100 + 10] == 1 and pai_count[type * 100 + 7] == nil) then -- 2 10 补 7
                
                    markTempl[type * 100 + 7] = 1
                
                elseif (pai_count[type * 100 + 1] == 1 and pai_count[type * 100 + 3] == nil) then -- 2 1 补 3
                
                    markTempl[type * 100 + 3] = 1
                
                elseif (pai_count[type * 100 + 3] == 1 and pai_count[type * 100 + 1] == nil) then -- 2 3 补 1
                
                    markTempl[type * 100 + 1] = 1
                
                elseif (pai_count[type * 100 + 3] == 1 and pai_count[type * 100 + 4] == nil) then -- 2 3 补 4
                
                    markTempl[type * 100 + 4] = 1
                
                elseif (pai_count[type * 100 + 4] == 1 and pai_count[type * 100 + 3] == nil) then -- 2 4 补 3
                
                    markTempl[type * 100 + 3] = 1
                end
        
            elseif (value == 7) then
            
                if (pai_count[type * 100 + 2] == 1 and pai_count[type * 100 + 10] == nil) then -- 7 2 补 10
                
                    markTempl[type * 100 + 10] = 1
                
                elseif (pai_count[type * 100 + 10] == 1 and pai_count[type * 100 + 2] == nil) then -- 7 10 补 2
                
                    markTempl[type * 100 + 2] = 1
                
                elseif (pai_count[type * 100 + 5] == 1 and pai_count[type * 100 + 6] == nil) then -- 7 5 补 6
                
                    markTempl[type * 100 + 6] = 1
                
                elseif (pai_count[type * 100 + 6] == 1 and pai_count[type * 100 + 5] == nil) then -- 7 6 补 5

                    markTempl[type * 100 + 5] = 1

                elseif (pai_count[type * 100 + 6] == 1 and pai_count[type * 100 + 8] == nil) then -- 7 6 补 8

                    markTempl[type * 100 + 8] = 1

                elseif (pai_count[type * 100 + 8] == 1 and pai_count[type * 100 + 6] == nil) then -- 7 8 补 6

                    markTempl[type * 100 + 6] = 1
                
                elseif (pai_count[type * 100 + 8] == 1 and pai_count[type * 100 + 9] == nil) then -- 7 8 补 9
                
                    markTempl[type * 100 + 9] = 1
                
                elseif (pai_count[type * 100 + 9] == 1 and pai_count[type * 100 + 8] == nil) then -- 7 9 补 8
                
                    markTempl[type * 100 + 8] = 1
                end
            
            elseif (value == 9) then
            
                if (pai_count[handpokers[i] - 2] == 1 and pai_count[handpokers[i] - 1] == nil) then --9 7 补 8
                
                    markTempl[handpokers[i] - 1] = 1

                elseif (pai_count[handpokers[i] - 1] == 1 and pai_count[handpokers[i] - 2] == nil) then -- 9 8 补 7
                
                    markTempl[handpokers[i] - 2] = 1
                
                elseif (pai_count[handpokers[i] - 1] == 1 and pai_count[handpokers[i] + 1] == nil) then -- 9 8 补 10
                
                    markTempl[handpokers[i] + 1] = 1
                end
            
            elseif (value == 10) then
            
                if (pai_count[type * 100 + 2] == 1 and pai_count[type * 100 + 7] == nil) then -- 10 2 补 7
                
                    markTempl[type * 100 + 7] = 1
                
                elseif (pai_count[type * 100 + 7] == 1 and pai_count[type * 100 + 2] == nil) then -- 10 7 补 2
                
                    markTempl[type * 100 + 2] = 1
                
                elseif (pai_count[type * 100 + 8] == 1 and pai_count[type * 100 + 9] == nil) then -- 10 8 补 9
                
                    markTempl[type * 100 + 9] = 1
                
                elseif (pai_count[type * 100 + 9] == 1 and pai_count[type * 100 + 8] == nil) then -- 10 9 补 8
                
                    markTempl[type * 100 + 8] = 1
                end
            
            else
                --假设value == 6
                if (pai_count[handpokers[i] - 2] == 1 and pai_count[handpokers[i] - 1] == nil) then --6 4 补 5
                
                    markTempl[handpokers[i] - 1] = 1
                
                elseif (pai_count[handpokers[i] - 1] == 1 and pai_count[handpokers[i] - 2] == nil) then -- 6 5 补 4
                
                    markTempl[handpokers[i] - 2] = 1

                elseif (pai_count[handpokers[i] - 1] == 1 and pai_count[handpokers[i] + 1] == nil) then -- 6 5 补 7

                    markTempl[handpokers[i] + 1] = 1

                elseif (pai_count[handpokers[i] + 1] == 1 and pai_count[handpokers[i] - 1] == nil) then -- 6 7 补 5

                    markTempl[handpokers[i] - 1] = 1
                
                elseif (pai_count[handpokers[i] + 2] == 1 and pai_count[handpokers[i] + 1] == nil) then -- 6 8 补 7
                
                    markTempl[handpokers[i] + 1] = 1
                
                elseif (pai_count[handpokers[i] + 1] == 1 and pai_count[handpokers[i] + 2] == nil) then -- 6 7 补 8
                
                    markTempl[handpokers[i] + 2] = 1
                end
            end
        end
	end

	for cardValue,count in pairs(markTempl) do
        possibilityHus[#possibilityHus + 1] = cardValue
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

function TingpaiLogic.getchuTingPairByTwo(combi,resChu_ting,pubicHuxi,headcombi)   --没跑起的情况下，手里会省2张牌做门子
    local comSize = #combi
    local type = {}
    local value = {}
    table.sort(combi)
    for i,v in ipairs(combi) do
        type[i] = TingpaiLogic.getPaiType(combi[i])
		value[i] = TingpaiLogic.getPaiValue(combi[i])
    end
    return TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, 1, 2, pubicHuxi,headcombi)
end

function TingpaiLogic.getchuTingPairByOne(combi,resChu_ting,pubicHuxi,headcombi)
    headcombi[#headcombi + 1] = combi
    TingpaiLogic.setTing_huValue(resChu_ting,combi[1],pubicHuxi,headcombi)
    return true
end

function TingpaiLogic.getchuTingPairByFour(combi,resChu_ting,pubicHuxi,headcombi) --跑起来了，要一对将牌
    local comSize = #combi
	local type = {}
	local value = {}
	table.sort( combi )
    local isTing = false
	for  i = 1, comSize do
		type[i] = TingpaiLogic.getPaiType(combi[i])
		value[i] = TingpaiLogic.getPaiValue(combi[i])
    end
    headcombi[#headcombi + 1] = {0,0}
	if (type[1] == type[2] and value[1] == value[2]) then
        headcombi[#headcombi][1] = combi[1]
        headcombi[#headcombi][2] = combi[2]
        local tempisTing = TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, 3, 4, pubicHuxi,headcombi)
        isTing = isTing or tempisTing
    end
	if type[3] == type[4] and value[3] == value[4] then
        headcombi[#headcombi][1] = combi[3]
        headcombi[#headcombi][2] = combi[4]
        local tempisTing = TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, 1, 2, pubicHuxi,headcombi)
        isTing = isTing or tempisTing
    end

	local indexValue =   --三张组合 打出一张单挑情况
	{
		{1,2,3,4},
		{1,2,4,3},
		{1,3,4,2},
		{2,3,4,1}
	}
    
	local firstIndex
    headcombi[#headcombi][#headcombi[#headcombi] + 1] = 0
    headcombi[#headcombi + 1] = {0}
	for  i = 1, #indexValue do
	
		if (TingpaiLogic.isVaildCombi({ combi[indexValue[i][1]],combi[indexValue[i][2]], combi[indexValue[i][3]] })) then
            headcombi[#headcombi - 1][1] =  combi[indexValue[i][1]]
            headcombi[#headcombi - 1][2] =  combi[indexValue[i][2]]
            headcombi[#headcombi - 1][3] =  combi[indexValue[i][3]]
            headcombi[#headcombi][1] =  combi[indexValue[i][4]]
 			--既然剩1张 就单钓呗
			local tempHufen = 0
            if type[indexValue[i][1]] == type[indexValue[i][2]] and type[indexValue[i][2]] == type[indexValue[i][3]] then --这里考虑加胡系
                if value[indexValue[i][1]] == 1 and value[indexValue[i][2]] == 2 and value[indexValue[i][3]] == 3 then
                    if (type[indexValue[i][1]] == 1) then
                        tempHufen = g_phzHuxi.s_chi
                    else
                        tempHufen = g_phzHuxi.b_chi
                    end
                elseif value[indexValue[i][1]] == 2 and value[indexValue[i][2]] == 7 and value[indexValue[i][3]] == 10 then
                    if (type[indexValue[i][1]] == 1) then
                        tempHufen = g_phzHuxi.s_chi
                    else
                        tempHufen = g_phzHuxi.b_chi
                    end
                end

            end
            firstIndex = indexValue[i][4]
            TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex],pubicHuxi + tempHufen,headcombi)
            isTing = true
		end
    end
    return isTing
end

function TingpaiLogic.setTing_huValue(resChu_ting,ting,huxi,headcombi)
    if resChu_ting[ting] == nil then
        resChu_ting[ting] = {}
        resChu_ting[ting][TingpaiLogic.resIndex.huxi] = huxi
        resChu_ting[ting][TingpaiLogic.resIndex.combi] = {}
        resChu_ting[ting][TingpaiLogic.resIndex.combi] = table.clone(headcombi)
    end

    if huxi > resChu_ting[ting][TingpaiLogic.resIndex.huxi] then
        resChu_ting[ting][TingpaiLogic.resIndex.huxi] = huxi
        resChu_ting[ting][TingpaiLogic.resIndex.combi] = table.clone(headcombi)
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
function TingpaiLogic.setChuTingCard(combi, resChu_ting, value, type, firstIndex, scondIndex, pubicHuxi,headcombi)
    local tempNewHeadCombi = {}
    local isTing = false
    tempNewHeadCombi = table.clone(headcombi) --python_hulue 本行做忽略
    tempNewHeadCombi[#tempNewHeadCombi + 1] = {combi[firstIndex],combi[scondIndex]}
    if combi[firstIndex] - combi[scondIndex] == -1 then
		if (value[firstIndex] ~= 1) then
			if (value[firstIndex] - 1 == 1) then                   --听的是1
                if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                    isTing = true
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi + g_phzHuxi.b_chi,tempNewHeadCombi)
                    isTing = true
                end
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 1,pubicHuxi,tempNewHeadCombi)
                 isTing = true
            end
        end

		if (value[scondIndex] ~= 10) then
		
			if (value[scondIndex] + 1 == 3) then           --听的是3
				if (type[scondIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                    isTing = true
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi + g_phzHuxi.b_chi,tempNewHeadCombi)
                    isTing = true
                end
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 1,pubicHuxi,tempNewHeadCombi)
                isTing = true
            end
        end

	elseif (combi[firstIndex] - combi[scondIndex] == -2) then
	
		if (value[firstIndex] + 1 == 2) then                 --听的是2
            if (type[firstIndex] == 1) then
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                isTing = true
            else
                TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi + g_phzHuxi.b_chi,tempNewHeadCombi)
                isTing = true
            end
		
		else
            TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 1,pubicHuxi,tempNewHeadCombi)
            isTing = true
        end
	
	elseif (value[firstIndex] == value[scondIndex]) then
        TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 100,pubicHuxi,tempNewHeadCombi)
        TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 200,pubicHuxi,tempNewHeadCombi)
        isTing = true
        if type[firstIndex] == type[scondIndex] then
            if type[scondIndex] == 2 then 
                TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 200,pubicHuxi + g_phzHuxi.b_xiao ,tempNewHeadCombi)
            else        
                TingpaiLogic.setTing_huValue(resChu_ting,value[firstIndex] + 100,pubicHuxi + g_phzHuxi.s_xiao,tempNewHeadCombi)
            end 
        end
	
	else
        if (type[firstIndex] == type[scondIndex]) then
		
			if (value[firstIndex] == 2 and value[scondIndex] == 7) then
                if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 3,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                    isTing = true
                else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[scondIndex] + 3,pubicHuxi + g_phzHuxi.b_chi,tempNewHeadCombi)
                    isTing = true
                end
            
			elseif (value[firstIndex] == 2 and value[scondIndex] == 10) then
			
				if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 5,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                    isTing = true
				else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] + 5,pubicHuxi + g_phzHuxi.b_chi,tempNewHeadCombi)
                    isTing = true
                end
			
			elseif (value[firstIndex] == 7 and value[scondIndex] == 10) then
			
				if (type[firstIndex] == 1) then
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 5,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                    isTing = true
				else
                    TingpaiLogic.setTing_huValue(resChu_ting,combi[firstIndex] - 5,pubicHuxi + g_phzHuxi.s_chi,tempNewHeadCombi)
                    isTing = true
                end
			end
		end
    end
    return isTing
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
	while (left <= right) do
		if _handpokers[left] ~= tempVal or paiCount == 4 then
            if paiCount >= 3 then
                res[#res + 1] = {}
				delStartIndex = left - paiCount
                left = left - paiCount
				tmpPaicount = paiCount
                while paiCount > 0 do
                    table.insert(res[#res],_handpokers[delStartIndex])
                    table.remove(_handpokers,delStartIndex)
                    paiCount = paiCount - 1
                    right = right - 1
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

        res[#res + 1] = {}
        while paiCount > 0 do
            res[#res][#res[#res] + 1] = _handpokers[#_handpokers]
            table.remove(_handpokers,#_handpokers)
            paiCount = paiCount - 1
		end
	end

	return res
end

function TingpaiLogic.getValidComByHandpokers(handpokers)
	local pai_count = {}
	local retComs = {}
	for i,paiValue in ipairs(handpokers) do
        if pai_count[paiValue] == nil then
            pai_count[paiValue] = 1
        else
            pai_count[paiValue] = pai_count[paiValue] + 1
        end
    end
	local prePaivalue = 0
	for i,paiValue in ipairs(handpokers) do
		if prePaivalue ~= paiValue then
            prePaivalue = paiValue;
            if (TingpaiLogic.getPaiValue(paiValue) == 2) then     --二七十
            
                if (pai_count[paiValue] == 2 and pai_count[paiValue + 5] == 2 and pai_count[paiValue + 8] == 2) then
                    table.insert(retComs,{ paiValue, paiValue + 5, paiValue + 8})
                end

                if (pai_count[paiValue + 5] and pai_count[paiValue + 5] >= 1 and pai_count[paiValue + 8] and pai_count[paiValue + 8] >= 1) then
                    table.insert(retComs,{ paiValue, paiValue + 5, paiValue + 8})
                end
            end

            --顺子
            if (pai_count[paiValue] == 2) then
            
                local type = TingpaiLogic.getPaiType(paiValue);         --壹壹一
                if (type == 1) then
                    if (pai_count[paiValue + 100] and pai_count[paiValue + 100] > 0) then
                        table.insert(retComs,{ paiValue, paiValue, paiValue + 100})
                    end
                else
                
                    if (pai_count[paiValue - 100] and pai_count[paiValue - 100] > 0) then
                        table.insert(retComs,{ paiValue, paiValue, paiValue - 100})
                    end
                end

                if (pai_count[paiValue + 1] == 2 and pai_count[paiValue + 2] == 2) then
                    table.insert(retComs,{ paiValue, paiValue + 1, paiValue + 2})
                end
            end

            if (pai_count[paiValue + 1] and pai_count[paiValue + 1] >= 1 and pai_count[paiValue + 2] and pai_count[paiValue + 2] >= 1) then
                table.insert(retComs,{ paiValue, paiValue + 1, paiValue + 2})
            end
        end
	end
	return retComs
end


function TingpaiLogic.getAllCardCombi(handPokers,kindNum)
    local comsize = math.floor( (#handPokers + kindNum) / 3 ) - 1
    local tempNum = 1
    if (#handPokers + kindNum) % 3 == 2 or  (#handPokers + kindNum) % 3 == 0 then
        comsize = comsize + 1
        tempNum = 0
    end
    comsize = comsize - kindNum
    local vaildcombis = TingpaiLogic.getValidComByHandpokers(handPokers)--TingpaiLogic.combinationZhuhe(handPokers,3,TingpaiLogic.isVaildCombi)

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
    end

    for i,combis in ipairs(tempcombss) do
        local tempMenzi = TingpaiLogic.getMenzi(combis,handPokers)
        combis[#combis + 1] = tempMenzi
    end

    if ((kindNum * 2) + 4 >= #handPokers) then
        local tempHandPokers = {handPokers}
        tempcombss[#tempcombss + 1] = tempHandPokers
    end
    
    return tempcombss
end

function TingpaiLogic.getMenzi(combis,handpokers)
    local pai_Index = {}
    for i = 1,#handpokers do
        if pai_Index[handpokers[i]] == nil then
            pai_Index[handpokers[i]] = {}
        end
        pai_Index[handpokers[i]][#pai_Index[handpokers[i]] + 1] = i
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
                res[#res + 1] = handpokers[index]
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

--pai_Count 各个字牌数量用与过滤
function TingpaiLogic.combinationZhuheList(pai_Count,sumList, nComLen,retList) --获取有效手牌路径
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
                retList[#retList + 1] = nSumCount
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
            local key = ""
            for i = 2,nComLen+1 do
                nSumCount[i - 1] = sumList[nSumIndex[i]]
                key = key .. sumList[nSumIndex[i]]
            end

            retList[#retList + 1] = nSumCount

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