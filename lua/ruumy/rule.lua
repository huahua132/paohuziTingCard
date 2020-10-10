local table = table
local math = math
math.randomseed( os.time() )
function table.copy(t, nometa)
    local lookup_table = {}
    local function _copy(t)
        if type(t) ~= "table" then
            return t
        elseif lookup_table[t] then
            return lookup_table[t]
        end
        local new_table = {}
        lookup_table[t] = new_table
        for index, value in pairs(t) do
            new_table[_copy(index)] = _copy(value) -- index 是一个table时 可能会存在无法找到索引的情况
        end

        if not nometa then
           new_table = setmetatable(new_table, getmetatable(t))
        end
        
        return new_table
    end
    return _copy(t)
end

function rand_table(tb)
    local sum = 0
    for k,v in pairs(tb) do
        assert(v > 0,k)
        sum = sum + v
    end

    local last = 0
    local r = math.random(1,sum) 
    for k,v in pairs(tb) do
        local cur = last + v
        if r > last and r <= cur then
            return k,v
        end
        last = cur
    end
end

local table_clone = table.copy
local rand_table = rand_table


local rule = {}

local GROUP_TYPE = 
{
	pure_sequence = 1,      --纯序列
	sequence      = 2,		--序列
	set           = 3,		--集合
	invalid       = 4,		--无效
	joker         = 5       --赖子
} 

local suitType = {  
	Spade = 3, 			--黑桃
	Heart = 2, 			--红桃
	Club = 1, 			--梅花
	Diamond = 0, 		--方块
	Joker = 4,  		--大小王
}

local cardData = {
	--方块，梅花，红桃，黑桃
	--0x0E, 0x1E, 0x2E, 0x3E,--A
	0x4F,--大王
	0x4E,--小王
	0x0D, 0x1D, 0x2D, 0x3D,  --K
	0x0C, 0x1C, 0x2C, 0x3C,  --Q
	0x0B, 0x1B, 0x2B, 0x3B,  --J
	0x0A, 0x1A, 0x2A, 0x3A,  --10
	0x09, 0x19, 0x29, 0x39,  --9
	0x08, 0x18, 0x28, 0x38,  --8
	0x07, 0x17, 0x27, 0x37,  --7
	0x06, 0x16, 0x26, 0x36,  --6
	0x05, 0x15, 0x25, 0x35,  --5
	0x04, 0x14, 0x24, 0x34,  --4
	0x03, 0x13, 0x23, 0x33,  --3
	0x02, 0x12, 0x22, 0x32,  --2
	0x01, 0x11, 0x21, 0x31  --1
}

local card_id_value_map = 
{
	--方块
	[101] = 0x01, 
	[102] = 0x02,
	[103] = 0x03,
	[104] = 0x04,
	[105] = 0x05,
	[106] = 0x06,
	[107] = 0x07,
	[108] = 0x08,
	[109] = 0x09,
	[110] = 0x0a,
	[111] = 0x0b,
	[112] = 0x0c,
	[113] = 0x0d,
	--梅花
	[201] = 0x11,
	[202] = 0x12,
	[203] = 0x13,
	[204] = 0x14,
	[205] = 0x15,
	[206] = 0x16,
	[207] = 0x17,
	[208] = 0x18,
	[209] = 0x19,
	[210] = 0x1a,
	[211] = 0x1b,
	[212] = 0x1c,
	[213] = 0x1d,
	--红桃
	[301] = 0x21,
	[302] = 0x22,
	[303] = 0x23,
	[304] = 0x24,
	[305] = 0x25,
	[306] = 0x26,
	[307] = 0x27,
	[308] = 0x28,
	[309] = 0x29,
	[310] = 0x2a,
	[311] = 0x2b,
	[312] = 0x2c,
	[313] = 0x2d,
	--黑桃
	[401] = 0x31,
	[402] = 0x32,
	[403] = 0x33,
	[404] = 0x34,
	[405] = 0x35,
	[406] = 0x36,
	[407] = 0x37,
	[408] = 0x38,
	[409] = 0x39,
	[410] = 0x3a,
	[411] = 0x3b,
	[412] = 0x3c,
	[413] = 0x3d,
	--方块
	[501] = 0x01,
	[502] = 0x02,
	[503] = 0x03,
	[504] = 0x04,
	[505] = 0x05,
	[506] = 0x06,
	[507] = 0x07,
	[508] = 0x08,
	[509] = 0x09,
	[510] = 0x0a,
	[511] = 0x0b,
	[512] = 0x0c,
	[513] = 0x0d,
	--梅花
	[601] = 0x11,
	[602] = 0x12,
	[603] = 0x13,
	[604] = 0x14,
	[605] = 0x15,
	[606] = 0x16,
	[607] = 0x17,
	[608] = 0x18,
	[609] = 0x19,
	[610] = 0x1a,
	[611] = 0x1b,
	[612] = 0x1c,
	[613] = 0x1d,
	--红桃
	[701] = 0x21,
	[702] = 0x22,
	[703] = 0x23,
	[704] = 0x24,
	[705] = 0x25,
	[706] = 0x26,
	[707] = 0x27,
	[708] = 0x28,
	[709] = 0x29,
	[710] = 0x2a,
	[711] = 0x2b,
	[712] = 0x2c,
	[713] = 0x2d,
	--黑桃
	[801] = 0x31,
	[802] = 0x32,
	[803] = 0x33,
	[804] = 0x34,
	[805] = 0x35,
	[806] = 0x36,
	[807] = 0x37,
	[808] = 0x38,
	[809] = 0x39,
	[810] = 0x3a,
	[811] = 0x3b,
	[812] = 0x3c,
	[813] = 0x3d,

	--王牌
	[901] = 0x4E,
	[902] = 0x4F,
}

local one_pair_card_id_list = {
	101,102,103,104,105,106,107,108,109,110,111,112,113,
	201,202,203,204,205,206,207,208,209,210,211,212,213,
	301,302,303,304,305,306,307,408,309,310,311,312,313,
	401,402,403,404,405,406,407,308,409,410,411,412,413
}

local card_id_lib = {}
for id,v in pairs(card_id_value_map) do
	table.insert( card_id_lib,id)
end

local CardNumMap = {
	[0x0D] = {113, 213, 313, 413,513, 613, 713, 813},  --K
	[0x0C] = {112, 212, 312, 412,512, 612, 712, 812},  --Q
	[0x0B] = {111, 211, 311, 411,511, 611, 711, 811},  --J
	[0x0A] = {110, 210, 310, 410,510, 610, 710, 810},  --10
	[0x09] = {109, 209, 309, 409,509, 609, 709, 809},  --9
	[0x08] = {108, 208, 308, 408,508, 608, 708, 808},  --8
	[0x07] = {107, 207, 307, 407,507, 607, 707, 807},  --7
	[0x06] = {106, 206, 306, 406,506, 606, 706, 806},  --6
	[0x05] = {105, 205, 305, 405,505, 605, 705, 805},  --5
	[0x04] = {104, 204, 304, 404,504, 604, 704, 804},  --4
	[0x03] = {103, 203, 303, 403,503, 603, 703, 803},  --3
	[0x02] = {102, 202, 302, 402,502, 602, 702, 802},  --2
	[0x01] = {101, 201, 301, 401,501, 601, 701, 801},  --1
	[0x0F] = {902},--大王
	[0x0E] = {901},--小王
}


local CardScoreMap =
{
	[0x0F] = 10, --大王
	[0x0E] = 10, --小王
	[0x0D] = 10,  --K
	[0x0C] = 10,  --Q
	[0x0B] = 10,  --J
	[0x0A] = 10, --10
	[0x09] = 9, --9
	[0x08] = 8, --8
	[0x07] = 7, --7
	[0x06] = 6, --6
	[0x05] = 5, --5
	[0x04] = 4, --4
	[0x03] = 3, --3
	[0x02] = 2, --2
	[0x01] = 10
}

local weight_num_score =
{
	[0x0F] = 1, --大王
	[0x0E] = 1, --小王
	[0x0D] = 1,  --K
	[0x0C] = 1,  --Q
	[0x0B] = 1,  --J
	[0x0A] = 1, --10
	[0x09] = 2, --9
	[0x08] = 3, --8
	[0x07] = 4, --7
	[0x06] = 5, --6
	[0x05] = 6, --5
	[0x04] = 7, --4
	[0x03] = 8, --3
	[0x02] = 9, --2
	[0x01] = 1
}

local CardGradeMap = {
	[0x0F] = 17, --大王
	[0x0E] = 16, --小王
	[0x0D] = 13,  --K
	[0x0C] = 12,  --Q
	[0x0B] = 11,  --J
	[0x0A] = 10, --10
	[0x09] = 9, --9
	[0x08] = 8, --8
	[0x07] = 7, --7
	[0x06] = 6, --6
	[0x05] = 5, --5
	[0x04] = 4, --4
	[0x03] = 3, --3
	[0x02] = 2, --2
	[0x01] = 14, --A
}

local cardDisplay = {
	"A","2","3","4","5","6","7","8","9","10","J","Q","K","Kinglet","King",
}

local cardsuit = 
{
	[0] = "♢",
	[1] = "♣",
	[2] = "♡",
	[3] = "♤"
}

local function GetSuit(id)  --花色
	local bigType = id >> 4
	if bigType > 0x04 then
		return nil
	end
	return bigType
end

local function GetNum(id) --编号1到15
	local num = id & 0x0F
	return num
end

local function GetScore(id)  --分数
	local num = GetNum(id)
  	return CardScoreMap[num]
end 


local function GetDisplay(id)  --牌号
	local num = GetNum(id)
	local suit = GetSuit(id)
	if num > 13 then return cardDisplay[num] end      --大小王没花色
	local display = cardsuit[suit] .. cardDisplay[num]
	return display
end

local function GetGrade(id)  --权级
	local num = GetNum(id)
  	return CardGradeMap[num]
end 



local allCards = {}
for _,id in ipairs(cardData) do
	allCards[id] = {
		id = id,
		num = GetNum(id),
		score=GetScore(id), 
		suit=GetSuit(id),
		display=GetDisplay(id),
		grade = GetGrade(id)
	}
end

local QKA = {              --判断牌型用，A可以组合 123 和 QKA
	0x0E,0x1E,0x2E,0x3E
}

for _,id in ipairs(QKA) do
	allCards[id] = {
		id = id,
		num = GetNum(id),
		score=GetScore(id), 
		suit=GetSuit(id),
		display=GetDisplay(id),
		grade = GetGrade(id)
	}
end

local function get_card_info(card_id)
	local card_value = card_id_value_map[card_id]
	return allCards[card_value]
end

local function get_card_num(card_id)
	local card_info = get_card_info(card_id)
	if not card_info then
		return -1
	end
	return card_info.num
end

local function isvalid(id,islog)
	if not allCards[id] then
		if islog then
			log.error("not valid card_id =" .. id)
		end
		return false
	end
	return true
end

local function CardsDisplay(cards)
	local str =  ''
	if cards then
		for _,card in ipairs(cards) do
			if isvalid(card) then
				str = str..' '..allCards[card].display
			end
		end
	end
	return str
end

local function card_id_to_card_value(cards)
	if type(cards) == "table" then
		local card_value_list = {}
		for _,id in ipairs(cards) do
			if card_id_value_map[id] then
				table.insert(card_value_list, card_id_value_map[id])
			else
				table.insert(card_value_list, id)
			end
		end
		return card_value_list
	else
		return card_id_value_map[cards]
	end
end

