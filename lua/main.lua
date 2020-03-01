
package.path = package.path ..';..\\?.lua'
require 'TingpaiLogic'
--print(package.path)

-- @param object 要克隆的值
-- @return objectCopy 返回值的副本
--]]
function table.clone( object )
    local lookup_table = {}
    local function copyObj( object )
        if type( object ) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs( object ) do
            new_table[copyObj( key )] = copyObj( value )
        end
        return setmetatable( new_table, getmetatable( object ) )
    end
    return copyObj( object )
end

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
function randFapai(paiNum)
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

    for i = 1,paiNum do
        randIndex = math.random(1,size)
        table.insert(res,tempLib[randIndex])
        tempLib[randIndex],tempLib[size] = tempLib[size],tempLib[randIndex]
        size = size - 1
    end
    return res
end

--local handpoker = {555,102,103,104,201,202,203,204,205,206,208,208,208,210,210,110,107,107,207,203}
--local handpoker = {555,555,108,108,108,107,107,207,207,201}
--local handpoker = {555,103,103,209,209,206,207,208,108,108,108}
--local handpoker = {555,201,202,202,203,203,204,103,104,105,206,106,106,106,107,207,207,108,109,110}
local handpoker = randFapai(8)
table.insert(handpoker,555)
table.insert(handpoker,555)
table.insert(handpoker,555)

local ret_tingHu = {}
print("handpokers:" .. table.concat(handpoker,','))
local preTime = os.time()
ret_tingHu = TingpaiLogic.getTingPaiRes(handpoker)
local nowTime = os.time()

for tingpaiValue,item in pairs(ret_tingHu) do
    local logStr = "cards:"
    for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
        logStr = logStr .. '[' .. table.concat(paicom,',') .. '] '
    end
    print(logStr .. "ting:" .. tingpaiValue .. " huxi:" .. item[TingpaiLogic.resIndex.huxi])
end

print("user time :" .. nowTime - preTime)

--有错误的用例贴这
--handpokers:209,210,110,104,201,110,105,208,555,555,555