
package.path = package.path ..';..\\?.lua'
require 'TingLogic'
print(package.path)

function table.clone (hands)
    local han = {}
    for i,v in ipairs(hands) do
        table.insert(han,v)
    end
    return han
end

g_phzCards = {}
g_phzCards.kind_CardValue = 555
g_phzHuxi = {}
g_phzHuxi.b_xiao = 6
g_phzHuxi.s_xiao = 3
handpoker = {207,207,108,109,110,210,210}

ret_tingHu = {}
ret = TingpaiLogic.getTingPaiList(handpoker,ret_tingHu,0)

for i,v in pairs(ret_tingHu) do
    print(i,v)
end