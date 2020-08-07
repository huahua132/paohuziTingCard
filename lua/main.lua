
package.path = package.path ..';..\\?.lua'
require 'TingpaiLogic'
require 'functions'
--print(package.path)

local paiLib =
{
    101,102,103,104,105,106,107,108,109,110,
    201,202,203,204,205,206,207,208,209,210,
    101,102,103,104,105,106,107,108,109,110,
    201,202,203,204,205,206,207,208,209,210,
    101,102,103,104,105,106,107,108,109,110,
    201,202,203,204,205,206,207,208,209,210,
    101,102,103,104,105,106,107,108,109,110,
    201,202,203,204,205,206,207,208,209,210
}
math.randomseed(os.time())
function randFapai(paiNum,kindNum)
    local tempLib = table.clone(paiLib)
    local function random_shuffle(paiLib)
        for i = 1,#paiLib do
            local randIndex = math.random(1,#paiLib)
            paiLib[i],paiLib[randIndex] = paiLib[randIndex],paiLib[i]
        end
    end
    random_shuffle(tempLib)

    local res = {}
    local randIndex = 0
    local size = #tempLib

    for i = 1,paiNum - kindNum do
        randIndex = math.random(1,size)
        table.insert(res,tempLib[randIndex])
        tempLib[randIndex],tempLib[size] = tempLib[size],tempLib[randIndex]
        size = size - 1
    end

    for i = 1, kindNum do
        table.insert(res,g_phzCards.kind_CardValue)
    end
    return res
end

--local handpoker = {555,102,103,104,201,202,203,204,205,206,208,208,208,210,210,110,107,107,207,203}
--local handpoker = {555,555,108,108,108,107,107,207,207,201}
--local handpoker = {555,103,103,209,209,206,207,208,108,108,108}
--local handpoker = {555,201,202,202,203,203,204,103,104,105,206,106,106,106,107,207,207,108,109,110}
-- local handpoker = randFapai(2,0)
-- --local handpoker = {201,205,109,108,203,204,208,207,107,110,106,102,101,201,108,103,555,555,555,555}

-- local preTime = os.time()
-- local ret_tingHu = {}
-- ret_tingHu = TingpaiLogic.getTingPaiRes(handpoker)
-- local nowTime = os.time()
-- print("user time :" .. nowTime - preTime)
-- print("handpokers:" .. table.concat(handpoker,','))

-- --Debug(ret_tingHu)
-- for tingpaiValue,item in pairs(ret_tingHu) do
--     local logStr = "cards:"
--     for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
--         logStr = logStr .. '[' .. table.concat(paicom,',') .. '] '
--     end
--     print(logStr .. "ting:" .. tingpaiValue .. " huxi:" .. item[TingpaiLogic.resIndex.huxi])
-- end
local card_num = 6
local file_name = 'ting_card_ret_' .. card_num .. '.lua'
local file = io.open(file_name,'a')

local function write_ting_pai_ret(hand_card)
    local ret_tingHu = TingpaiLogic.getTingPaiRes(hand_card)
    if next(ret_tingHu) then
        local write_str = ""
        local key = ""
        for _,card in ipairs(hand_card) do
            key = key .. card
        end
        write_str = write_str .. '[' .. key .. '] = {\n'
        local KK = 1
        for tingpaiValue,item in pairs(ret_tingHu) do
            write_str = write_str .. '[' .. KK ..'] = {'
            write_str = write_str .. "card_group = {"
            for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
                if next(paicom) then
                    write_str = write_str .. '{'
                    for card_i,card in ipairs(paicom) do
                        write_str = write_str .. card .. ','
                    end
                    write_str = write_str .. '},'
                end
            end
            write_str = write_str .. '},'
            write_str = write_str .. 'ting_pai_value = ' .. tingpaiValue .. ','
            write_str = write_str .. 'huxi = ' .. item[TingpaiLogic.resIndex.huxi] .. '},\n'
            KK = KK + 1
        end
        write_str = write_str .. '},\n'
        file:write(write_str)
    end
   
end

local function combinationMarkTempList(sumList, nComLen)
    nComLen = nComLen > #sumList and #sumList or nComLen
    local nSumIndex = {}
    for i = 1,nComLen+1 do
        nSumIndex[i] = i - 1
    end
    local key_filter = {}
    local flag = true
    local nPos = nComLen + 1

    while nSumIndex[1] == 0 do
        if flag then
            local nSumCount = {}
            local key = ''
            for i = 2,nComLen+1 do
                nSumCount[i - 1] = sumList[nSumIndex[i]]
                key = key .. sumList[nSumIndex[i]]
                
            end
            if not key_filter[key] then
                write_ting_pai_ret(nSumCount)
                key_filter[key] = true
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
end


file:write('return {\n')
combinationMarkTempList(paiLib,card_num)
file:write('}')
file:close()