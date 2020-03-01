
package.path = package.path ..';..\\?.lua'
require 'TingpaiLogic'
--print(package.path)

function table.clone (hands)
    local han = {}
    for i,v in ipairs(hands) do
        table.insert(han,v)
    end
    return han
end

local handpoker = {555,102,103,104,201,202,203,204,205,206,208,208,208,210,210,110,107,107,207,203}
local ret_tingHu = {}
TingpaiLogic.getTingPaiList(handpoker,ret_tingHu,0,{})

for tingpaiValue,item in pairs(ret_tingHu) do
    local logStr = "ting:" .. tingpaiValue .. " huxi:" .. item[TingpaiLogic.resIndex.huxi] .. "  cards:"
    for i, paicom in ipairs(item[TingpaiLogic.resIndex.combi]) do
        logStr = logStr .. '[' .. table.concat(paicom,',') .. '] '
    end
    print(logStr)
end

print("ok")
