
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

--local handpoker = {102,109,104,108,107,206,204,108,555,555,555}
local handpoker = randFapai(11,3)

local ret_tingHu = {}
print("handpokers:" .. table.concat(handpoker,','))
local preTime = os.time()
ret_tingHu = TingpaiLogic.getTingPaiRes(handpoker)
local nowTime = os.time()

--Debug(ret_tingHu)
 for tingpaiValue,item in pairs(ret_tingHu) do
     local logStr = "cards:"
     for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
         logStr = logStr .. '[' .. table.concat(paicom,',') .. '] '
     end
     print(logStr .. "ting:" .. tingpaiValue .. " huxi:" .. item[TingpaiLogic.resIndex.huxi])
 end

print("user time :" .. nowTime - preTime)
print("handpokers:" .. table.concat(handpoker,','))
--有错误的用例贴这
--handpokers:206,206,206,205,105,206,207,102,555,555,555
--handpokers:103,102,104,204,104,203,110,103,555,555,555
--handpokers:206,104,106,202,206,105,210,103,555,555,555
--handpokers:109,209,203,105,106,103,203,209,555,555,555
--handpokers:201,202,203,208,208,104,102,204,555,555,555
--handpokers:101,106,201,202,206,102,101,202,555,555,555
--handpokers:210,207,209,109,209,206,202,107,555,555,555 组合里面有空表 
--handpokers:202,108,108,204,105,106,108,207,555,555,555 组合里面有空表
--handpokers:202,102,104,109,209,204,106,104,555,555,555 组合里面有空表
--handpokers:101,110,110,101,210,203,209,209,555,555,555 组合里面有空表
--handpokers:102,109,104,108,107,206,204,108,555,555,555 组合里面有空表