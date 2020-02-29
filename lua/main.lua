
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

g_phzCards = {}
g_phzCards.kind_CardValue = 555
g_phzHuxi = {}
g_phzHuxi.b_xiao = 6
g_phzHuxi.s_xiao = 3
g_phzHuxi.b_qing = 12
g_phzHuxi.s_qing = 9
handpoker = {203,203,206,207,208,108,108,108}

ret_tingHu = {}
ret = TingpaiLogic.getTingPaiList(handpoker,ret_tingHu,0)

for i,v in pairs(ret_tingHu) do
    print(i,v)
end