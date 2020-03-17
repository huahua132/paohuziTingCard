
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
local handpoker = randFapai(20,4)
--local handpoker = {201,205,109,108,203,204,208,207,107,110,106,102,101,201,108,103,555,555,555,555}

local preTime = os.time()
local ret_tingHu = {}
ret_tingHu = TingpaiLogic.getTingPaiRes(handpoker)
local nowTime = os.time()
print("user time :" .. nowTime - preTime)
print("handpokers:" .. table.concat(handpoker,','))

--Debug(ret_tingHu)
for tingpaiValue,item in pairs(ret_tingHu) do
    local logStr = "cards:"
    for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
        logStr = logStr .. '[' .. table.concat(paicom,',') .. '] '
    end
    print(logStr .. "ting:" .. tingpaiValue .. " huxi:" .. item[TingpaiLogic.resIndex.huxi])
end