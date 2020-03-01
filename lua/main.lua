
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

--local handpoker = {555,102,103,104,201,202,203,204,205,206,208,208,208,210,210,110,107,107,207,203}
--local handpoker = {555,555,108,108,108,107,107,207,207,201}
local handpoker = {555,103,103,209,209,206,207,208,108,108,108}
local ret_tingHu = {}

local preTime = os.time()
TingpaiLogic.getTingPaiList(handpoker,ret_tingHu,0,{})
local nowTime = os.time()

for tingpaiValue,item in pairs(ret_tingHu) do
    local logStr = "cards:"
    for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
        logStr = logStr .. '[' .. table.concat(paicom,',') .. '] '
    end
    print(logStr .. "ting:" .. tingpaiValue .. " huxi:" .. item[TingpaiLogic.resIndex.huxi])
end

print("user time :" .. nowTime - preTime)