function rule.shufflethecards(cards)
	for i = 1,#cards do
		local index = math.random(1,#cards)
		cards[i],cards[index] = cards[index],cards[i]
	end
end

function rule.random_allot_cards(card_num,player_num) 
	local temp_card_id_list = table_clone(card_id_lib)
	rule.shufflethecards(temp_card_id_list)

	local seat_cards_list = {}
	local joker_card_id = 0
	local remaining_cards = {}

	--找赖子
	local index_list = {}
	for index,card_id in pairs(temp_card_id_list) do
		local card_value = card_id_value_map[card_id]
		if allCards[card_value].num <= 13 then  --大小王不参与 
			table.insert(index_list,index)
		end
	end
	local cur_index = index_list[math.random(1,#index_list)]
	joker_card_id = temp_card_id_list[cur_index]
	table.remove(temp_card_id_list,cur_index)

	--发玩家牌
	for i = 1,player_num do
		local one_card_list = {}
		for j = 1,card_num do
			local index = math.random(1,#temp_card_id_list) 
			table.insert(one_card_list,temp_card_id_list[index])
			table.remove(temp_card_id_list,index)
		end
		table.insert(seat_cards_list,one_card_list)
	end
	
	remaining_cards = temp_card_id_list
	-- seat_cards_list[1] = {101,102,103,104,202,203,204,205,206,207,108,208,308}
	-- seat_cards_list[2] = {501,502,503,504,602,603,604,605,606,607,508,608,708}
	return seat_cards_list,joker_card_id,remaining_cards
end

function rule.allot_card_one(player_num)
	local card_list = table_clone(one_pair_card_id_list)
	rule.shufflethecards(card_list)

	local allot_card_list = {}

	for i = 1,player_num do 
		local index = math.random(1,#card_list)
		table.insert(allot_card_list,card_list[index])
		table.remove(card_list,index)
	end
	return allot_card_list
end

local function compare_grade_t(card1,card2)
	if allCards[card1].grade > allCards[card2].grade then
		return true
	elseif allCards[card1].grade == allCards[card2].grade then
		return allCards[card1].suit > allCards[card2].suit 
	end

	return false
end

function rule.get_max_card_index(card_id_list)
	local card_value_list = card_id_to_card_value(card_id_list)
	local maxIndex = nil
	local maxValue = nil
	for i,v in ipairs(card_value_list) do
		if v > 0 then
			if not maxIndex then
				maxIndex = i
				maxValue = v
			else
				if compare_grade_t(v,maxValue) then
					maxIndex = i
					maxValue = v
				end
			end
		end
	end
	return maxIndex
end

local function dump(cards) 
	for i,v in ipairs(cards) do
		print(string.format("花色：%d，牌面：%s, 权重：%d", allCards[v].suit,
		 allCards[v].display,
		  allCards[v].score))
	end
end

function rule.dumpDisplay(cards,is_value) 
	local card_value_list = cards
	if not is_value then
		card_value_list = card_id_to_card_value(cards)
	end
	local str = ""
	local str2 = ""
	if type(card_value_list) == "table" then
		for i,v in ipairs(card_value_list) do
			if not isvalid(v) then
			else
				str = str .. allCards[v].display .. "|"
				str2 = str2 .. cards[i] .. ","
			end
		end
	else
		if not isvalid(cards) then
		else
			str = str .. allCards[cards].display .. "|"
			str2 = str2 .. cards
		end
	end
	print(str .. "____" .. str2)
end
--[[for i = 1, 10000 do
	seat_cards_list,joker_card,Remaining_cards = rule.allot_cards(13,6)
end]]
function rule.is_joker_card(joker_card_id,card_id)
	local joker_card = card_id_to_card_value(joker_card_id)
	local card = card_id_to_card_value(card_id)

	if allCards[joker_card].num == allCards[card].num or allCards[card].num > 13 then
		return true
	end

	return false
end

function rule.is_sequence(card_lt,joker_card_id)  --是否是序列
	if #card_lt < 3 then
		return false
	end
	local card_list = card_id_to_card_value(card_lt)
	local joker_card = card_id_to_card_value(joker_card_id)
	local joker_cnt = 0

	for i = #card_list,1,-1 do
		if not isvalid(card_list[i]) then
			return false
		end
		if allCards[card_list[i]].num > 13 or allCards[card_list[i]].num == allCards[joker_card].num then
			joker_cnt = joker_cnt + 1
			table.remove(card_list,i)
		end
	end
	if #card_list == 0 then return true end

	if joker_cnt <= 0 then return false end

	table.sort(card_list)

	if allCards[card_list[1]].num == 1 and #card_list >= 2 and allCards[card_list[2]].num - allCards[card_list[1]].num - 1 > joker_cnt then
		local newCard = card_list[1] + 13    --去组合 QKA
		table.remove(card_list,1)
		table.insert(card_list,newCard)
	end

	local cur_num = card_list[1]
	local cur_pos = 2
	while cur_pos <= #card_list do
		if allCards[cur_num].suit ~= allCards[card_list[cur_pos]].suit then
			return false
		end
		if allCards[card_list[cur_pos]].num - allCards[cur_num].num == 1 then
			cur_num = card_list[cur_pos]
		else
			if joker_cnt > 0 then
				cur_num = cur_num + 1
				joker_cnt = joker_cnt - 1
				cur_pos = cur_pos - 1
			else
				return false
			end
		end
		cur_pos = cur_pos + 1
	end

	return true
end
assert(rule.is_sequence({101,102,103},104) == false)
assert(rule.is_sequence({201,102,103},104) == false)
assert(rule.is_sequence({101,102,104},104) == true)
assert(rule.is_sequence({101,103,104},104) == true)
assert(rule.is_sequence({101,105,106,107,108,109,110,111,104,204},104) == true)
assert(rule.is_sequence({101,104,105,106,107,108,109,110,103,503},103) == true)
assert(rule.is_sequence({101,105,106,107,108,109,110,404,304},104) == false)
assert(rule.is_sequence({112,113,101},104) == false)
function rule.get_score_card_list(card_id_list,joker_card_id)
	local card_list = card_id_to_card_value(card_id_list)
	local joker_card = card_id_to_card_value(joker_card_id)
	local score = 0
	for i,v in ipairs(card_list) do
		if allCards[v].num <= 13 and allCards[v].num ~= allCards[joker_card].num then
			score = score + allCards[v].score
		end
	end

	return score
end

function rule.is_pure_sequence(card_lt)  --是否是纯序列
	if #card_lt < 3 then
		return false
	end
	local card_list = card_id_to_card_value(card_lt)
	table.sort(card_list)

	if allCards[card_list[1]].num == 1 and #card_list >= 2 and allCards[card_list[2]].num - allCards[card_list[1]].num > 2 then
		local newCard = card_list[1] + 13    --去组合 QKA
		table.remove(card_list,1)
		table.insert(card_list,newCard)
	end

	local startIndex = 0
	local cur_num = card_list[1]
	local cur_pos = 2
	while cur_pos <= #card_list do
		if not isvalid(card_list[cur_pos]) then
			return false
		end
		if allCards[cur_num].suit ~= allCards[card_list[cur_pos]].suit then
			return false
		end
		if allCards[card_list[cur_pos]].num - allCards[cur_num].num == 1 then
			cur_num = card_list[cur_pos]
		else
			return false
		end
		cur_pos = cur_pos + 1
	end

	return true
end

assert(rule.is_pure_sequence({101,102,103}) == true)
assert(rule.is_pure_sequence({101,112,113}) == true)
assert(rule.is_pure_sequence({101,102,104}) == false)
assert(rule.is_pure_sequence({101,103,104}) == false)


function rule.is_set(card_lt,joker_card_id)  --是否是集合
	if #card_lt ~= 3 and #card_lt ~= 4 then
		return false
	end

	local card_list = card_id_to_card_value(card_lt)
	local joker_card = card_id_to_card_value(joker_card_id)
	local joker_cnt = 0

	for i = #card_list,1,-1 do
		if not isvalid(card_list[i]) then
			return false
		end
		if allCards[card_list[i]].num > 13 or allCards[card_list[i]].num == allCards[joker_card].num then
			joker_cnt = joker_cnt + 1
			table.remove(card_list,i)
		end
	end
	if #card_list == 0 then return true end
	local suit_cnt = {[suitType.Club] = 1,[suitType.Diamond] = 1,[suitType.Heart] = 1,[suitType.Spade] = 1}
	local num = allCards[card_list[1]].num
	for i,card_v in ipairs(card_list) do
		if num ~= allCards[card_v].num then
			return false
		end
		if suit_cnt[allCards[card_v].suit] > 0 then
			suit_cnt[allCards[card_v].suit] = suit_cnt[allCards[card_v].suit] - 1
		else
			return false
		end
	end

	return true
end

assert(rule.is_set({101,101,201,301},102) == false)
assert(rule.is_set({101,201,301},102) == true)
assert(rule.is_set({101,202,302},102) == true)
assert(rule.is_set({101,202,302},106) == false)

function rule.is_jokers(card_lt,joker_card_id)
	local card_list = card_id_to_card_value(card_lt)
	local joker_card = card_id_to_card_value(joker_card_id)

	for i,card in ipairs(card_list) do
		if not isvalid(card_list[i]) then
			return false
		end
		if allCards[card_list[i]].num <= 13 and allCards[card_list[i]].num ~= allCards[joker_card].num then
			return false
		end
	end
	return true
end

assert(rule.is_jokers({113},809) == false)
assert(rule.is_jokers({901},809) == true)
assert(rule.is_jokers({109},809) == true)
assert(rule.is_jokers({109,111},809) == false)
assert(rule.is_jokers({109,209,309,409,509,609,709,809,901},809) == true)

local function group_card_value_to_card_id(group_list,card_list_id)
	--这里还有用牌值找 对于牌id
	local temp_card_id_list = table_clone(card_list_id)

	local temp_value_id_map = {}  --值为 K  value 为 id列表
	for _,id in ipairs(temp_card_id_list) do
		local value = card_id_value_map[id]
		if not temp_value_id_map[value] then
			temp_value_id_map[value] = {}
		end
		table.insert(temp_value_id_map[value],id)
	end

	for _,one_group in ipairs(group_list) do
		local card_list = one_group.card_list
		for filed_i,card_value in ipairs(card_list) do
			local t_id_list = temp_value_id_map[card_value]
			if not next(t_id_list) then
				return false
			end
			card_list[filed_i] = t_id_list[1]
			table.remove(t_id_list,1)
		end
	end
	return true
end

local function del_group_dis_card(group_list,dis_card)
	for i = #group_list,1,-1 do
		local card_list = group_list[i].card_list
		for c_i,card_id in ipairs(card_list) do
			if card_id == dis_card then
				table.remove(card_list,c_i)
				break
			end
		end
		if #card_list == 0 then
			table.remove(group_list,i)
		end
	end
end

local function del_and_add_sequence(cards_v,endIndex,startIndex,card_A_cnt)
	local pure_sequence = {}
	while (endIndex >= startIndex) do
		table.insert(pure_sequence,cards_v[endIndex])
		if allCards[cards_v[endIndex]].num == 1 then
			card_A_cnt = card_A_cnt - 1
		end
		local deleIndex = endIndex
		if cards_v[endIndex] == cards_v[endIndex - 1] then
			endIndex = endIndex - 2
		else
			endIndex = endIndex - 1
		end
		table.remove(cards_v,deleIndex)
	end
	return pure_sequence,card_A_cnt
end

local function add_pure_sequence(pure_sequence_list,center_index_list,end_index,card_A_cnt,cards_v,start_index)
	local temp_end_index = end_index
	local temp_pure_sequence   --提前声明是为了返回A的使用数量
	if next(center_index_list) then
		center_index_list[0] = -100
		local center_index = center_index_list[#center_index_list]
		local rm_pos = #center_index_list
		local cen_cur_pos = #center_index_list - 1
		local cent_cnt = 0
		if center_index > 3 then
			while cen_cur_pos >= 0 do
				if center_index - center_index_list[cen_cur_pos] == 2 then
					center_index = center_index_list[cen_cur_pos]
					rm_pos = cen_cur_pos
					cent_cnt = cent_cnt + 1
				else
					local temp_card_cnt = 1
					local temp_cur_card = cards_v[center_index]
					for i = center_index + 1,end_index do
						if temp_cur_card ~= cards_v[i] then
							temp_card_cnt = temp_card_cnt + 1
						end
						temp_cur_card = cards_v[i]
					end
					if temp_card_cnt >= 3 then
						temp_pure_sequence,card_A_cnt = del_and_add_sequence(cards_v,end_index,center_index,card_A_cnt)
						table.insert(pure_sequence_list,temp_pure_sequence)
						end_index = center_index_list[#center_index_list] - 1 - cent_cnt
					end
					center_index = center_index_list[cen_cur_pos]
					while cent_cnt + 1 > 0 do
						table.remove( center_index_list, rm_pos)
						cent_cnt = cent_cnt - 1
					end
					rm_pos = cen_cur_pos
					cent_cnt = 0
				end
				cen_cur_pos = cen_cur_pos - 1
			end
		end
	end

	if temp_end_index == end_index then
		temp_pure_sequence,card_A_cnt = del_and_add_sequence(cards_v,end_index,start_index,card_A_cnt)
		table.insert(pure_sequence_list,temp_pure_sequence)
	end

	return card_A_cnt,end_index
end

local function resolve_card_pure_sequence(tempCard_list,joker_card)
	local joker_king_list = {}
	local suit_map_list = {}
	for i = #tempCard_list,1,-1 do
		if allCards[tempCard_list[i]].num > 13 then
			table.insert(joker_king_list,tempCard_list[i])
			table.remove(tempCard_list,i)
		else
			if not suit_map_list[ allCards[tempCard_list[i]].suit ] then
				suit_map_list[ allCards[tempCard_list[i]].suit ] = {}
			end
			table.insert(suit_map_list[ allCards[tempCard_list[i]].suit ],tempCard_list[i])
		end
	end

	local pure_sequence_list = {}
	--找同花顺
	for suit_i,cards_v in pairs(suit_map_list) do
		if #cards_v >= 3 then
			table.sort(cards_v,function (a,b) return a > b end)
			local card_A_cnt = 0
			for i = #cards_v,#cards_v - 1, -1 do
				if allCards[cards_v[i]].num == 1 then--A
					card_A_cnt = card_A_cnt + 1
				end
			end
			for LOOP = 1, 2 do
				local startIndex = 1
				local count = 1
				local endIndex = 0
				local card_num = cards_v[1]
				local center_index_list = {}
				local center_end = 0
				local curpos = 2
				while curpos <= #cards_v do
					if card_num - cards_v[curpos] == 1 then
						count = count + 1
						card_num = cards_v[curpos]
					elseif cards_v[curpos] == card_num then
						table.insert(center_index_list,curpos)
					else
						endIndex = curpos - 1
						if count >= 3 then
							card_A_cnt,endIndex = add_pure_sequence(pure_sequence_list,center_index_list,endIndex,card_A_cnt,cards_v,startIndex)
							curpos = startIndex
						elseif count == 2 and card_A_cnt > 0 and allCards[cards_v[startIndex]].num == 13 then
							local temp_pure_sequence
							temp_pure_sequence,card_A_cnt = del_and_add_sequence(cards_v,endIndex,startIndex,card_A_cnt)
							table.insert(temp_pure_sequence,cards_v[#cards_v])
							card_A_cnt = card_A_cnt - 1
							table.remove(cards_v,#cards_v)
							table.insert(pure_sequence_list,temp_pure_sequence)
							curpos = startIndex
						end
						center_index_list = {}
						startIndex = curpos
						card_num = cards_v[curpos]
						count = 1
					end
					curpos = curpos + 1
				end
				if count >= 3 then     --有顺子
					endIndex = #cards_v
					card_A_cnt,endIndex = add_pure_sequence(pure_sequence_list,center_index_list,endIndex,card_A_cnt,cards_v,startIndex)
				end
			end
			if card_A_cnt > 0 then
				for i,card_list in ipairs(pure_sequence_list) do
					if allCards[card_list[#card_list]].suit == suit_i and allCards[card_list[#card_list]].num == 13 then
						table.insert(card_list,cards_v[#cards_v])
						card_A_cnt = card_A_cnt - 1
						table.remove(cards_v,#cards_v)
					end
					if card_A_cnt <= 0 then break end
				end
			end
		end
	end
	--找同花顺
	--如果能拆成2个就拆一下
	for i,card_list in ipairs(pure_sequence_list) do
		if #card_list >= 6 then
			local new_pure_sequence = {card_list[1],card_list[2],card_list[3]}
			table.remove(card_list,1)
			table.remove(card_list,1)
			table.remove(card_list,1)
			table.insert(pure_sequence_list,new_pure_sequence)
		end
	end
	return pure_sequence_list,joker_king_list,suit_map_list
		--[[
		pure_sequence_list    : 纯序列
		joker_king_list       ：分离出来的王赖   牌赖子还未找出
		num_card_list_map     ：剩余未组合的牌    key = 花色 ： value = 牌数组 
	]]
end

local function get_cards_score(card_list,joker_card)
	local score = 0
	for i,v in ipairs(card_list) do
		if allCards[v].num <= 13 and allCards[v].num ~= allCards[joker_card].num then
			score = score + allCards[v].score
		end
	end

	return score
end

local function get_cards_id_score(card_list,joker_card_id)
	local score = 0
	for i,v in ipairs(card_list) do
		if v <= 900 and v % 100 ~= joker_card_id % 100 then
			score = score + get_card_info(v).score
		end
	end

	return score
end

local function get_cards_list_score(cards_list,joker_card)
	local score = 0
	for _,cards in ipairs(cards_list) do
		for i,v in ipairs(cards) do
			if allCards[v].num <= 13 and allCards[v].num ~= allCards[joker_card].num then
				score = score + allCards[v].score
			end
		end
	end
	return score
end

local function resolve_card_sequence(_one_card_list,joker_card)
	local suit_map_list = {}
	local joker_king_list = {}
	for _,card_value in ipairs(_one_card_list) do
		if allCards[card_value].num > 13 or allCards[card_value].num == allCards[joker_card].num then
			table.insert(joker_king_list,card_value)
		else
			if not suit_map_list[allCards[card_value].suit] then
				suit_map_list[allCards[card_value].suit] = {}
			end
			table.insert(suit_map_list[allCards[card_value].suit],card_value)
		end
	end
	local surplus_card_list = {}  --剩余的牌
	local sequence_list = {}	  --找出的序列
	local suit_list = {}
	for suit_i,list_v in pairs(suit_map_list) do
		table.insert(suit_list,{suit = suit_i,card_list = list_v})
	end

	table.sort(suit_list,function(a,b) return get_cards_score(a.card_list,joker_card) > get_cards_score(b.card_list,joker_card) end)

	for suit_i,list_info in ipairs(suit_list) do
		local suit_i = list_info.suit
		local list_v = list_info.card_list
		if #list_v >= 2 and #joker_king_list > 0 then
			table.sort(list_v, function(a,b) return a > b end)
			local card_A_cnt = 0
			for i = #list_v,#list_v - 1,-1 do
				if allCards[list_v[i]].num == 1 then--A
					card_A_cnt = card_A_cnt + 1
				end
			end
			local startIndex = 1
			local endIndex = 0
			local curPos = 2
			local count = 1
			local cur_num = list_v[1]
			local nead_joker = 0
			while curPos <= #list_v do
				if cur_num - list_v[curPos] == 1 then
					count = count + 1
					cur_num = list_v[curPos]
				elseif list_v[curPos] == cur_num then
				elseif cur_num - list_v[curPos] == 2 and nead_joker < #joker_king_list then   --差一个赖子补一下
					count = count + 2
					nead_joker = nead_joker + 1
					cur_num = list_v[curPos]
				else
					local sequence = {}
					local have = false
					
					if card_A_cnt > 0 and #joker_king_list - nead_joker >= 1 and (allCards[list_v[startIndex]].num == 12 or allCards[list_v[startIndex]].num == 13) then   --QKA
						table.insert(sequence,list_v[#list_v])
						table.remove(list_v,#list_v)
						card_A_cnt = card_A_cnt - 1
						have = true
						nead_joker = nead_joker + 1
					elseif count == 2 and #joker_king_list > 0 then   --56
						have = true
						nead_joker = 1
					elseif count >= 3 then     --有顺子
						have = true
					end
					if have then
						endIndex = curPos - 1
						local tempsequence = {}
						tempsequence,card_A_cnt = del_and_add_sequence(list_v,endIndex,startIndex,card_A_cnt)
						for i,v in ipairs(tempsequence) do
							table.insert(sequence,1,v)
						end
						for king_i = 1,nead_joker do
							table.insert(sequence, joker_king_list[#joker_king_list])
							table.remove(joker_king_list,#joker_king_list)
						end
						table.insert(sequence_list,sequence)
						curPos = startIndex
					end

					startIndex = curPos
					cur_num = list_v[curPos]
					count = 1
					nead_joker = 0
				end
				curPos = curPos + 1
			end
			local sequence = {}
			local have = false
			if count == 2 and #joker_king_list > 0 then   --56
				have = true
				nead_joker = 1
			elseif count >= 3 then
				have = true
			end

			if have then
				endIndex = #list_v
				local sequence = {}
				sequence,card_A_cnt = del_and_add_sequence(list_v,endIndex,startIndex,card_A_cnt)
				for king_i = 1,nead_joker do
					table.insert(sequence, joker_king_list[#joker_king_list])
					table.remove(joker_king_list,#joker_king_list)
				end
				table.insert(sequence_list,sequence)
			end
		end

		for i,v in ipairs(list_v) do
			table.insert(surplus_card_list,v)
		end
	end

	for _,card in ipairs(joker_king_list) do
		table.insert( surplus_card_list,card)
	end

	return sequence_list,surplus_card_list
	--[[
		sequence_list    : 序列
		surplus_card_list：剩余未组合的牌 
	]]
end

local function resolve_card_set(_one_card_list,joker_card)
	local num_card_list_map = {}
	local joker_king_list = {}
	local surplus_card_list = {}  --剩余的牌
	for _,card_value in ipairs(_one_card_list) do
		if allCards[card_value].num > 13 or allCards[card_value].num == allCards[joker_card].num then
			table.insert(joker_king_list,card_value)
		else
			if not num_card_list_map[allCards[card_value].num] then
				num_card_list_map[allCards[card_value].num] = {}
			end
			table.insert(num_card_list_map[allCards[card_value].num],card_value)
		end
	end

	local num_info_list = {}
	for num_i,list_v in pairs(num_card_list_map) do
		table.insert(num_info_list,{num = num_i,card_list = list_v})
	end
	table.sort(num_info_list,function(a,b) return get_cards_score(a.card_list,joker_card) > get_cards_score(b.card_list,joker_card) end)
	--set
	local set_list = {}
	for _,num_info in pairs(num_info_list) do
		local num_i = num_info.num
		local num_list = num_info.card_list
		if #num_list == 2 and #joker_king_list >= 1 and allCards[num_list[1]].suit ~= allCards[num_list[2]].suit then
			local card_list = {}
			table.insert(card_list,num_list[1])
			table.insert(card_list,num_list[2])
			table.insert(card_list, joker_king_list[#joker_king_list])
			table.remove(joker_king_list,#joker_king_list)
			num_list = {}
			table.insert(set_list,card_list)
		elseif #num_list >= 3 then
			local suit_cnt = {[suitType.Club] = 1,[suitType.Diamond] = 1,[suitType.Heart] = 1,[suitType.Spade] = 1}
			local card_list = {}
			for num_i = #num_list, 1 ,-1 do
				if suit_cnt[allCards[num_list[num_i]].suit] > 0 then
					table.insert(card_list,num_list[num_i])
					suit_cnt[allCards[num_list[num_i]].suit] = suit_cnt[allCards[num_list[num_i]].suit] - 1
					table.remove(num_list,num_i)
				end
			end
			if #card_list >=3 then
				table.insert(set_list,card_list)
			else
				for i,v in ipairs(card_list) do
					table.insert(num_list,v)
				end
			end
		end

		for _,card in ipairs(num_list) do
			table.insert( surplus_card_list, card)
		end
	end

	for _,card in ipairs(joker_king_list) do
		table.insert( surplus_card_list, card)
	end

	return set_list,surplus_card_list
	--[[
		set_list         : 序列
		surplus_card_list：剩余未组合的牌
	]]
end

local function add_group_list(group_list,card_list,group_type)
	local one_group = {}
	one_group.type = group_type
	one_group.card_list = table_clone(card_list)
	table.insert(group_list,one_group)
end
--机器人输牌做牌提交
local function get_robot_lost_group_list(card_id_list,filter_card_list,joker_card_id,need_card_num)
	local temp_card_id_value_map = table_clone(card_id_value_map)
	for i,v in ipairs(filter_card_list) do
		temp_card_id_value_map[v] = nil
	end
	local temp_card_id_lib = {}
	for id,v in pairs(temp_card_id_value_map) do
		table.insert( temp_card_id_lib,id)
	end
	local group_list = {}

	rule.shufflethecards(temp_card_id_lib)
	local card_list_id = table_clone(card_id_list)
	for i = 1, 8 do
		if temp_card_id_lib[i] then
			table.insert(card_list_id,temp_card_id_lib[i] )
		end
	end

	local card_list = card_id_to_card_value(card_list_id)
	local joker_card = card_id_to_card_value(joker_card_id)

	local pure_sequence_list,joker_king_list,suit_map_list = resolve_card_pure_sequence(card_list,joker_card)

	local surplus_card_list = table_clone(joker_king_list)  --剩余的牌 
	for suit_i,suit_v in pairs(suit_map_list) do
		for _,card_value in ipairs(suit_v) do
			table.insert(surplus_card_list,card_value)
		end
	end

	local sequence_list, seq_surplus_card_list = resolve_card_sequence(surplus_card_list,joker_card)
	local set_list,      set_surplus_card_list = resolve_card_set(seq_surplus_card_list,joker_card)

	local card_cnt = 0

	while card_cnt < need_card_num do
		if not next(pure_sequence_list) and not next(sequence_list) and not next(set_list) then
			break
		end

		for i = #pure_sequence_list, 1,-1 do
			add_group_list(group_list,pure_sequence_list[i],GROUP_TYPE.pure_sequence)
			card_cnt = card_cnt + #pure_sequence_list[i]
			table.remove( pure_sequence_list, i)
			break
		end

		for i = #sequence_list, 1,-1 do
			add_group_list(group_list,sequence_list[i],GROUP_TYPE.sequence)
			card_cnt = card_cnt + #sequence_list[i]
			table.remove( sequence_list, i)
			break
		end

		for i = #set_list, 1,-1 do
			add_group_list(group_list,set_list[i],GROUP_TYPE.set)
			card_cnt = card_cnt + #set_list[i]
			table.remove( set_list, i)
			break
		end
	end
	local big_cnt = card_cnt - need_card_num
	if card_cnt > need_card_num then
		for i,v in ipairs(group_list) do
			if v.type ~= GROUP_TYPE.sequence then    --这里有赖子，去掉就不成立啦
				local card_list = v.card_list
				while #card_list > 3 and big_cnt > 0  do
					table.remove( card_list,1)
					big_cnt = big_cnt - 1
					card_cnt = card_cnt - 1
				end
			end
		end
	end

	if big_cnt > 0 then                    --牌还有多就刚好拆掉一些好的牌组
		for i = #group_list , 1, -1 do
			local one_group = group_list[i]
			while #one_group.card_list > 0 and big_cnt > 0 do
				table.remove( one_group.card_list,1)
				big_cnt = big_cnt - 1
				card_cnt = card_cnt - 1
			end
		end
	else
		local temp_card_list = set_surplus_card_list
		local need_valid_card_cnt = need_card_num - card_cnt
		if need_valid_card_cnt > 0 then
		local one_group = {}
			one_group.type = GROUP_TYPE.invalid
			one_group.card_list = {}
			for i = 1,need_valid_card_cnt do
				table.insert(one_group.card_list,temp_card_list[i])
			end
			table.insert(group_list,one_group)
		end
	end

	--这里还有用牌值找 对于牌id
	local temp_card_id_list = table_clone(card_list_id)
	local temp_value_id_map = {}  --值为 K  value 为 id列表
	for _,id in ipairs(temp_card_id_list) do
		local value = card_id_value_map[id]
		if not temp_value_id_map[value] then
			temp_value_id_map[value] = {}
		end
		table.insert(temp_value_id_map[value],id)
	end

	--把组合也换一下
	local hands_cards = {}
	for _,one_group in ipairs(group_list) do
		local card_list = one_group.card_list
		for filed_i,card_value in ipairs(card_list) do
			local t_id_list = temp_value_id_map[card_value]
			if not next(t_id_list) then
				return false,group_list
			end
			card_list[filed_i] = t_id_list[1]
			table.insert(hands_cards,card_list[filed_i])
			table.remove(t_id_list,1)
		end
	end

	-- print("group_list2 --------------- joker_card = " .. joker_card_id)
	-- for i,v in ipairs(group_list) do
	-- 	print("group_type = " .. v.type)
	-- 	rule.dumpDisplay(v.card_list)
	-- end
	-- print("group_list2 --------------- joker_card = " .. joker_card_id)
	-- rule.dumpDisplay(hands_cards)
	-- print("----------------------------------------------")
	return true,group_list,hands_cards
end

function rule.get_robot_lost_group_list(card_id_list,filter_card_list,joker_card_id,need_card_num)
	local ok,ret,group_list,hands_cards = pcall(get_robot_lost_group_list,card_id_list,filter_card_list,joker_card_id,need_card_num)
	if not ok then
		log.error("get_robot_lost_group_list err:",card_id_list,filter_card_list,joker_card_id,need_card_num)
		return false
	end
	return ret,group_list,hands_cards
end
--机器人赢牌提交做牌
local function get_robot_win_group_list(card_list_id,joker_card_id,need_card_num,is_seqee)
	local card_list = card_id_to_card_value(card_list_id)
	local joker_card = card_id_to_card_value(joker_card_id)
	local tempCard_list = table_clone(card_list)
	-- print("----------------------------------------------")
	-- rule.dumpDisplay(tempCard_list)
	local pure_sequence_list,joker_king_list,suit_map_list = resolve_card_pure_sequence(tempCard_list,joker_card)

	local surplus_card_list = table_clone(joker_king_list)  --剩余的牌 
	for suit_i,suit_v in pairs(suit_map_list) do
		for _,card_value in ipairs(suit_v) do
			table.insert(surplus_card_list,card_value)
		end
	end

	local sequence_list, seq_surplus_card_list = resolve_card_sequence(surplus_card_list,joker_card)
	local set_list,      set_surplus_card_list = resolve_card_set(seq_surplus_card_list,joker_card)

	local group_list = {}
	--没有纯序列肯定就是完成不了
	if not next(pure_sequence_list) then
		return false
	end
	local card_cnt = 0
	local is_pure_seq = false
	local is_seq = is_seqee or false
	while card_cnt < need_card_num do
		if not next(pure_sequence_list) and not next(sequence_list) and not next(set_list) then
			return false
			--充不满牌数就算了
		end

		for i = #pure_sequence_list, 1,-1 do
			add_group_list(group_list,pure_sequence_list[i],GROUP_TYPE.pure_sequence)
			card_cnt = card_cnt + #pure_sequence_list[i]
			if is_pure_seq then
				is_seq = true
			end
			is_pure_seq = true
			table.remove( pure_sequence_list, i)
			break
		end

		for i = #sequence_list, 1,-1 do
			add_group_list(group_list,sequence_list[i],GROUP_TYPE.sequence)
			card_cnt = card_cnt + #sequence_list[i]
			table.remove( sequence_list, i)
			break
		end

		for i = #set_list, 1,-1 do
			add_group_list(group_list,set_list[i],GROUP_TYPE.set)
			card_cnt = card_cnt + #set_list[i]
			table.remove( set_list, i)
			break
		end
	end

	if card_cnt > need_card_num then
		local big_cnt = card_cnt - need_card_num
		for i,v in ipairs(group_list) do
			if v.type ~= GROUP_TYPE.sequence then    --这里有赖子，去掉就不成立啦
				local card_list = v.card_list
				while #card_list > 3 and big_cnt > 0  do
					table.remove( card_list,1)
					big_cnt = big_cnt - 1
				end
			end
		end
		if big_cnt > 0 then
			return false
		end
	end

	local temp_card_list = {}
	for i,card_list in ipairs(pure_sequence_list) do
		for _,card_value in ipairs(card_list) do
			table.insert( temp_card_list, card_value )
		end
	end

	for i,card_list in ipairs(sequence_list) do
		for _,card_value in ipairs(card_list) do
			table.insert( temp_card_list, card_value )
		end
	end

	for i,card_list in ipairs(set_list) do
		for _,card_value in ipairs(card_list) do
			table.insert( temp_card_list, card_value )
		end
	end

	for i,card_value in ipairs(set_surplus_card_list) do
		table.insert(temp_card_list,card_value)
	end

	if #temp_card_list <= 0 then
		return false
	end

	if not is_pure_seq or not is_seq then
		return false
	end

	--在里面弄一张牌用做完成
	local index = math.random(1,#temp_card_list)
	local card_value = temp_card_list[index]

	--这里还有用牌值找 对于牌id
	local temp_card_id_list = table_clone(card_list_id)

	local temp_value_id_map = {}  --值为 K  value 为 id列表
	for _,id in ipairs(temp_card_id_list) do
		local value = card_id_value_map[id]
		if not temp_value_id_map[value] then
			temp_value_id_map[value] = {}
		end
		table.insert(temp_value_id_map[value],id)
	end

	local filsh_card_id = 0
	local id_list = temp_value_id_map[card_value]
	if not next(id_list) then
		return false
	end
	filsh_card_id = id_list[1]
	table.remove(id_list,1)
	--把组合也换一下
	local hands_cards = {filsh_card_id}
	for _,one_group in ipairs(group_list) do
		local card_list = one_group.card_list
		for filed_i,card_value in ipairs(card_list) do
			local t_id_list = temp_value_id_map[card_value]
			if not next(t_id_list) then
				return false
			end
			card_list[filed_i] = t_id_list[1]
			table.insert(hands_cards,card_list[filed_i])
			table.remove(t_id_list,1)
		end
	end

	-- log.info("group_list2 --------------- joker_card = " .. joker_card_id)
	-- for i,v in ipairs(group_list) do
	-- 	log.info("group_type = " .. v.type)
	-- 	rule.dumpDisplay(v.card_list)
	-- end
	-- log.info("group_list2 --------------- joker_card = " .. joker_card_id)
	-- rule.dumpDisplay(hands_cards)
	-- log.info("----------------------------------------------")
	return true,filsh_card_id,group_list,hands_cards
end

function rule.get_robot_win_group_list(card_list_id,joker_card_id,need_card_num,is_seqee)
	local ok,ret,filsh_card_id,group_list,hands_cards = pcall(get_robot_win_group_list,card_list_id,joker_card_id,need_card_num,is_seqee)
	if not ok then
		log.error("get_robot_win_group_list err:",card_list_id,joker_card_id,need_card_num,is_seqee)
		return false
	end
	return ret,filsh_card_id,group_list,hands_cards
end

local function get_group_list(card_list_id,joker_card_id,is_seqss) 
	local card_list = card_id_to_card_value(card_list_id)
	local joker_card = card_id_to_card_value(joker_card_id)
	local tempCard_list = table_clone(card_list)
	-- print("----------------------------------------------")
	-- rule.dumpDisplay(tempCard_list)
	local pure_sequence_list,joker_king_list,suit_map_list = resolve_card_pure_sequence(tempCard_list,joker_card)

	local surplus_card_list = table_clone(joker_king_list)  --剩余的牌 
	for suit_i,suit_v in pairs(suit_map_list) do
		for _,card_value in ipairs(suit_v) do
			table.insert(surplus_card_list,card_value)
		end
	end

	local head_list = {}
	local end_list = {}

	for _,list_v in ipairs(pure_sequence_list) do
		if #list_v > 3 then
			table.insert(head_list,list_v[1])
			table.insert(end_list,list_v[#list_v])
		end
	end

	local temp_combi = {}
	for i = 1,#head_list do
		table.insert(temp_combi,table_clone(head_list))
		for j = #head_list - 1,1,-1 do
			for k = 1,#head_list do
				local tmp_card_list = {}
				if k <= j then
					table.insert(tmp_card_list,head_list[i])
				else
					table.insert(tmp_card_list,end_list[i])
				end
			end
		end
		table.insert(temp_combi,table_clone(end_list))
		for j = #end_list - 1,1,-1 do
			for k = 1,#end_list do
				local tmp_card_list = {}
				if k <= j then
					table.insert(tmp_card_list,end_list[i])
				else
					table.insert(tmp_card_list,head_list[i])
				end
			end
		end
	end

	local clone_surplus_card_list = table_clone(surplus_card_list)

	local sequence_list,seq_surplus_card_list = resolve_card_sequence(surplus_card_list,joker_card)

	local set_list,set_surplus_card_list = resolve_card_set(seq_surplus_card_list,joker_card)

	local best_sequence_list = sequence_list
	local best_set_list = set_list
	local best_score = get_cards_list_score(best_sequence_list,joker_card)
	best_score = best_score + get_cards_list_score(best_set_list,joker_card)
	local best_surplus_card_list = set_surplus_card_list
	local best_combi = {}
	for _,combi_card_list in ipairs(temp_combi) do
		local tep_combi_card_list = table_clone(combi_card_list)
		local temp_surplus_card_list = table_clone(clone_surplus_card_list)
		for i,card in ipairs(tep_combi_card_list) do
			table.insert(temp_surplus_card_list,card)
		end

		local temp_sequence_list,temp_seq_surplus_card_list = resolve_card_sequence(temp_surplus_card_list,joker_card)

		local temp_set_list,temp_set_surplus_card_list = resolve_card_set(temp_seq_surplus_card_list,joker_card)

		local temp_best_score = get_cards_list_score(temp_sequence_list,joker_card)
		temp_best_score = temp_best_score + get_cards_list_score(temp_set_list,joker_card)
		if temp_best_score > best_score then
			best_score = temp_best_score
			best_sequence_list = temp_sequence_list
			best_set_list = temp_set_list
			best_surplus_card_list = temp_set_surplus_card_list
			best_combi = tep_combi_card_list
		end

		if #pure_sequence_list > 1 then
			local temp_set_list,temp_set_surplus_card_list = resolve_card_set(temp_surplus_card_list,joker_card)

			local temp_sequence_list,temp_seq_surplus_card_list = resolve_card_sequence(temp_set_surplus_card_list,joker_card)

			local temp_best_score = get_cards_list_score(temp_sequence_list,joker_card)
			temp_best_score = temp_best_score + get_cards_list_score(temp_set_list,joker_card)
			if temp_best_score > best_score then
				best_score = temp_best_score
				best_sequence_list = temp_sequence_list
				best_set_list = temp_set_list
				best_surplus_card_list = temp_seq_surplus_card_list
				best_combi = tep_combi_card_list
			end
		end
	end

	for _,card_value in ipairs(best_combi) do
		for i,pure_card_list in ipairs(pure_sequence_list) do
			if #pure_card_list > 3 then
				if card_value == pure_card_list[1] then
					table.remove(pure_card_list,1)
					break
				end
				if card_value == pure_card_list[#pure_card_list] then
					table.remove(pure_card_list,#pure_card_list)
					break
				end
			end
		end
	end

	local card_value_map_index = {}
	local set_joker_king_list = {}
	for i = #best_surplus_card_list,1,-1 do
		local card_value = best_surplus_card_list[i]
		if allCards[card_value].num > 13 or allCards[card_value].num == allCards[joker_card].num then
			table.insert(set_joker_king_list,card_value)
			table.remove( best_surplus_card_list,i)
		else
			card_value_map_index[card_value] = i
		end
	end
	local rm_surplus_card_index = {}
	for _,pure_card_list in ipairs(pure_sequence_list) do
		local head_card= pure_card_list[1]
		if card_value_map_index[head_card - 1] then
			table.insert(pure_card_list,1,head_card - 1)
			table.insert(rm_surplus_card_index,card_value_map_index[head_card - 1])
			card_value_map_index[head_card - 1] = nil
		end
		local end_card = pure_card_list[#pure_card_list]
		if allCards[end_card].num == 13 then
			local need_card = end_card - 12
			if card_value_map_index[need_card] then
				table.insert(pure_card_list,need_card)
				table.insert(rm_surplus_card_index,card_value_map_index[need_card])
				card_value_map_index[need_card] = nil
			end
		elseif allCards[end_card].num == 1 then
		else
			if card_value_map_index[end_card + 1] then
				table.insert(pure_card_list,end_card + 1)
				table.insert(rm_surplus_card_index,card_value_map_index[end_card + 1])
				card_value_map_index[end_card + 1] = nil
			end
		end
	end

	table.sort(rm_surplus_card_index,function(a,b) return a > b end)
	for _,index in ipairs(rm_surplus_card_index) do
		table.remove(best_surplus_card_list,index)
	end

	local is_pure_seq = false
	local is_seq = is_seqss
	--后面把组合发出去
	local group_list = {}

	for i = #pure_sequence_list, 1,-1 do
		add_group_list(group_list,pure_sequence_list[i],GROUP_TYPE.pure_sequence)
		if is_pure_seq then
			is_seq = true
		end
		is_pure_seq = true
	end

	for i = #best_sequence_list, 1,-1 do
		add_group_list(group_list,best_sequence_list[i],GROUP_TYPE.sequence)
		is_seq = true
	end

	local temp_card_list = best_surplus_card_list

	if #set_joker_king_list >= 2 and #temp_card_list >= 1 then
		local temp_group_card_list = {}
		for i = #set_joker_king_list,#set_joker_king_list - 1,-1 do
			table.insert(temp_group_card_list,set_joker_king_list[i])
			table.remove(set_joker_king_list,i)
		end
		table.insert(temp_group_card_list,temp_card_list[1])
		table.remove(temp_card_list,1)
		add_group_list(group_list,temp_group_card_list,GROUP_TYPE.sequence)
		is_seq = true
	end

	for i = #best_set_list, 1,-1 do
		if is_pure_seq and is_seq then
			add_group_list(group_list,best_set_list[i],GROUP_TYPE.set)
		else
			for _,card_id in ipairs(best_set_list[i]) do
				table.insert(temp_card_list,card_id)
			end
		end
	end

	if #set_joker_king_list > 0 then
		add_group_list(group_list,set_joker_king_list,GROUP_TYPE.joker)
	end
	
	if #temp_card_list > 0 then
		add_group_list(group_list,temp_card_list,GROUP_TYPE.invalid)
	end

	-- log.info("group_list --------------- joker_card = " .. joker_card_id)
	-- for i,v in ipairs(group_list) do
	-- 	log.info("group_type = " .. v.type)
	-- 	rule.dumpDisplay(v.card_list,true)
	-- end
	-- rule.dumpDisplay(card_list_id)
	-- log.info("group_list --------------- joker_card = " .. joker_card_id)
	-- log.info("----------------------------------------------")
	return group_list
end

function rule.get_group_list(card_list_id,joker_card_id,is_seqss)
	local ok,group_list = pcall(get_group_list,card_list_id,joker_card_id,is_seqss)
	if not ok then
		log.error("get_group_list group_card_value_to_card_id err ",card_list_id,joker_card_id,is_seqss)
		return {}
	end
	return group_list
end

local function get_group_list_id(card_list_id,joker_card_id,is_seqss)
	local group_list = get_group_list(card_list_id,joker_card_id,is_seqss) 
	if not group_card_value_to_card_id(group_list,card_list_id) then
		log.error("get_group_list_id group_card_value_to_card_id err ",group_list,card_list_id)
		return {}
	end
	return group_list
end

local GET_GROUP_NEED_CARD = {}
local function add_need_card_map(need_card_map,card_id)
	local suit = math.floor(card_id / 100)
	need_card_map[card_id] = true
	if suit <= 4 then
		need_card_map[card_id + 400] = true
	else
		need_card_map[card_id - 400] = true
	end
end

local function unified_card_id_list(card_id_list) 
	for i,card_id in ipairs(card_id_list) do
		if card_id < 500 then
			card_id_list[i] = card_id_list[i] + 400
		end
	end
end

local function get_pure_seq_need_card(need_card_map,card_id_list,joker_id)
	if not next(card_id_list) then return end
	table.sort(card_id_list)
	if card_id_list[1] % 100 ~= 1 then --A前面没有了
		add_need_card_map(need_card_map,card_id_list[1] - 1)
	elseif card_id_list[2] then
		add_need_card_map(need_card_map,card_id_list[2] - 1)
	end
	if card_id_list[#card_id_list] % 100 ~= 13 then --K后面没有了
		add_need_card_map(need_card_map,card_id_list[#card_id_list] + 1)
	else
		--可能可以弄个A
		if card_id_list[1] % 100 ~= 1 then
			add_need_card_map(need_card_map,card_id_list[#card_id_list] - 12)
		end
	end
	--101 102 103 104 105 可以摸 103 和 106
	if #card_id_list >= 5 then
		for i = 3,#card_id_list - 2 do
			add_need_card_map(need_card_map,card_id_list[i])
		end
	end
end
GET_GROUP_NEED_CARD[GROUP_TYPE.pure_sequence] = get_pure_seq_need_card

local function get_seq_need_card(need_card_map,card_id_list,joker_id)
	local joker_card_num = joker_id % 100
	for i = #card_id_list,1,-1 do
		if card_id_list[i] > 900 or card_id_list[i] % 100 == joker_card_num then
			table.remove(card_id_list,i)
		end
	end
	if not next(card_id_list) then return end
	table.sort(card_id_list)

	if card_id_list[1] % 100 ~= 1 then --A前面没有了
		add_need_card_map(need_card_map,card_id_list[1] - 1)
	elseif #card_id_list >= 2 then
		add_need_card_map(need_card_map,card_id_list[2] - 1)
	end

	if card_id_list[#card_id_list] % 100 ~= 13 then --K后面没有了
		add_need_card_map(need_card_map,card_id_list[#card_id_list] + 1)
	else
		--可能可以弄个A
		if card_id_list[1] % 100 ~= 1 then
			add_need_card_map(need_card_map,card_id_list[#card_id_list] - 12)
		end
	end

	local pre_num = card_id_list[1]
	for i = 2,#card_id_list do
		if card_id_list[i] - pre_num == 1 then
			add_need_card_map(need_card_map,pre_num - 1)
			add_need_card_map(need_card_map,card_id_list[i] + 1)
		elseif card_id_list[i] - pre_num == 2 then
			add_need_card_map(need_card_map,pre_num + 1)
		end
		pre_num = card_id_list[i]
	end

end
GET_GROUP_NEED_CARD[GROUP_TYPE.sequence] = get_seq_need_card

local function get_invald_seq_need_card(need_card_map,card_id_list,joker_id)
	if #card_id_list < 2 then
		return
	end
	table.sort(card_id_list)
	local pre_num = card_id_list[1]
	for i = 2,#card_id_list do
		if card_id_list[i] - pre_num == 1 then
			add_need_card_map(need_card_map,pre_num - 1)
			add_need_card_map(need_card_map,card_id_list[i] + 1)
		elseif card_id_list[i] - pre_num == 2 then
			add_need_card_map(need_card_map,pre_num + 1)
		end
		pre_num = card_id_list[i]
	end
end

local function get_set_need_card(need_card_map,card_id_list,joker_id)
	for i,card_id in ipairs(card_id_list) do
		if math.floor(card_id / 100) > 4 then
			card_id_list[i] = card_id_list[i] - 400
		end
	end

	local joker_card_num = joker_id % 100
	for i = #card_id_list,1,-1 do
		if card_id_list[i] % 100 == joker_card_num or card_id_list[i] > 900 then
			table.remove(card_id_list,i)
		end
	end

	if #card_id_list == 4 or #card_id_list == 0 then return end
	local suit_cnt = {[suitType.Club] = 1,[suitType.Diamond] = 1,[suitType.Heart] = 1,[suitType.Spade] = 1}
	local num = card_id_list[1] % 100
	for i,card_id in ipairs(card_id_list) do
		local suit = math.floor(card_id / 100)
		if suit > 4 then
			suit = suit - 4
		end
		suit = suit - 1
		suit_cnt[suit] = suit_cnt[suit] - 1
	end

	for suit,cnt in pairs(suit_cnt) do
		if cnt == 1 then
			add_need_card_map(need_card_map,(suit + 1) * 100 + num )
		end
	end

end
GET_GROUP_NEED_CARD[GROUP_TYPE.set] = get_set_need_card

local function get_invaild_need_card(need_card_map,card_id_list,joker_id,is_can_need_seq,is_have_joker)
	local suit_map = {}
	local num_map = {}

	for i,card_id in ipairs(card_id_list) do
		local suit = math.floor(card_id / 100)
		if suit > 4 then
			suit = suit - 4
		end
		suit = suit - 1
		local num = card_id % 100
		if not suit_map[suit] then
			suit_map[suit] = {}
		end
		if not num_map[num] then
			num_map[num] = {}
		end
		table.insert(suit_map[suit],card_id)
		table.insert(num_map[num],card_id)
	end
	
	for _,_card_list in pairs(suit_map) do
		if #_card_list >= 2 then
			get_invald_seq_need_card(need_card_map,_card_list,joker_id)
			if is_have_joker then
				local head_card_id = _card_list[1]
				local end_card_id = _card_list[#_card_list]
				local head_temp_num = head_card_id % 100
				local end_temp_num = end_card_id % 100
				if head_temp_num > 2 then
					add_need_card_map(need_card_map,head_card_id - 2)
				end
				if head_temp_num > 1 then
					add_need_card_map(need_card_map,head_card_id - 1)
				end
				if end_temp_num < 12 then
					add_need_card_map(need_card_map,end_card_id + 2)
				end
				if end_temp_num < 13 then
					add_need_card_map(need_card_map,end_card_id + 1)
				end
				if end_temp_num == 13 or end_temp_num == 12 then
					add_need_card_map(need_card_map,math.floor(end_card_id / 100) * 100 + 1)
				end
				if add_need_card_map == 1 then
					add_need_card_map(need_card_map,math.floor(head_card_id / 100) * 100 + 12)
					add_need_card_map(need_card_map,math.floor(head_card_id / 100) * 100 + 13)
				end
			end
		end
	end
	
	if is_can_need_seq then
		for _,_card_list in pairs(num_map) do
			if #_card_list >= 2 then
				get_set_need_card(need_card_map,_card_list,joker_id)
			else
				if is_have_joker then
					get_set_need_card(need_card_map,_card_list,joker_id)
				end
			end
		end
	end
end
GET_GROUP_NEED_CARD[GROUP_TYPE.invalid] = get_invaild_need_card

local function get_joker_need_card(need_card_map,card_id_list,joker_id)

end
GET_GROUP_NEED_CARD[GROUP_TYPE.joker] = get_joker_need_card

local function get_group_list_need_card_map(group_list,joker_id,_is_seq)
	local temp_group_list = table_clone(group_list)
	local need_card_map = {}

	local is_pure_seq = false
	local is_seq = _is_seq
	local is_have_joker = false

	for i,one_group in ipairs(temp_group_list) do
		local type = one_group.type
		if type == GROUP_TYPE.pure_sequence then
			if is_pure_seq then
				is_seq = true
			end
			is_pure_seq = true
		elseif type == GROUP_TYPE.sequence then
			is_seq = true
		elseif type == GROUP_TYPE.joker then
			is_have_joker = true
		end
	end

	for i,one_group in ipairs(temp_group_list) do
		local type = one_group.type
		local card_id_list = one_group.card_list
		local func = GET_GROUP_NEED_CARD[type]
		if func then
			unified_card_id_list(card_id_list)
			if type ~= GROUP_TYPE.set then
				func(need_card_map,card_id_list,joker_id,is_pure_seq and is_seq,is_have_joker)
			else
				if is_pure_seq and is_seq then
					func(need_card_map,card_id_list,joker_id)
				end
			end
		end
	end

	return need_card_map
end

local function is_kind_card(card_id)
	return card_id >= 900
end

local function is_joker_card(card_id,joker_card_id)
	if card_id >= 900 then return true end
	local card_info = get_card_info(card_id)
	local joker_card_info = get_card_info(joker_card_id)
	return card_info.num == joker_card_info.num
end

local function insert_map_list(map_list,key,value)
	if not map_list[key] then
		map_list[key] = {}
	end
	table.insert(map_list[key],value)
end

local function card_big_sort(card_list)
	table.sort(card_list,function(a,b)
		local a_card_info = get_card_info(a)
		local b_card_info = get_card_info(b)
		return a_card_info.num > b_card_info.num
	end)
end

local function card_small_sort(card_list)
	table.sort(card_list,function(a,b)
		local a_card_info = get_card_info(a)
		local b_card_info = get_card_info(b)
		return a_card_info.num < b_card_info.num
	end)
end

local function get_A_card_cnt(card_list)
	local card_A_cnt = 0
	for i = #card_list,#card_list - 1, -1 do
		local card_info = get_card_info(card_list[i])
		if card_info.num == 1 then--A
			card_A_cnt = card_A_cnt + 1
		end
	end
	return card_A_cnt
end

local function merge_card_list(from,to)
	for i = #from,1,-1 do
		local card_id = table.remove(from,i)
		table.insert(to,card_id)
	end
end

local function resolve_joker_cards(card_list,joker_card_id)
	local joker_card_list = {}
	for i = #card_list,1,-1 do
		local card_id = card_list[i]
		if is_joker_card(card_id,joker_card_id) then
			table.insert(joker_card_list,card_id)
			table.remove(card_list,i)
		end
	end
	return joker_card_list
end

local function new_del_and_add_sequence(cards_v,endIndex,startIndex,card_A_cnt)
	local pure_sequence = {}
	while (endIndex >= startIndex) do
		table.insert(pure_sequence,cards_v[endIndex])
		local end_card_num = get_card_num(cards_v[endIndex])
		local end_next_card_num = get_card_num(cards_v[endIndex - 1])
		if end_card_num == 1 then
			card_A_cnt = card_A_cnt - 1
		end
		local deleIndex = endIndex
		if end_card_num == end_next_card_num then
			endIndex = endIndex - 2
		else
			endIndex = endIndex - 1
		end
		table.remove(cards_v,deleIndex)
	end
	return pure_sequence,card_A_cnt
end

local function new_add_pure_sequence(pure_sequence_list,center_index_list,end_index,card_A_cnt,cards_v,start_index)
	local temp_end_index = end_index
	local temp_pure_sequence   --提前声明是为了返回A的使用数量
	if next(center_index_list) then
		center_index_list[0] = -100
		local center_index = center_index_list[#center_index_list]
		local rm_pos = #center_index_list
		local cen_cur_pos = #center_index_list - 1
		local cent_cnt = 0
		if center_index > 3 then
			while cen_cur_pos >= 0 do
				if center_index - center_index_list[cen_cur_pos] == 2 then
					center_index = center_index_list[cen_cur_pos]
					rm_pos = cen_cur_pos
					cent_cnt = cent_cnt + 1
				else
					local temp_card_cnt = 1
					
					local temp_cur_num = get_card_num(cards_v[center_index])
					for i = center_index + 1,end_index do
						local cards_v_num = get_card_num(cards_v[i])
						if temp_cur_num ~= cards_v_num then
							temp_card_cnt = temp_card_cnt + 1
						end
						temp_cur_num = cards_v_num
					end
					if temp_card_cnt >= 3 then
						temp_pure_sequence,card_A_cnt = new_del_and_add_sequence(cards_v,end_index,center_index,card_A_cnt)
						table.insert(pure_sequence_list,temp_pure_sequence)
						end_index = center_index_list[#center_index_list] - 1 - cent_cnt
					end
					center_index = center_index_list[cen_cur_pos]
					while cent_cnt + 1 > 0 do
						table.remove( center_index_list, rm_pos)
						cent_cnt = cent_cnt - 1
					end
					rm_pos = cen_cur_pos
					cent_cnt = 0
				end
				cen_cur_pos = cen_cur_pos - 1
			end
		end
	end

	if temp_end_index == end_index then
		temp_pure_sequence,card_A_cnt = new_del_and_add_sequence(cards_v,end_index,start_index,card_A_cnt)
		table.insert(pure_sequence_list,temp_pure_sequence)
	end

	return card_A_cnt,end_index
end

local function new_resolve_card_pure_sequence(tempCard_list,joker_card)
	local suit_map_list = {}
	local surplus_card_list = {}  --剩余的牌
	for i = #tempCard_list,1,-1 do
		local card_id = tempCard_list[i]
		if is_kind_card(card_id) then
			table.insert(surplus_card_list,card_id)
			table.remove(tempCard_list,i)
		else
			local card_info = get_card_info(card_id)
			insert_map_list(suit_map_list,card_info.suit,card_id)
		end
	end
	local pure_sequence_list = {}
	--找同花顺
	for suit_i,cards_v in pairs(suit_map_list) do
		if #cards_v >= 3 then
			card_big_sort(cards_v)
			local card_A_cnt = get_A_card_cnt(cards_v)
			for LOOP = 1, 2 do
				local startIndex = 1
				local count = 1
				local endIndex = 0
				local card_num = get_card_num(cards_v[1])
				local center_index_list = {}
				local center_end = 0
				local curpos = 2
				while curpos <= #cards_v do
					local cur_card_num = get_card_num(cards_v[curpos])
					if card_num - cur_card_num == 1 then
						count = count + 1
						card_num = cur_card_num
					elseif cur_card_num == card_num then
						table.insert(center_index_list,curpos)
					else
						endIndex = curpos - 1
						if count >= 3 then
							card_A_cnt,endIndex = new_add_pure_sequence(pure_sequence_list,center_index_list,endIndex,card_A_cnt,cards_v,startIndex)
							curpos = startIndex
						elseif count == 2 and card_A_cnt > 0 and get_card_info(cards_v[startIndex]).num == 13 then
							local temp_pure_sequence
							temp_pure_sequence,card_A_cnt = new_del_and_add_sequence(cards_v,endIndex,startIndex,card_A_cnt)
							table.insert(temp_pure_sequence,cards_v[#cards_v])
							card_A_cnt = card_A_cnt - 1
							table.remove(cards_v,#cards_v)
							table.insert(pure_sequence_list,temp_pure_sequence)
							curpos = startIndex
						end
						center_index_list = {}
						startIndex = curpos
						card_num = get_card_num(cards_v[curpos])
						count = 1
					end
					curpos = curpos + 1
				end
				if count >= 3 then     --有顺子
					endIndex = #cards_v
					card_A_cnt,endIndex = new_add_pure_sequence(pure_sequence_list,center_index_list,endIndex,card_A_cnt,cards_v,startIndex)
				end
			end
			if card_A_cnt > 0 then
				for i,card_list in ipairs(pure_sequence_list) do
					local card_info = get_card_info(card_list[#card_list])
					if card_info.suit == suit_i and card_info.num == 13 then
						table.insert(card_list,cards_v[#cards_v])
						card_A_cnt = card_A_cnt - 1
						table.remove(cards_v,#cards_v)
					end
					if card_A_cnt <= 0 then break end
				end
			end
		end
		
		merge_card_list(cards_v,surplus_card_list)
	end
	--找同花顺
	--如果能拆成几个就拆一下
	for i,card_list in ipairs(pure_sequence_list) do
		while #card_list >= 6 do
			local new_pure_sequence = {card_list[#card_list - 2],card_list[#card_list - 1],card_list[#card_list]}
			table.remove(card_list,#card_list)
			table.remove(card_list,#card_list)
			table.remove(card_list,#card_list)
			table.insert(pure_sequence_list,new_pure_sequence)
		end
	end

	return pure_sequence_list,surplus_card_list
end

local function subsets(nums) 
	local n = #nums
	local t = {}
	local ans = {}
	local mask = 0
	while mask < (1 << n) do
		t = {}
		for  i = 0, n - 1 do
			if (mask & (1 << i)) ~= 0 then
				table.insert(t,nums[i+1])
			end
		end
		table.insert(ans,t)
		mask = mask + 1
	end
	return ans
end

local function check_have_need_cards(pure_sequence_list,use_pure_map,need_card_id_map,joker_card_id)
	for index,card_list in ipairs(pure_sequence_list) do
		if not use_pure_map[index] then
			local is_over_loop = false
			for i,card_id in ipairs(card_list) do
				if is_joker_card(card_id,joker_card_id) or need_card_id_map[card_id] then break end
				if i == #card_list then
					is_over_loop = true
				end
			end
			if is_over_loop then return false end
		end
	end
	return true
end

local function check_need_combi_card_list(combi_card_list,need_card_id_map,joker_card_id)
	if not next(combi_card_list) then return true end
	for i,card_id in ipairs(combi_card_list) do
		if is_joker_card(card_id,joker_card_id) or need_card_id_map[card_id] then return true end
	end
	return false
end

local function get_resolve_pure_head_end(pure_sequence_list)
	local head_list = {}
	local end_list = {}
	local temp_combi = {}
	for _,list_v in ipairs(pure_sequence_list) do
		if #list_v > 3 then
			local l_len = #list_v
			local can_leve_cnt = l_len - 3
			
			local one_head_list = {}
			local one_end_list = {}

			for i = 1,can_leve_cnt do
				table.insert(one_head_list,list_v[i])
				table.insert(one_end_list,list_v[l_len - i + 1])
			end

			table.insert(head_list,one_head_list)
			table.insert(end_list,one_end_list)
		end
	end

	for i = 1,#head_list do
		
		local temp_l = {}
		for _,t_one_card in ipairs(head_list) do
			for _d,card_id in ipairs(t_one_card) do
				table.insert(temp_l,card_id)
				table.insert(temp_combi,table_clone(temp_l))
			end
		end
		for j = #head_list - 1,1,-1 do
			for k = 1,#head_list do
				local tmp_card_list = {}
				if k <= j then
					for _d,card_id in ipairs(head_list[i]) do
						table.insert(tmp_card_list,card_id)
					end
				else
					for _d,card_id in ipairs(end_list[i]) do
						table.insert(tmp_card_list,card_id)
					end
				end
			end
		end
		local temp_l = {}
		for _,t_one_card in ipairs(end_list) do
			for _d,card_id in ipairs(t_one_card) do
				table.insert(temp_l,card_id)
				table.insert(temp_combi,table_clone(temp_l))
			end
		end
		for j = #end_list - 1,1,-1 do
			for k = 1,#end_list do
				local tmp_card_list = {}
				if k <= j then
					for _d,card_id in ipairs(end_list[i]) do
						table.insert(tmp_card_list,card_id)
					end
				else
					for _d,card_id in ipairs(head_list[i]) do
						table.insert(tmp_card_list,card_id)
					end
				end
			end
		end
	end
	return temp_combi
end

function add_sort_seq_list(card_list,need_joker_cnt,joker_card_list)
	card_small_sort(card_list)
	if get_card_num(card_list[1]) == 1 and #card_list >= 2 and get_card_num(card_list[2]) - get_card_num(card_list[1]) - 1 > need_joker_cnt then
		local card_id = table.remove(card_list,1)
		table.insert(card_list,card_id + 13)
	end

	local cur_num = card_list[#card_list] % 100
	local pre_pos = #card_list - 1
	while pre_pos > 0 do
		local pre_num = card_list[pre_pos] % 100
		if cur_num - pre_num == 1 then
			cur_num = pre_num
		else
			if need_joker_cnt > 0 then
				cur_num = cur_num - 1
				need_joker_cnt = need_joker_cnt - 1
				pre_pos = pre_pos + 1
				local card_id = table.remove(joker_card_list,#joker_card_list)
				table.insert(card_list,pre_pos,card_id)
			else
				break
			end
		end
		pre_pos = pre_pos - 1
	end

	if need_joker_cnt > 0 then
		local card_id = table.remove(joker_card_list,#joker_card_list)
		if card_list[1] % 100 == 1 then
			table.insert(card_list,card_id)
		else
			table.insert(card_list,1,card_id)
		end
	end

	for i = 1,#card_list do
		if card_list[i] < 900 and card_list[i] % 100 == 14 then
			card_list[i] = card_list[i] - 13
		end
	end
end

local function get_need_joker_num(card_list,joker_card_id)
	local temp_card_list = table_clone(card_list)
	if rule.is_pure_sequence(card_list) then
		return 0
	end
	local need_joker_cnt = 0
	for i = 1,5 do
		table.insert(temp_card_list,902)
		need_joker_cnt = need_joker_cnt + 1
		if rule.is_sequence(temp_card_list,joker_card_id) then
			return need_joker_cnt
		end
	end

	return need_joker_cnt
end

local function add_temp_seq_list(temp_seq_list,card_list,joker_card_id,joker_cnt)
	local all_sub_card_list = subsets(card_list)
	for i,one_cards in ipairs(all_sub_card_list) do
		if #one_cards >= 2 then
			local need_joker = get_need_joker_num(one_cards,joker_card_id)
			if need_joker <= joker_cnt then
				table.insert(temp_seq_list,{type = GROUP_TYPE.sequence,need_joker_cnt = need_joker,card_list = one_cards})
			end
		end
	end
end

local function new_resolve_card_seq_set(surplus_card_list,joker_card_list,joker_card_id,_is_have_seq)
	local suit_map_list = {}
	local num_map_list = {}
	local card_index_map = {}  --剩余的牌
	for i = #surplus_card_list,1,-1 do
		local card_id = surplus_card_list[i]
		local card_info = get_card_info(card_id)
		insert_map_list(suit_map_list,card_info.suit,card_id)
		insert_map_list(num_map_list,card_info.num,card_id)
		card_index_map[card_id] = i
	end
	local user_card_index = {}
	local function user_surplus_card_id(__card_index_map,__user_card_index,card_id)
		table.insert(__user_card_index,__card_index_map[card_id])
		__card_index_map[card_id] = nil
	end

	local pure_seq_list = {}
	local sequence_list = {}
	local set_list = {}
	local temp_seq_list = {}
	local tt_joker_cnt = #joker_card_list
	for suit_i,list_v in pairs(suit_map_list) do
		if #list_v >= 2 and tt_joker_cnt > 0 then
			card_big_sort(list_v)
			local card_A_cnt = get_A_card_cnt(list_v)
			local startIndex = 1
			local endIndex = 0
			local curPos = 2
			local count = 1
			local cur_num = get_card_num(list_v[1])
			local nead_joker = 0
			while curPos <= #list_v do
				local next_num = get_card_num(list_v[curPos])
				if cur_num - next_num == 1 then
					count = count + 1
					cur_num = next_num
				elseif next_num == cur_num then
				elseif cur_num - next_num == 2 then   --差一个赖子补一下
					count = count + 2
					nead_joker = nead_joker + 1
					cur_num = next_num
				elseif cur_num - next_num == 3 then   --差2个赖子补一下
					count = count + 3
					nead_joker = nead_joker + 2
					cur_num = next_num
				else
					local sequence = {card_list = {},need_joker_cnt = 0,type = GROUP_TYPE.sequence}
					local have = false
					local start_index_num = get_card_info(list_v[startIndex]).num
					if card_A_cnt > 0 and
					 (start_index_num == 10 or
					 start_index_num == 11 or
					 start_index_num == 12 or
					 start_index_num == 13) then   --QKA
						table.insert(sequence.card_list,list_v[#list_v])
						have = true
						local add_need_joker = 1
						if start_index_num == 10 then
							add_need_joker = 3
						elseif start_index_num == 11 then
							add_need_joker = 2
						end
						nead_joker = nead_joker + add_need_joker
					elseif count == 2 then   --56
						have = true
						nead_joker = nead_joker + 1
					elseif count >= 3 then     --有顺子
						if nead_joker == 0 then
							endIndex = curPos - 1
							local tempsequence = {}
							tempsequence = new_del_and_add_sequence(list_v,endIndex,startIndex,card_A_cnt)
							table.insert(pure_seq_list,tempsequence)
						else
							have = true
						end
					end
					if have then
						endIndex = curPos - 1
						local tempsequence = {}
						tempsequence = new_del_and_add_sequence(list_v,endIndex,startIndex,card_A_cnt)
						for i,v in ipairs(tempsequence) do
							if not next(sequence.card_list) then
								table.insert(sequence.card_list,v)
							else
								table.insert(sequence.card_list,#sequence.card_list,v)
							end
						end
						add_temp_seq_list(temp_seq_list,sequence.card_list,joker_card_id,#joker_card_list)
						curPos = startIndex
					end

					startIndex = curPos
					cur_num = get_card_num(list_v[curPos])
					count = 1
					nead_joker = 0
				end
				curPos = curPos + 1
			end
			local sequence = {}
			local have = false
			if count == 2 then   --56
				have = true
				nead_joker = 1
			elseif count >= 3 then
				if nead_joker == 0 then
					endIndex = #list_v
					local sequence = {}
					sequence = new_del_and_add_sequence(list_v,endIndex,startIndex,card_A_cnt)
					table.insert(pure_seq_list,sequence)
				else
					have = true
				end
			end

			if have then
				endIndex = #list_v
				local sequence = {card_list = {},need_joker_cnt = nead_joker,type = GROUP_TYPE.sequence}
				sequence.card_list = new_del_and_add_sequence(list_v,endIndex,startIndex,card_A_cnt)
				add_temp_seq_list(temp_seq_list,sequence.card_list,joker_card_id,#joker_card_list)
			end
		end
	end

	for num_i,num_list in pairs(num_map_list) do
		if #num_list == 2 and get_card_info(num_list[1]).suit ~= get_card_info(num_list[2]).suit then
			local set_info = {card_list = {},need_joker_cnt = 1,type = GROUP_TYPE.set}
			table.insert(set_info.card_list,num_list[1])
			table.insert(set_info.card_list,num_list[2])
			table.insert(temp_seq_list,set_info)
		elseif #num_list >= 3 then
			local suit_cnt = {[suitType.Club] = 1,[suitType.Diamond] = 1,[suitType.Heart] = 1,[suitType.Spade] = 1}
			local aa_card_list = {}
			for num_i = #num_list, 1 ,-1 do
				if suit_cnt[get_card_info(num_list[num_i]).suit] > 0 and card_index_map[num_list[num_i]] then
					table.insert(aa_card_list,num_list[num_i])
					suit_cnt[get_card_info(num_list[num_i]).suit] = suit_cnt[get_card_info(num_list[num_i]).suit] - 1
				end
			end
			if #aa_card_list == 2 then
				local set_info = {card_list = aa_card_list,need_joker_cnt = 1,type = GROUP_TYPE.set}
				table.insert(temp_seq_list,set_info)
			end
		end
	end

	local LOOP_CNT = 2
	local first_flag = 1
	local best_score = nil
	local best_card_index_map = nil
	local best_user_card_index = nil
	local best_joker_card_list = nil
	local best_sequence_list = nil
	local best_set_list = nil
	for LOOP = 1,LOOP_CNT do
		local clone_user_card_index = table_clone(user_card_index)
		local clone_card_index_map = table_clone(card_index_map)
		local clone_set_list = table_clone(set_list)
		local clone_seq_list = table_clone(sequence_list)
		local clone_joker_card_list = table_clone(joker_card_list)
		for j = 1,2 do
			if first_flag == 1 then
				for num_i,num_list in pairs(num_map_list) do
					if #num_list >= 3 then
						local suit_cnt = {[suitType.Club] = 1,[suitType.Diamond] = 1,[suitType.Heart] = 1,[suitType.Spade] = 1}
						local aa_card_list = {}
						for num_i = #num_list, 1 ,-1 do
							if suit_cnt[get_card_info(num_list[num_i]).suit] > 0 and clone_card_index_map[num_list[num_i]] then
								table.insert(aa_card_list,num_list[num_i])
								suit_cnt[get_card_info(num_list[num_i]).suit] = suit_cnt[get_card_info(num_list[num_i]).suit] - 1
							end
						end
						if #aa_card_list >=3 then
							for k,card_id in ipairs(aa_card_list) do
								user_surplus_card_id(clone_card_index_map,clone_user_card_index,card_id)
							end
							table.insert(clone_set_list,aa_card_list)
						elseif #aa_card_list == 2 and #clone_joker_card_list > 0 then
							for k,card_id in ipairs(aa_card_list) do
								user_surplus_card_id(clone_card_index_map,clone_user_card_index,card_id)
							end
							local joker_card_id = table.remove(clone_joker_card_list,#clone_joker_card_list)
							table.insert(aa_card_list,joker_card_id)
							table.insert(clone_set_list,aa_card_list)
						end
					end
				end
				first_flag = 2
			else
				for i = #pure_seq_list,1,-1 do
					local is_ok = true
					for k,card_id in ipairs(pure_seq_list[i]) do
						if not clone_card_index_map[card_id] then is_ok = false break end
					end
					if not is_ok then
					else
						for k,card_id in ipairs(pure_seq_list[i]) do
							user_surplus_card_id(clone_card_index_map,clone_user_card_index,card_id)
						end
						table.insert(clone_seq_list,pure_seq_list[i])
					end
				end
				table.sort(temp_seq_list,function (a,b)
					if a.need_joker_cnt > b.need_joker_cnt then
						return false
					elseif a.need_joker_cnt < b.need_joker_cnt then
						return true
					end
					return get_cards_id_score(a.card_list,joker_card_id) > get_cards_id_score(b.card_list,joker_card_id) end)
				for _,one_temp_seq_info in ipairs(temp_seq_list) do
					if one_temp_seq_info.need_joker_cnt <= #clone_joker_card_list then
						local one_seq = table_clone(one_temp_seq_info.card_list)
						local is_ok = true
						for _i,card_id in ipairs(one_seq) do
							if not clone_card_index_map[card_id] then is_ok = false break end
						end
						if is_ok then
							for _i,card_id in ipairs(one_seq) do
								user_surplus_card_id(clone_card_index_map,clone_user_card_index,card_id)
							end
							if one_temp_seq_info.type == GROUP_TYPE.sequence then
								add_sort_seq_list(one_seq,one_temp_seq_info.need_joker_cnt,clone_joker_card_list)
							else
								for need_i = 1,one_temp_seq_info.need_joker_cnt do
									local joker_card_id = table.remove(clone_joker_card_list,#clone_joker_card_list)
									table.insert(one_seq,joker_card_id)
								end
							end
							if one_temp_seq_info.type == GROUP_TYPE.sequence then
								table.insert(clone_seq_list,one_seq)
							else
								table.insert(clone_set_list,one_seq)
							end
						end
					end
				end
				if LOOP == 2 then
					first_flag = 1
				end
			end
		end

		local temp_score = 0
		local is_have_seq = _is_have_seq
		for _,cc_card_list in ipairs(clone_seq_list) do
			temp_score = temp_score + get_cards_id_score(cc_card_list,joker_card_id)
			is_have_seq = true
		end
		if is_have_seq then
			for _,cc_card_list in ipairs(clone_set_list) do
				temp_score = temp_score + get_cards_id_score(cc_card_list,joker_card_id)
			end
		end
		if not best_score or temp_score > best_score then
			 best_score = temp_score
			 best_card_index_map  = clone_card_index_map
			 best_user_card_index = clone_user_card_index
			 best_joker_card_list = clone_joker_card_list
			 best_sequence_list   = clone_seq_list
			 best_set_list        = clone_set_list
		end
	end

	for i = #pure_seq_list,1,-1 do
		local is_ok = true
		for k,card_id in ipairs(pure_seq_list[i]) do
			if not best_card_index_map[card_id] then is_ok = false break end
		end
		if not is_ok then
			table.remove( pure_seq_list, i)
		else
			for k,card_id in ipairs(pure_seq_list[i]) do
				user_surplus_card_id(best_card_index_map,best_user_card_index,card_id)
			end
		end
	end

	table.sort(best_user_card_index,function(a,b) return a > b end)
	for i,index in ipairs(best_user_card_index) do
		table.remove(surplus_card_list,index)
	end

	if not _is_have_seq and #pure_seq_list <= 0 and #best_sequence_list <= 0 then
		local need_joker_cnt = 2 - #best_joker_card_list
	
		for i = #best_set_list,1,-1 do
			if need_joker_cnt > 0 then
				local one_card_list = best_set_list[i]
				local is_have_joker = false
				for _,card_id in ipairs(one_card_list) do
					if is_joker_card(card_id,joker_card_id) then
						is_have_joker = true
						break
					end
				end
				if is_have_joker then
					for _,card_id in ipairs(one_card_list) do
						if is_joker_card(card_id,joker_card_id) then
							table.insert(best_joker_card_list,card_id)
							need_joker_cnt = need_joker_cnt - 1
						else
							table.insert(surplus_card_list,card_id)
						end
					end
					table.remove(best_set_list,i)
				end
			end
		end
	end

	if #best_joker_card_list >=2 and #surplus_card_list >= 1 then
		card_big_sort(surplus_card_list)
		local one_seq = {}
		table.insert(one_seq,surplus_card_list[1])
		table.remove(surplus_card_list,1)
		for i = 1,2 do
			table.insert(one_seq,best_joker_card_list[#best_joker_card_list])
			table.remove(best_joker_card_list,#best_joker_card_list)
		end
		table.insert(best_sequence_list,one_seq)
	end
	local pure_sequence_list,pure_surplus_card_list = new_resolve_card_pure_sequence(surplus_card_list,joker_card_id)
	merge_card_list(pure_sequence_list,pure_seq_list)
	return pure_seq_list,best_sequence_list,best_set_list,best_joker_card_list,pure_surplus_card_list
end

local function get_head_card(card_list,joker_card_id)
	local connect_joker_cnt = 0
	for i,card_id in ipairs(card_list) do
		if is_joker_card(card_id,joker_card_id) then
			connect_joker_cnt = connect_joker_cnt + 1
		else
			return card_id_value_map[card_id - connect_joker_cnt] or 0x4F
		end
	end
	return 0x4F
end

local function get_end_card(card_list,joker_card_id)
	local connect_joker_cnt = 0
	for i = #card_list,1,-1 do
		local card_id = card_list[i]
		if is_joker_card(card_id,joker_card_id) then
			connect_joker_cnt = connect_joker_cnt + 1
		else
			return card_id_value_map[card_id + connect_joker_cnt] or 0x4F
		end
	end
	return 0x4F
end

local function adjust_combi_card_list(one_combi,temp_combi_pure_sequence_list,temp_resolve_surplus_card_list,joker_card_id)
	for _,card_value in ipairs(one_combi) do
		for i,pure_card_list in ipairs(temp_combi_pure_sequence_list) do
			if #pure_card_list > 3 then
				if card_value == pure_card_list[1] then
					table.remove(pure_card_list,1)
					break
				end
				if card_value == pure_card_list[#pure_card_list] then
					table.remove(pure_card_list,#pure_card_list)
					break
				end
			end
		end
	end

	local card_value_map_index = {}

	for i = #temp_resolve_surplus_card_list,1,-1 do
		local card_value = card_id_value_map[temp_resolve_surplus_card_list[i]]
		card_value_map_index[card_value] = {index = i,card_id = temp_resolve_surplus_card_list[i]}
	end

	local rm_surplus_card_index = {}
	for _,pure_card_list in ipairs(temp_combi_pure_sequence_list) do
		local head_card = get_head_card(pure_card_list,joker_card_id)
		if card_value_map_index[head_card - 1] then
			table.insert(pure_card_list,1,card_value_map_index[head_card - 1].card_id)
			table.insert(rm_surplus_card_index,card_value_map_index[head_card - 1].index)
			card_value_map_index[head_card - 1] = nil
		end
		local end_card = get_end_card(pure_card_list,joker_card_id)
		if allCards[end_card].num == 13 then
			local need_card = end_card - 12
			if card_value_map_index[need_card] then
				table.insert(pure_card_list,card_value_map_index[need_card].card_id)
				table.insert(rm_surplus_card_index,card_value_map_index[need_card].index)
				card_value_map_index[need_card] = nil
			end
		elseif allCards[end_card].num == 1 then
		else
			if card_value_map_index[end_card + 1] then
				table.insert(pure_card_list,card_value_map_index[end_card + 1].card_id)
				table.insert(rm_surplus_card_index,card_value_map_index[end_card + 1].index)
				card_value_map_index[end_card + 1] = nil
			end
		end
	end

	table.sort(rm_surplus_card_index,function(a,b) return a > b end)
	for _,index in ipairs(rm_surplus_card_index) do
		table.remove(temp_resolve_surplus_card_list,index)
	end
end

local function get_new_best_group_list(card_list_id,joker_card_id,_is_seq)
	local tempCard_list = table_clone(card_list_id)
	local pure_sequence_list,surplus_card_list = new_resolve_card_pure_sequence(tempCard_list,joker_card_id)
	local joker_card_list = resolve_joker_cards(surplus_card_list,joker_card_id)
	local pure_index = {}
	for i,v in ipairs(pure_sequence_list) do
		table.insert(pure_index,i)
	end
	local all_sub_index = subsets(pure_index)
	local best_score = nil
	local best_pure_seq_list = nil
	local best_sequence_list = nil
	local best_set_list = nil
	local best_surplus_card_list = nil
	local best_joker_card_list = nil
	for _,one_index_list in pairs(all_sub_index) do
		local temp_surplus_card_list = table_clone(surplus_card_list)
		local use_pure_map = {}
		for _,p_index in ipairs(one_index_list) do
			use_pure_map[p_index] = true
		end
		
		local temp_pure_sequence_list = table_clone(pure_sequence_list)
		for i = #temp_pure_sequence_list,1,-1 do
			local card_v = temp_pure_sequence_list[i]
			if not use_pure_map[i] then
				merge_card_list(card_v,temp_surplus_card_list)
				table.remove(temp_pure_sequence_list,i)
			end
		end
		local is_have_seq = _is_seq
		if #temp_pure_sequence_list > 1 then
			is_have_seq = true
		end
		local temp_joker_list = table_clone(joker_card_list)
		local temp_surplus_joker_list = resolve_joker_cards(temp_surplus_card_list,joker_card_id)
		merge_card_list(temp_surplus_joker_list,temp_joker_list)

		local temp_combi = get_resolve_pure_head_end(temp_pure_sequence_list)
		table.insert(temp_combi,{})
		
		for _,one_combi in ipairs(temp_combi) do
			local temp_combi_pure_sequence_list = table_clone(temp_pure_sequence_list)
			local temp_combi_card_list = table_clone(one_combi)
			local temp_combi_joker_list = table_clone(temp_joker_list)
			local temp_combi_surplus_joker_list = resolve_joker_cards(temp_combi_card_list,joker_card_id)
			merge_card_list(temp_combi_surplus_joker_list,temp_combi_joker_list)
			local temp_combi_surplus_card_list = table_clone(temp_surplus_card_list)
			merge_card_list(temp_combi_card_list,temp_combi_surplus_card_list)
			local temp_pure_seq_list,temp_combi_sequence_list,temp_combi_set_list,temp_combi_joker_card_list,temp_resolve_surplus_card_list = new_resolve_card_seq_set(
				temp_combi_surplus_card_list,temp_combi_joker_list,joker_card_id,is_have_seq)

			merge_card_list(temp_pure_seq_list,temp_combi_pure_sequence_list)

			local seq_temp_combi = get_resolve_pure_head_end(temp_combi_sequence_list)
			local seq_best_score = get_cards_id_score(temp_resolve_surplus_card_list,joker_card_id)
			local seq_best_pure_seq_list = temp_pure_seq_list
			local seq_best_sequence_list = temp_combi_sequence_list
			local seq_best_set_list = temp_combi_set_list
			local seq_best_surplus_card_list = temp_resolve_surplus_card_list
			local seq_best_joker_card_list = temp_combi_joker_card_list
			local seq_one_seq_combi = {}
			for _s,one_seq_combi in ipairs(seq_temp_combi) do
				local seq_temp_card_list = table_clone(one_seq_combi)
				local seq_temp_joker_card_list = table_clone(temp_combi_joker_card_list)
				
				local seq_temp_combi_surplus_joker_list = resolve_joker_cards(seq_temp_card_list,joker_card_id)
				merge_card_list(seq_temp_combi_surplus_joker_list,seq_temp_joker_card_list)

				local seq_temp_surplus_card_list = table_clone(temp_resolve_surplus_card_list)
				merge_card_list(seq_temp_card_list,seq_temp_surplus_card_list)

				local seq_temp_pure_seq_list,seq_temp_combi_sequence_list,seq_temp_combi_set_list,seq_temp_combi_joker_card_list,seq_temp_resolve_surplus_card_list = new_resolve_card_seq_set(
					seq_temp_surplus_card_list,seq_temp_joker_card_list,joker_card_id,true)

				local score = get_cards_id_score(seq_temp_resolve_surplus_card_list,joker_card_id)
				if not seq_best_score or score < seq_best_score then
					seq_best_score = score
					seq_best_pure_seq_list = seq_temp_pure_seq_list
					seq_best_sequence_list = seq_temp_combi_sequence_list
					seq_best_set_list = seq_temp_combi_set_list
					seq_best_surplus_card_list = seq_temp_resolve_surplus_card_list
					seq_best_joker_card_list = seq_temp_combi_joker_card_list
					seq_one_seq_combi = one_seq_combi
				end
			end

			if seq_best_score ~= nil then
				temp_resolve_surplus_card_list = seq_best_surplus_card_list
				temp_combi_joker_card_list = seq_best_joker_card_list
				merge_card_list(seq_best_pure_seq_list,temp_combi_pure_sequence_list)
				merge_card_list(seq_best_sequence_list,temp_combi_sequence_list)
				merge_card_list(seq_best_set_list,temp_combi_set_list)
				adjust_combi_card_list(seq_one_seq_combi,temp_combi_sequence_list,temp_resolve_surplus_card_list,joker_card_id)
			end

			adjust_combi_card_list(one_combi,temp_combi_pure_sequence_list,temp_resolve_surplus_card_list,joker_card_id)

			for i = #temp_combi_sequence_list,1,-1 do
				if rule.is_pure_sequence(temp_combi_sequence_list[i]) then
					local tt_card_list = table.remove(temp_combi_sequence_list,i)
					table.insert(temp_combi_pure_sequence_list,tt_card_list)
				end
			end

			local score = 10000
			if #temp_combi_pure_sequence_list >= 2 or (#temp_combi_pure_sequence_list == 1 and #temp_combi_sequence_list >= 1) then
				score = get_cards_id_score(temp_resolve_surplus_card_list,joker_card_id)
			else
				if #temp_combi_pure_sequence_list == 0 then
					for _tt,seq_card_list in ipairs(temp_combi_sequence_list) do
						if score == 10000 then
							score = get_cards_id_score(seq_card_list,joker_card_id)
						else
							score = score + get_cards_id_score(seq_card_list,joker_card_id)
						end
					end
				end
				for _tt,set_card_list in ipairs(temp_combi_set_list) do
					if score == 10000 then
						score = get_cards_id_score(set_card_list,joker_card_id)
					else
						score = score + get_cards_id_score(set_card_list,joker_card_id)
					end
				end
			end
			if not best_score or score < best_score then
				best_score = score
				best_pure_seq_list = temp_combi_pure_sequence_list
				best_sequence_list = temp_combi_sequence_list
				best_set_list = temp_combi_set_list
				best_surplus_card_list = temp_resolve_surplus_card_list
				best_joker_card_list = temp_combi_joker_card_list
			end
			if best_score == 0 then
				break
			end
		end
		if best_score == 0 then
			break
		end
	end
	
	local group_list = {}
	local is_pure_seq = false
	local is_seq = _is_seq

	for i = #best_pure_seq_list, 1,-1 do
		add_group_list(group_list,best_pure_seq_list[i],GROUP_TYPE.pure_sequence)
		assert(rule.is_pure_sequence(best_pure_seq_list[i]))
		if is_pure_seq then
			is_seq = true
		end
		is_pure_seq = true
	end

	for i = #best_sequence_list, 1,-1 do
		add_group_list(group_list,best_sequence_list[i],GROUP_TYPE.sequence)
		assert(rule.is_sequence(best_sequence_list[i],joker_card_id))
		is_seq = true
	end

	
	local temp_card_list = best_surplus_card_list

	for i = #best_set_list, 1,-1 do
		assert(rule.is_set(best_set_list[i],joker_card_id))
		if is_pure_seq and is_seq then
			add_group_list(group_list,best_set_list[i],GROUP_TYPE.set)
		else
			for _,card_id in ipairs(best_set_list[i]) do
				table.insert(temp_card_list,card_id)
			end
		end
	end

	if #best_joker_card_list > 0 then
		add_group_list(group_list,best_joker_card_list,GROUP_TYPE.joker)
	end
	
	if #temp_card_list > 0 then
		add_group_list(group_list,temp_card_list,GROUP_TYPE.invalid)
	end
	return group_list
end

local function get_hand_card_score(hands_cards,joker_id,_is_seq)
	local group_list = get_new_best_group_list(hands_cards,joker_id,_is_seq)

	local is_pure_seq = false
	local is_seq = _is_seq

	for i,one_group in ipairs(group_list) do
		local card_list = one_group.card_list
		one_group.score = rule.get_score_card_list(card_list,joker_id)
		if one_group.type == GROUP_TYPE.pure_sequence then
			if is_pure_seq then
				is_seq = true
			else
				is_pure_seq = true
			end
		elseif one_group.type == GROUP_TYPE.sequence then
			is_seq = true
		end
	end

	local result = (is_pure_seq and is_seq)
	local score = 0

	for i,one_group in ipairs(group_list) do
		if result then
			if one_group.type == GROUP_TYPE.invalid then
				score = score + one_group.score
			end
		else
			if one_group.type ~= GROUP_TYPE.pure_sequence and one_group.type ~= GROUP_TYPE.jokers then
				score = score + one_group.score
			end
		end
	end

	return score
end

function rule.get_group_list_id(card_list_id,joker_card_id,is_seqss)
	local ok,group_list = pcall(get_group_list_id,card_list_id,joker_card_id,is_seqss)
	if not ok then
		log.error("get_group_list_id group_card_value_to_card_id err ",card_list_id,joker_card_id,is_seqss)
		return {}
	end
	return group_list
end

local function adapter_touch_close_deck_card(hand_cards,closed_deck_id,joker_id,_is_seq)
	if not next(hand_cards) or not next(closed_deck_id) then
		return nil
	end
	local group_list = get_group_list_id(hand_cards,joker_id,_is_seq)
	local need_card_map = get_group_list_need_card_map(group_list,joker_id,_is_seq)

	local ret_index = nil

	for index = #closed_deck_id,1,-1 do
		if need_card_map[closed_deck_id[index]] then
			ret_index = index
			break
		end
	end

	return ret_index
end

function rule.adapter_touch_close_deck_card(hand_cards,closed_deck_id,joker_id,_is_seq)
	local ok,ret_index = pcall(adapter_touch_close_deck_card,hand_cards,closed_deck_id,joker_id,_is_seq)
	if not ok then
		log.error("adapter_touch_close_deck_card err ",hand_cards,closed_deck_id,joker_id,_is_seq)
		return nil
	end
	return ret_index
end

local function adapter_bad_touch_close_deck_card(hand_cards,closed_deck_id,joker_id,_is_seq)
	if not next(hand_cards) or not next(closed_deck_id) then
		return nil
	end
	local group_list = get_group_list_id(hand_cards,joker_id,_is_seq)
	local need_card_map = get_group_list_need_card_map(group_list,joker_id,_is_seq)
	local joker_id_value = joker_id % 100
	local ret_index = nil

	for index = #closed_deck_id,1,-1 do
		if closed_deck_id[index] < 900 and not need_card_map[closed_deck_id[index]] and closed_deck_id[index] % 100 ~= joker_id_value then
			ret_index = index
			break
		end
	end

	return ret_index
end

function rule.adapter_bad_touch_close_deck_card(hand_cards,closed_deck_id,joker_id,_is_seq)
	local ok,ret_index = pcall(adapter_bad_touch_close_deck_card,hand_cards,closed_deck_id,joker_id,_is_seq)
	if not ok then
		log.error("adapter_bad_touch_close_deck_card err ",hand_cards,closed_deck_id,joker_id,_is_seq)
		return nil
	end
	return ret_index
end

function rule.split_invalid_group_by_suit(group_list)
	local card_id_list = {}
	local joker_card_list = {}
	for i = #group_list,1,-1 do
		local one_group = group_list[i]
		if one_group.type == GROUP_TYPE.invalid then
			for _,one_card in ipairs(one_group.card_list) do
				table.insert(card_id_list,one_card)
			end
			table.remove(group_list,i)
		end
	end
	local suit_cards_map = {[suitType.Diamond] = {},[suitType.Club] = {},[suitType.Heart] = {},[suitType.Spade] = {}}
	for _,card_id in ipairs(card_id_list) do
		local suit = math.floor(card_id / 100)
		if suit > 4 then
			suit = suit - 4
		end
		suit = suit - 1
		if suit_cards_map[suit] then
			table.insert(suit_cards_map[suit],card_id)
		else
			table.insert(joker_card_list,card_id)
		end
	end
	if next(joker_card_list) then
		add_group_list(group_list,joker_card_list,GROUP_TYPE.joker)
	end

	for suit,card_list in pairs(suit_cards_map) do
		if next(card_list) then
			if #group_list < 6 then
				add_group_list(group_list,card_list,GROUP_TYPE.invalid)
			else
				local last_card_list = group_list[#group_list].card_list
				for _,card_id in ipairs(card_list) do
					table.insert(last_card_list,card_id)
				end
			end
		end
	end
end

local function sort_card_list(seat_card_list,joker_card_id)
	table.sort(seat_card_list,function(a,b) 
		local a_group_list = get_group_list(a,joker_card_id)
		local b_group_list = get_group_list(b,joker_card_id)
		local a_invalid_count = 0
		local b_invalid_count = 0
		if next(a_group_list) then
			a_invalid_count = a_invalid_count + #a_group_list[#a_group_list].card_list
		end
		if next(b_group_list) then
			b_invalid_count = b_invalid_count + #b_group_list[#b_group_list].card_list
		end

		return a_invalid_count < b_invalid_count
	end)
	--散牌小的在前面
	return true
end

function rule.sort_card_list(seat_card_list,joker_card_id)
	local temp_seat_card_list = table_clone(seat_card_list)
	local ok,ret = pcall(sort_card_list,seat_card_list,joker_card_id)
	if not ok then
		log.error("sort_card_list err:",temp_seat_card_list,joker_card_id)
		seat_card_list = temp_seat_card_list
		return false
	end
	return true
end

local CARD_JOKER_RAND = {
	[0x0D] = 1000,  --K
	[0x0C] = 1000,  --Q
	[0x0B] = 1000,  --J
	[0x0A] = 1000, --10
	[0x09] = 1000, --9
	[0x08] = 1000, --8
	[0x07] = 1000, --7
	[0x06] = 1000, --6
	[0x05] = 1000, --5
	[0x04] = 1000, --4
	[0x03] = 1000, --3
	[0x02] = 1000, --2
	[0x01] = 1000, --A
}

local GROUP_RAND = {
	[GROUP_TYPE.pure_sequence] = 2000,
	[GROUP_TYPE.sequence] = 3000,
	[GROUP_TYPE.set] = 5000
}

local JOKER_CNT = {
	[0] = 6000,
	[1] = 3000,
	[2] = 1000
}

local SEQ_CNT_RAND = {
	[3] = 5000,
	[4] = 3000,
	[5] = 2000
}

local function score_alloc_cards(_card_cnt,_player_cnt)
	local temp_card_num_map = table_clone(CardNumMap)
	local seat_cards_list = {}
	local joker_card_id = 0
	local remaining_cards = {}
	local is_10_card = _card_cnt == 10
	local function pop_one_card_id(num_index,suit_index)
		local card_id = temp_card_num_map[num_index][suit_index]
		temp_card_num_map[num_index][suit_index] = 0
		return card_id
	end

	local function push_one_card_id(card_id)
		local rm_num_index = card_id % 100
		local rm_suit_index = math.floor(card_id / 100)
		temp_card_num_map[rm_num_index][rm_suit_index] = card_id
	end

	--找赖子
	local rand_joker_num = rand_table(CARD_JOKER_RAND)
	local rand_joker_suit = math.random(1,8)
	joker_card_id = pop_one_card_id(rand_joker_num,rand_joker_suit)

	--发玩家牌
	for i = 1,_player_cnt do
		--先搞一个纯序列嘛
		local one_card_group_list = {}
		local need_group_type_list = {GROUP_TYPE.sequence,GROUP_TYPE.pure_sequence}
		if is_10_card then
			need_group_type_list = {GROUP_TYPE.pure_sequence}
		end
		local need_group_type = nil
		local one_cards_cnt = 0
		local cnt = 0
		local joker_card_num = joker_card_id % 100
		while one_cards_cnt < _card_cnt do
			cnt = cnt + 1
			local one_cards_info = {group_type = need_group_type,card_list = {}}
			
			if need_group_type then
				local rand_suit = math.random(1,8)
				local card_cnt  = rand_table(SEQ_CNT_RAND)
				if need_group_type == GROUP_TYPE.pure_sequence or need_group_type == GROUP_TYPE.sequence then
					local start_card_num = math.random(0x01,0x0D - card_cnt + 2)
					for card_i = 1, card_cnt do
						if temp_card_num_map[start_card_num][rand_suit] ~= 0 then
							table.insert(one_cards_info.card_list,pop_one_card_id(start_card_num,rand_suit))
							start_card_num = start_card_num + 1
							if start_card_num > 0x0D then
								start_card_num = 0x01
							end
						else
							break
						end
					end
				else
					local start_card_num = math.random(0x01,0x0D)
					if joker_card_num ~= start_card_num % 100 then
						if card_cnt > 4 then
							card_cnt = 4
						end
						local suit_cnt_map = {[1] = 0,[2] = 0,[3] = 0, [4] = 0}
						local get_cnt = 0
						for suit_i = rand_suit,8 do
							if get_cnt >= card_cnt then break end
							local suit = suit_i
							if suit > 4 then
								suit = suit - 4
							end
							if temp_card_num_map[start_card_num][suit_i] ~= 0 and suit_cnt_map[suit] == 0 then
								table.insert(one_cards_info.card_list,pop_one_card_id(start_card_num,suit_i))
								suit_cnt_map[suit] = 1
								get_cnt = get_cnt + 1
							end
						end

						for suit_i = 1,rand_suit - 1 do
							if get_cnt >= card_cnt then break end
							local suit = suit_i
							if suit > 4 then
								suit = suit - 4
							end
							if temp_card_num_map[start_card_num][suit_i] ~= 0 and suit_cnt_map[suit] == 0 then
								table.insert(one_cards_info.card_list,pop_one_card_id(start_card_num,suit_i))
								suit_cnt_map[suit] = 1
								get_cnt = get_cnt + 1
							end
						end
					end
				end

				if #one_cards_info.card_list == card_cnt or cnt > 1000 then
					table.insert(one_card_group_list,one_cards_info)
					one_cards_cnt = one_cards_cnt + card_cnt
					need_group_type = nil
					if cnt > 1000 then break end   --防止死循环
				else
					for _,card_id in ipairs(one_cards_info.card_list) do
						push_one_card_id(card_id)
					end
				end
			else
				if #need_group_type_list > 0 then
					need_group_type = table.remove(need_group_type_list,#need_group_type_list)
				else
					need_group_type = rand_table(GROUP_RAND)
				end
			end
		end
		--校队调整牌数量
		local sur_cnt = one_cards_cnt - _card_cnt
		local LOOP = 1
		while sur_cnt > 0 do
			local is_not_set = true
			for _,one_group in ipairs(one_card_group_list) do
				if sur_cnt <= 0 then break end
				if one_group.group_type == GROUP_TYPE.set then
					for i = #one_group.card_list,1,-1 do
						push_one_card_id(one_group.card_list[i])
						table.remove(one_group.card_list,i)
						sur_cnt = sur_cnt - 1
						if sur_cnt <= 0 then break end
					end
					is_not_set = false
				else
					if LOOP > 1 and is_not_set then
						for i = #one_group.card_list,1,-1 do
							push_one_card_id(one_group.card_list[i])
							table.remove(one_group.card_list,i)
							sur_cnt = sur_cnt - 1
							if sur_cnt <= 0 then break end
						end
					end
				end
			end
			LOOP = LOOP + 1
		end

		--这里替换赖子下来
		local joker_card_cnt = rand_table(JOKER_CNT)
		--从2开始过滤一个纯序列
		for i = 2,#one_card_group_list do
			local one_group = one_card_group_list[i]
			if joker_card_cnt > 0 then
				if #one_group.card_list > 0 then
					local rand_num = math.random(1,10000)
					local start_suit = math.random(1,8)
					local one_joker_id = nil
					for JOKER_LOOP = 1,2 do
						if rand_num < 8000 then
							for suit_i = start_suit,8 do
								if temp_card_num_map[joker_card_num][suit_i] ~= 0 then
									one_joker_id = pop_one_card_id(joker_card_num,suit_i)
									break
								end
							end
							if not one_joker_id then
								for suit_i = 1,start_suit - 1 do
									if temp_card_num_map[joker_card_num][suit_i] ~= 0 then
										one_joker_id = pop_one_card_id(joker_card_num,suit_i)
										break
									end
								end
							end
							if not one_joker_id then
								rand_num = 8001
							else
								break
							end
						else
							if temp_card_num_map[0x0F][1] ~= 0 then
								one_joker_id = pop_one_card_id(0x0F,1)
							elseif temp_card_num_map[0x0E][1] ~= 0 then
								one_joker_id = pop_one_card_id(0x0E,1)
							end
							if not one_joker_id then
								rand_num = 7000
							else
								break
							end
						end
					end
					if not one_joker_id then break end  --没有赖子可用啦
					local card_list = one_group.card_list
					
					local rm_index = math.random(1,#card_list)
					local rm_card_id = card_list[rm_index]
					table.remove(card_list,rm_index)
					push_one_card_id(rm_card_id)
				
					joker_card_cnt = joker_card_cnt - 1
					table.insert(card_list,one_joker_id)
				end
			else
				break
			end
		end

		local one_card_list = {}
		for _,one_group in ipairs(one_card_group_list) do
			for _d,card_id in ipairs(one_group.card_list) do
				table.insert(one_card_list,card_id)
			end
		end	
		table.insert(seat_cards_list,one_card_list)
	end

	for card_num,card_suit_info in pairs(temp_card_num_map) do
		for card_suit,card_id in pairs(card_suit_info) do
			if card_id ~= 0 then
				table.insert(remaining_cards,card_id)
			end
		end
	end

	rule.shufflethecards(remaining_cards)

	for _,card_list in ipairs(seat_cards_list) do
		while #card_list < _card_cnt do
			local index = math.random(1,#remaining_cards) 
			table.insert(card_list,remaining_cards[index])
			table.remove(remaining_cards,index)
		end
	end
	return seat_cards_list,joker_card_id,remaining_cards
end

function rule.score_alloc_cards(_card_cnt,_player_cnt)
	local ok,seat_cards_list,joker_card_id,remaining_cards = pcall(score_alloc_cards,_card_cnt,_player_cnt)
	if not ok then
		log.error("score_alloc_cards err:",_card_cnt,_player_cnt)
		return rule.random_allot_cards(_card_cnt,_player_cnt)
	end
	return seat_cards_list,joker_card_id,remaining_cards
end

local function adjust_hand_score(hand_cards,close_desk_cards,joker_card_id,score_num,_is_seq,filter_card_map)
	local group_list = get_group_list_id(hand_cards,joker_card_id,_is_seq)
	local need_rm_card_cnt = math.floor(score_num / 10)
	if score_num % 10 ~= 0 then need_rm_card_cnt = need_rm_card_cnt + 1 end
	local rm_card_list = {}

	for i = #group_list,1,-1 do
		local t_one_group = group_list[i]
		local group_card_list = t_one_group.card_list
		for card_i = #group_card_list,1,-1 do
			if not filter_card_map[card_i] then
				local one_card_id = table.remove(group_card_list,card_i)
				table.insert(rm_card_list,one_card_id)
				need_rm_card_cnt = need_rm_card_cnt - 1
				if need_rm_card_cnt <= 0 then break end
			end
		end
		if #group_card_list == 0 then table.remove(group_list,i) end
		if need_rm_card_cnt <= 0 then break end
	end

	local temp_card_list = {}
	for _,one_group in ipairs(group_list) do
		for _a,card_id in ipairs(one_group.card_list) do
			table.insert(temp_card_list,card_id)
		end
	end

	local score = get_hand_card_score(temp_card_list,joker_card_id,_is_seq)
	local temp_score_num = score_num - score
	local adjust_card_cnt = #rm_card_list

	local one_group = {
		card_list = {},
		type = GROUP_TYPE.invalid
	}
	table.insert(group_list,one_group)

	local adjust_card_index_list = {}
	local usered_index_map = {} 
	local one_group = group_list[#group_list]
	for i = 1,adjust_card_cnt do
		local card_score_map = {}
		local need_card_map = get_group_list_need_card_map(group_list,joker_card_id,_is_seq)
		for index,card_id in ipairs(close_desk_cards) do
			if not need_card_map[card_id] and card_id % 100 ~= joker_card_id % 100 and card_id < 900 and not usered_index_map[index] then
				local card_value = card_id_to_card_value(card_id)
				local card_score = allCards[card_value].score
				if not card_score_map[card_score] then
					card_score_map[card_score] = {}
				end
				table.insert(card_score_map[card_score],index)
			end
		end
		local start_score = 10
		if temp_score_num < 10 then
			start_score = temp_score_num
		end
		temp_score_num = temp_score_num - start_score
		if start_score ~= 0 then
			local is_find_card = false
			for i = start_score,1,-1 do
				local card_index_list = card_score_map[i]
				if card_index_list then
					local one_card_index = card_index_list[#card_index_list]
					usered_index_map[one_card_index] = true
					table.insert(adjust_card_index_list,one_card_index)
					table.insert(one_group.card_list,close_desk_cards[one_card_index])
					is_find_card = true
					break
				end
			end
			if not is_find_card then
				for i = start_score + 1,10 do
					local card_index_list = card_score_map[i]
					if card_index_list then
						local one_card_index = card_index_list[#card_index_list]
						usered_index_map[one_card_index] = true
						table.insert(adjust_card_index_list,one_card_index)
						table.insert(one_group.card_list,close_desk_cards[one_card_index])
						break
					end
				end
			end
		else
			for index,card_id in ipairs(close_desk_cards) do
				if not usered_index_map[index] and need_card_map[card_id] then
					usered_index_map[index] = true
					table.insert(adjust_card_index_list,index)
					table.insert(one_group.card_list,card_id)
					break
				end
			end
		end
	end

	--这里补齐牌
	local card_list_len = #one_group.card_list
	for i = card_list_len + 1,adjust_card_cnt do
		local index = math.random(1,#rm_card_list)
		local card_id = table.remove(rm_card_list,index)
		table.insert(one_group.card_list,card_id)
	end

	--然后删除替换出来的close_desk 把从手牌中拿出的牌放进去
	table.sort(adjust_card_index_list,function(a,b) return a > b end)
	for _,index in ipairs(adjust_card_index_list) do
		table.remove(close_desk_cards,index)
	end

	for _,card_id in ipairs(rm_card_list) do
		table.insert(close_desk_cards,card_id)
	end

	local ret_hand_cards = {}
	for _,one_group in ipairs(group_list) do
		for _i,card_id in ipairs(one_group.card_list) do
			table.insert(ret_hand_cards,card_id)
		end
	end
	return ret_hand_cards
end

function rule.adjust_hand_score(hand_cards,close_desk_cards,joker_card_id,score_num,_is_seq,filter_card_map)
	local ok,ret_hand_cards = pcall(adjust_hand_score,hand_cards,close_desk_cards,joker_card_id,score_num,_is_seq,filter_card_map)
	if not ok then
		log.error("adjust_hand_score err:",hand_cards,close_desk_cards,joker_card_id,score_num,_is_seq,filter_card_map)
		return hand_cards
	end
	return ret_hand_cards
end

function rule.get_hand_card_score(hands_cards,joker_id,_is_seq)
	local ok,score = pcall(get_hand_card_score,hands_cards,joker_id,_is_seq)
	if not ok then
		log.error("get_hand_card_score err:",hands_cards,joker_id,_is_seq)
		return 80
	end
	return score
end

function rule.re_random_allot_card_list(hand_cards,remaining_cards)
	local card_cnt = #hand_cards
	for _,card_id in ipairs(hand_cards) do
		table.insert(remaining_cards,card_id)
	end

	rule.shufflethecards(remaining_cards)

	local new_hand_cards = {}
	for j = 1,card_cnt do
		local index = math.random(1,#remaining_cards) 
		table.insert(new_hand_cards,remaining_cards[index])
		table.remove(remaining_cards,index)
	end
	return new_hand_cards
end

function rule.filter_joker_touch_close_deck_card(closed_deck,joker_card)
	local ret_index = nil
	for i = #closed_deck,1,-1 do
		local card_id = closed_deck[i]
		if card_id % 100 ~= joker_card % 100 and card_id < 900 then
			ret_index = i
			break
		end
	end
	return ret_index
end

local function auto_touch_card(hand_cards,open_card_info,Joker_card_id,last_dis_card_id,is_seq)
	--1摸开放区  2摸关闭区
	if not open_card_info then return 2 end

	local open_card_id = open_card_info.card_id

	if last_dis_card_id == open_card_id then
		return 2
	end

	local seat_id = open_card_info.seat_id
	if seat_id == 0 then                      --0为开局第一张 系统发的，可以拿
		if open_card_id > 900 or open_card_id % 100 == Joker_card_id % 100 then  
			return 1
		end
	end

	if open_card_id > 900 or open_card_id % 100 == Joker_card_id % 100 then   --赖子不能摸
		return 2
	end
	local index = adapter_touch_close_deck_card(hand_cards,{open_card_id},Joker_card_id,is_seq)
	if not index then return 2 end
	return 1
end

function rule.auto_touch_card(hand_cards,open_card_info,Joker_card_id,last_dis_card_id,is_seq)
	local ok,ret_type = pcall(auto_touch_card,hand_cards,open_card_info,Joker_card_id,last_dis_card_id,is_seq)
	if not ok then
		log.error("auto_touch_card err:",hand_cards,open_card_info,Joker_card_id,last_dis_card_id,is_seq)
		return 2
	end
	return ret_type
end

local function new_auto_dis_card(card_lt,Joker_card_id,is_seqss)
	local temp_card_list = table_clone(card_lt)
	local group_list = get_new_best_group_list(card_lt,Joker_card_id,is_seqss)
	local num_weight  = table_clone(CardScoreMap)
	local suit_weight = {[0] = 10,[1] = 10,[2] = 10,[3] = 10}

	local ret = false
	local dis_card = 0
	local invalid_group = group_list[#group_list]

	local is_pure_seq = false
	local is_seq = is_seqss or false
	for i,group in ipairs(group_list) do
		if group.type == GROUP_TYPE.pure_sequence then
			if is_pure_seq then
				is_seq = true
			end
			is_pure_seq = true
		elseif group.type == GROUP_TYPE.sequence then
			is_seq = true
		end
	end

	if invalid_group.type == GROUP_TYPE.invalid then
		local num_map_cnt = {
			[1] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[2] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[3] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[4] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[5] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[6] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[7] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[8] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[9] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[10] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[11] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[12] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[13] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} }
		}
		table.sort(invalid_group.card_list)
		for i,card in ipairs(invalid_group.card_list) do
			local card_info = get_card_info(card)
			local num = card_info.num 
			local suit = card_info.suit 
			if num <= 13 then
				num_map_cnt[num].cnt = num_map_cnt[num].cnt + 1
				num_map_cnt[num].suit[suit] = num_map_cnt[num].suit[suit] + 1
				--连续相邻的牌权重低
				if num_map_cnt[num].suit[suit] == 1 and num > 1 then  
					if num_map_cnt[num - 1].suit[suit] > 0 then
						num_weight[num - 1] = num_weight[num - 1] - weight_num_score[num - 1] * 2
						num_weight[num] = num_weight[num] - weight_num_score[num] * 2
					end
				end
				if num_map_cnt[num].suit[suit] == 1 and num > 2 then
					if num_map_cnt[num - 2].suit[suit] > 0 then
						num_weight[num] = num_weight[num] - weight_num_score[num]
						num_weight[num - 2] = num_weight[num - 2] - weight_num_score[num - 2]
					end
				end

				if num_map_cnt[num].suit[suit] == 2 then      --2张相同花色的牌 弃牌权重更高
					num_weight[num] = num_weight[num] + weight_num_score[num] * 2
					suit_weight[suit] = suit_weight[suit] + 5
				else
					if is_pure_seq and is_seq and num_map_cnt[num].cnt >= 2 then
						num_weight[num] = num_weight[num] - weight_num_score[num]
					end
				end
				
				suit_weight[suit] = suit_weight[suit] - 1
			end
		end

		local card_weight_list = {}
		local joker_card_info = get_card_info(Joker_card_id)
		for i,card in ipairs(invalid_group.card_list) do
			local one_weight_card = {}
			local card_info = get_card_info(card)
			if card_info.num > 13 or card_info.num == joker_card_info.num then
				one_weight_card.weight = -1000
			else
				one_weight_card.weight = num_weight[card_info.num] + suit_weight[card_info.suit]
			end
			one_weight_card.index = i
			table.insert(card_weight_list,one_weight_card)
		end

		if is_pure_seq and is_seq and #invalid_group.card_list == 1 then
			ret = true
			dis_card = invalid_group.card_list[1]
			table.remove(group_list,#group_list)
		end
		
		if dis_card == 0 and next(invalid_group.card_list) then
			table.sort(card_weight_list,function(a,b) return a.weight > b.weight end)
			local index = card_weight_list[1].index
			dis_card = invalid_group.card_list[index]
			del_group_dis_card(group_list,dis_card)
		end
	
	elseif invalid_group.type == GROUP_TYPE.joker then
		if is_pure_seq and is_seq then
			ret = true
			dis_card = invalid_group.card_list[1]
			table.remove(invalid_group.card_list,1)
			if #invalid_group.card_list == 0 then
				table.remove(group_list,#group_list)
			end
		end
	else
		if is_pure_seq and is_seq then
			ret = true
			for i,group in ipairs(group_list) do
				if #group.card_list > 3 then
					if group.type == GROUP_TYPE.sequence then
						table.sort(group.card_list,function(a,b)
							if is_joker_card(a,Joker_card_id) then
								return false
							end 
							
							 return get_card_num(a) < get_card_num(b)
							end)
					end
					dis_card = group.card_list[1]
					table.remove(group.card_list,1)
					break
				end
			end
		end
	end
	if dis_card == 0 then
		--local index = math.random(1,#card_lt)
		local index = #card_lt
		ret = false
		dis_card = card_lt[index]
		del_group_dis_card(group_list,dis_card)
	end

	return ret,dis_card,group_list
end

local function auto_dis_card(card_lt,Joker_card_id,is_seqss)
	local temp_card_list = table_clone(card_lt)
	local group_list = get_group_list(card_lt,Joker_card_id,is_seqss)
	local Joker_card = card_id_to_card_value(Joker_card_id)
	local num_weight  = table_clone(CardScoreMap)
	local suit_weight = {[0] = 10,[1] = 10,[2] = 10,[3] = 10}

	local ret = false
	local dis_card = 0
	local invalid_group = group_list[#group_list]

	local is_pure_seq = false
	local is_seq = is_seqss or false
	for i,group in ipairs(group_list) do
		if group.type == GROUP_TYPE.pure_sequence then
			if is_pure_seq then
				is_seq = true
			end
			is_pure_seq = true
		elseif group.type == GROUP_TYPE.sequence then
			is_seq = true
		end
	end

	if invalid_group.type == GROUP_TYPE.invalid then
		local num_map_cnt = {
			[1] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[2] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[3] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[4] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[5] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[6] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[7] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[8] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[9] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[10] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[11] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[12] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} },
			[13] = {cnt = 0,suit ={[0] = 0,[1] = 0,[2] = 0,[3] = 0} }
		}
		table.sort(invalid_group.card_list)
		for i,card in ipairs(invalid_group.card_list) do
			local num = allCards[card].num 
			local suit = allCards[card].suit 
			if num <= 13 then
				num_map_cnt[num].cnt = num_map_cnt[num].cnt + 1
				num_map_cnt[num].suit[suit] = num_map_cnt[num].suit[suit] + 1
				--连续相邻的牌权重低
				if num_map_cnt[num].suit[suit] == 1 and num > 1 then  
					if num_map_cnt[num - 1].suit[suit] > 0 then
						num_weight[num - 1] = num_weight[num - 1] - weight_num_score[num - 1] * 2
						num_weight[num] = num_weight[num] - weight_num_score[num] * 2
					end
				end
				if num_map_cnt[num].suit[suit] == 1 and num > 2 then
					if num_map_cnt[num - 2].suit[suit] > 0 then
						num_weight[num] = num_weight[num] - weight_num_score[num]
						num_weight[num - 2] = num_weight[num - 2] - weight_num_score[num - 2]
					end
				end

				if num_map_cnt[num].suit[suit] == 2 then      --2张相同花色的牌 弃牌权重更高
					num_weight[num] = num_weight[num] + weight_num_score[num] * 2
					suit_weight[suit] = suit_weight[suit] + 5
				else
					if is_pure_seq and is_seq and num_map_cnt[num].cnt >= 2 then
						num_weight[num] = num_weight[num] - weight_num_score[num]
					end
				end
				
				suit_weight[suit] = suit_weight[suit] - 1
			end
		end

		local card_weight_list = {}
		for i,card in ipairs(invalid_group.card_list) do
			local one_weight_card = {}
			if allCards[card].num > 13 or allCards[card].num == allCards[Joker_card].num then
				one_weight_card.weight = -1000
			else
				one_weight_card.weight = num_weight[allCards[card].num] + suit_weight[allCards[card].suit]
			end
			one_weight_card.index = i
			table.insert(card_weight_list,one_weight_card)
		end

		if not group_card_value_to_card_id(group_list,card_lt) then
			log.error("group_card_value_to_card_id err ")
			local index = math.random(1,#card_lt)
			del_group_dis_card(group_list,dis_card)
			return "err",card_lt[index],group_list
		end

		if is_pure_seq and is_seq and #invalid_group.card_list == 1 then
			ret = true
			dis_card = invalid_group.card_list[1]
			table.remove(group_list,#group_list)
		end
		
		if dis_card == 0 and next(invalid_group.card_list) then
			table.sort(card_weight_list,function(a,b) return a.weight > b.weight end)
			local index = card_weight_list[1].index
			dis_card = invalid_group.card_list[index]
			del_group_dis_card(group_list,dis_card)
		end
	
	elseif invalid_group.type == GROUP_TYPE.joker then
		if not group_card_value_to_card_id(group_list,card_lt) then
			log.error("group_card_value_to_card_id err ")
			local index = math.random(1,#card_lt)
			del_group_dis_card(group_list,dis_card)
			return "err",card_lt[index],group_list 
		end
		if is_pure_seq and is_seq then
			ret = true
			dis_card = invalid_group.card_list[1]
			table.remove(invalid_group.card_list,1)
			if #invalid_group.card_list == 0 then
				table.remove(group_list,#group_list)
			end
		end
	else
		if not group_card_value_to_card_id(group_list,card_lt) then
			log.error("group_card_value_to_card_id err ")
			local index = math.random(1,#card_lt)
			del_group_dis_card(group_list,dis_card)
			return "err",card_lt[index],group_list
		end
		if is_pure_seq and is_seq then
			ret = true
			for i,group in ipairs(group_list) do
				if #group.card_list > 3 then
					if group.type == GROUP_TYPE.sequence then
						table.sort(group.card_list,function(a,b)
							if is_joker_card(a,Joker_card_id) then
								return false
							end 
							
							 return get_card_num(a) < get_card_num(b)
							end)
					end
					dis_card = group.card_list[1]
					table.remove(group.card_list,1)
					break
				end
			end
		end
	end
	if dis_card == 0 then
		--local index = math.random(1,#card_lt)
		local index = #card_lt
		ret = false
		dis_card = card_lt[index]
		del_group_dis_card(group_list,dis_card)
	end

	return ret,dis_card,group_list
end

function rule.auto_dis_card(card_lt,Joker_card_id,is_seqss)
	local ok,ret,dis_card,group_list = pcall(auto_dis_card,card_lt,Joker_card_id,is_seqss)
	if not ok then
		log.error("auto_dis_card err:",card_lt,Joker_card_id,is_seqss)
		return false,card_lt[#card_lt],{}
	end
	return ret,dis_card,group_list
end

math.randomseed(os.time())
--local group_list = rule.get_group_list({406,407,408,409,108,109,110,111,807,808,212,213,201,},303)
--local group_list = rule.get_group_list({401,402,403,404,405,408,409,410,411,104,201,201,301},110)
-- local group_list = rule.get_group_list({106,309,310,311,312,206,406,201,105,205,305,310,411},106)
-- local group_list = rule.get_group_list({101,112,113,102,103},106)

-- local ret,dis_card,clubdd = rule.auto_dis_card({107,108,109,110,308,309,311,102,412,712,112,812,813,801,},402,false)
-- for i,v in ipairs(clubdd) do
-- 	print("group_type = " .. v.type)
-- 	rule.dumpDisplay(v.card_list)
-- end
-- local group_list = rule.get_group_list_id({108,109,110,308,309,311,102,412,712,112,812,813,801,},402,false)
-- for i,v in ipairs(group_list) do
-- 	print("group_type = " .. v.type)
-- 	rule.dumpDisplay(v.card_list)
-- end
-- -- --local cardsss = {510,511,512,513,406,407,408,501,502,503,504,505,405}
-- -- --local group_list = rule.get_group_list_id(cardsss,404)
-- -- rule.dumpDisplay({401,402,403,404,405,408,409,410,411,104,201,201,301})
-- local temp_card_list = {}
-- for i,v in ipairs(group_list) do
-- 	print("group_type = " .. v.type)
-- 	rule.dumpDisplay(v.card_list)
-- 	for _,card_id in ipairs(v.card_list) do
-- 		table.insert(temp_card_list,card_id)
-- 	end
-- end
-- assert(#cardsss == #temp_card_list)
-- table.sort(cardsss)
-- table.sort(temp_card_list)
-- rule.dumpDisplay(cardsss)
-- rule.dumpDisplay(temp_card_list)
-- for i,v in ipairs(cardsss) do
-- 	assert(cardsss[i] == temp_card_list[i])
-- end

local start_time = os.time()
print("start")
for i = 1,10000 do
	local text,joker_id,close_desk = rule.score_alloc_cards(13,1)
	--assert((13 * 8 + 2) - (13 * 6 + 1) == #close_desk)
	for _,cards in ipairs(text) do
		-- cards = {212,213,201,708,709,711,108,412,512,612,813,113,313,613,}
		-- joker_id = 808
		-- print("group_list --------------- joker_card = " .. joker_id)
		-- rule.dumpDisplay(cards)
		-- local ret,dis_card,group_list = auto_dis_card(cards,joker_id,false)
		-- for i,v in ipairs(group_list) do
		-- 	print("group_type = " .. v.type)
		-- 	rule.dumpDisplay(v.card_list)
		-- end
		-- if ret == true then
		-- 	for LOOP = #cards,1,-1 do
		-- 		if dis_card == cards[LOOP] then
		-- 			table.remove(cards,LOOP)
		-- 			break
		-- 		end
		-- 	end
		-- 	-- local score = get_hand_card_score(cards,joker_id,false)
		-- 	-- print(dis_card)
		-- 	-- assert(score == 0)
		-- end
		-- print('------------------------------------------')
		local group_list = get_group_list_id(cards,joker_id,false)
		--local group_list = get_new_best_group_list(cards,joker_id,false)
		local temp_card_list = {}
		for i,v in ipairs(group_list) do
			for _,card_id in ipairs(v.card_list) do
				table.insert(temp_card_list,card_id)
			end
			-- print("group_type = " .. v.type)
			-- rule.dumpDisplay(v.card_list)
		end
		assert(#temp_card_list == #cards)
		table.sort(cards)
		table.sort(temp_card_list)
		-- rule.dumpDisplay(cards)
		-- rule.dumpDisplay(temp_card_list)
		for i,v in ipairs(cards) do
			assert(cards[i] == temp_card_list[i])
		end
		-- for i,v in ipairs(group_list) do
		-- 	print("group_type = " .. v.type)
		-- 	rule.dumpDisplay(v.card_list,true)
		-- end
		-- rule.dumpDisplay(cards)
		-- print("group_list --------------- joker_card = " .. joker_id)
		-- print("----------------------------------------------")
	end
	-- for _,card_list in ipairs(text) do
	-- 	local new_hand_card = card_list--rule.adjust_hand_score(card_list,close_desk,joker_id,5,false,{})
	-- 	local ret,dis_card = rule.auto_dis_card(new_hand_card,joker_id,false)
	-- 	local group_list = rule.get_group_list(new_hand_card,joker_id,false)
	-- 	-- for i,v in ipairs(group_list) do
	-- 	-- 	print("group_type = " .. v.type)
	-- 	-- 	rule.dumpDisplay(v.card_list,true)
	-- 	-- end

	-- 	for i = #new_hand_card,1,-1 do
	-- 		if new_hand_card[i] == dis_card then
	-- 			table.remove(new_hand_card,i)
	-- 			break
	-- 		end
	-- 	end
		
	-- 	local score = rule.get_hand_card_score(new_hand_card,joker_id,false)
	-- 	if ret then
	-- 		print('joker = ' .. joker_id)
	-- 		assert(score == 0,rule.dumpDisplay(new_hand_card))
	-- 	end
	-- 	-- print("adjust_hand_score ",score)
	-- 	-- local group_list = rule.get_group_list(new_hand_card,joker_id,false)
	-- 	-- for i,v in ipairs(group_list) do
	-- 	-- 	print("group_type = " .. v.type)
	-- 	-- 	rule.dumpDisplay(v.card_list,true)
	-- 	-- end
	-- 	-- rule.dumpDisplay(new_hand_card)
	-- 	-- print("group_list --------------- joker_card = " .. joker_id)
	-- 	-- print("----------------------------------------------")
	-- end
	--assert((13 * 8 + 2) - (13 * 6 + 1) == #close_desk)
	-- rule.adapter_bad_touch_close_deck_card(text[1],close_desk,joker_id,false)
end
print("over",os.time() - start_time)

-- group_list --------------- joker_card = 308
-- group_type = 1
-- ♣9|♣10|♣J|♣Q|♣K|____25,26,27,28,29,
-- group_type = 2
-- ♢3|♢4|♡8|____3,4,40,
-- group_type = 2
-- ♢Q|♢10|♢8|____12,10,8,
-- group_type = 4
-- ♡2|♡3|♣3|____34,35,19,
-- ♢3|♢10|♣3|♡8|♢8|♣J|♣K|♢Q|♣Q|♢4|♡3|♣10|♣9|♡2|____503,110,603,708,108,211,613,112,612,104,303,610,209,702,
-- group_list --------------- joker_card = 308



-- local group_list = {
-- 	{type = 2,card_list = {108,110,502}},
-- } 

-- --local test,joker,rmcard = rule.random_allot_cards(14,1)

-- local ret = rule.adapter_touch_close_deck_card(group_list,{109},502)
-- print(ret)
-- local ret,discard,group_list = rule.auto_dis_card({102,108,108,},308,true)
-- print(discard)
-- for i,one_group in ipairs(group_list) do
-- 	local card_list = one_group.card_list
-- 	rule.dumpDisplay(card_list)
-- end

-- for i,one_group in ipairs(group_list) do
-- 	local card_list = one_group.card_list
-- 	rule.dumpDisplay(card_list)
-- end

-- local now_time = os.time()
-- print("user_time = " .. now_time - pro_time)

--  local ret = resolve_card_pure_sequence({43,9,33,19,44,37,79,49,29,38,39,38,40,18,36,42,24,2,52,36},604)
--  for i,v in ipairs(ret) do
--  	rule.dumpDisplay(v,true)
--  end

--  local ret = resolve_card_pure_sequence({57,56,56,55,55,53,51,},604)
--  for i,v in ipairs(ret) do
--  	rule.dumpDisplay(v,true)
--  end

-- rule.get_group_list({102,103,104,104,105,106,106,107,107,108,108,109,109,110,110,111,112},106)
-- rule.get_group_list({102,103,104,104,105,106},106)

--  rule.get_group_list({110,109,109,108,107,106},106)
--  rule.get_group_list({102,102,103,103,104,104},106)

--  local ret = resolve_card_pure_sequence({61,60,59,58,57,55,54,53,52,49},604)
--  for i,v in ipairs(ret) do
--  	rule.dumpDisplay(v,true)
--  end
--61,60,59,58,57,55,54,53,52,49   A没有放进去-
return rule