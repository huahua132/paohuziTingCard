local skynet = require "skynet"
local log = require "logger"
local tonumber,tostring = tonumber,tostring
local string,math,table =string,math,table
local pairs,ipairs,assert,pcall,next = pairs,ipairs,assert,pcall,next
local rand_table = rand_table
local table_clone = table.copy

local rule = {}

local Suit_type = {  
	Spade = 3, 			--黑桃
	Heart = 2, 			--红桃
	Club = 1, 			--梅花
	Diamond = 0, 		--方块
	Joker = 4,  		--大小王
}

local Card_type = 
{
    high_card = 1,       --高牌
    pair = 2,            --对子
    color = 3,           --同花
    sequence = 4,        --顺子
    pure_sequence = 5,   --同花顺
    trail_set = 6        --豹子
}

local Card_data = {
	--方块，梅花，红桃，黑桃
	--0x4F,--大王
	--0x4E,--小王
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
local Card_grade_map = {
	[0x0F] = 16, --大王
	[0x0E] = 15, --小王
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

local Card_point_map = {
	[0x0F] = 0, --大王
	[0x0E] = 0, --小王
	[0x0D] = 0,  --K
	[0x0C] = 0,  --Q
	[0x0B] = 0,  --J
	[0x0A] = 0, --10
	[0x09] = 9, --9
	[0x08] = 8, --8
	[0x07] = 7, --7
	[0x06] = 6, --6
	[0x05] = 5, --5
	[0x04] = 4, --4
	[0x03] = 3, --3
	[0x02] = 2, --2
	[0x01] = 1, --A
}

local Card_display = {
	"A","2","3","4","5","6","7","8","9","10","J","Q","K","Kinglet","King",
}

local Card_grade_list = {1,13,12,11,10,9,8,7,6,5,4,3,2}

local Card_suit = 
{
	[0] = "♢",
	[1] = "♣",
	[2] = "♡",
	[3] = "♤"
}

local function get_suit(id)  --花色
	local bigType = id >> 4
	if bigType > 0x04 then
		return nil
	end
	return bigType
end

local function get_num(id) --编号1到15
	local num = id & 0x0F
	return num
end

local function get_display(id)  --牌号
	local num = get_num(id)
	local suit = get_suit(id)
	if num > 13 then return Card_display[num] end      --大小王没花色
	local display = Card_suit[suit] .. Card_display[num]
	return display
end

local function get_grade(id)  --权级
	local num = get_num(id)
  	return Card_grade_map[num]
end 

local function get_point(id)  --点数
	local num = get_num(id)
	return Card_point_map[num]
end

local All_cards = {}
for _,id in ipairs(Card_data) do
	All_cards[id] = {
		id = id,
		num = get_num(id),
		suit=get_suit(id),
		display=get_display(id),
		grade = get_grade(id),
		point = get_point(id)
	}
end

local QKA = {              --判断牌型用，A可以组合 123 和 QKA
	0x0E,0x1E,0x2E,0x3E
}

for _,id in ipairs(QKA) do
	All_cards[id] = {
        id = id,
		num = get_num(id),
		suit=get_suit(id),
		display=get_display(id),
		grade = get_grade(id)
	}
end

local function isvalid(id,islog)
	if not All_cards[id] then
		if islog then
			log.error("not valid card_id =" .. id)
		end
		return false
	end
	return true
end

function rule.shufflethecards(cards)
	for i = 1,#cards do
		local index = math.random(1,#cards)
		cards[i],cards[index] = cards[index],cards[i]
	end
end

function rule.random_allot_cards(card_num,player_num,joker_num)
	local temp_card_id_list = table_clone(Card_data)
	rule.shufflethecards(temp_card_id_list)

	local seat_cards_list = {}
	local joker_card_list = rule.draw_out_joker_list(temp_card_id_list,joker_num)

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
	
	for _,cards in ipairs(seat_cards_list) do
		table.sort(cards,function(a,b) return All_cards[a].grade > All_cards[b].grade end)
	end

	return seat_cards_list,joker_card_list,temp_card_id_list
end

function rule.draw_out_joker_list(card_list,joker_num)
	--分离出牌值不会重复的赖子
	local joker_card_list = {}
	local remove_index_list = {}
	local card_num_map = {}
	local rand_num = {}
	for index,card in ipairs(card_list) do
		if not card_num_map[All_cards[card].num] then
			card_num_map[All_cards[card].num] = {}
			rand_num[All_cards[card].num] = 1000
		end
		table.insert(card_num_map[All_cards[card].num],index)
	end

	for i = 1,joker_num do
		local num = rand_table(rand_num)
		local card_index = card_num_map[num][1]
		table.insert(joker_card_list,card_list[card_index])
		table.insert(remove_index_list,card_index)
		rand_num[num] = nil
	end

	table.sort(remove_index_list)
	for i = #remove_index_list, 1, -1 do
		table.remove(card_list,remove_index_list[i])
	end

	return joker_card_list
end

function rule.allot_card_one(player_num)
	local card_list = table_clone(Card_data)
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
	if All_cards[card1].grade > All_cards[card2].grade then
		return true
	elseif All_cards[card1].grade == All_cards[card2].grade then
		return All_cards[card1].suit > All_cards[card2].suit 
	end

	return false
end

function rule.dumpDisplay(cards)
	local card_value_list = cards
	local str = ""
	for i,v in ipairs(card_value_list) do
		str = str .. All_cards[v].display
	end
	return str
end

local function is_trail_set(card_id_list,joker_cnt)
    if joker_cnt == 3 then
        return true,{0x31,0x21,0x11}     --三张A
    end
    local suit_map = {} 
    local num = 0
    for _,card in ipairs(card_id_list) do
        num = All_cards[card].num
        suit_map[All_cards[card].suit] = true
    end
    local change_list = {}
    if joker_cnt >= 2 then
        for i = Suit_type.Spade, Suit_type.Diamond, -1 do
            if not suit_map[i] and joker_cnt >= 1 then
                table.insert(change_list,(i << 4) + num)
                joker_cnt = joker_cnt - 1
            end
        end
        return true,change_list
    end
    local one_card_num = All_cards[card_id_list[1]].num
    for i = 2,#card_id_list do
        if All_cards[card_id_list[i]].num ~= one_card_num then
            return false
        end
    end

    for i = Suit_type.Spade, Suit_type.Diamond, -1 do
        if not suit_map[i] and joker_cnt >= 1 then
            table.insert(change_list,(i << 4) + num)
            joker_cnt = joker_cnt - 1
        end
    end
    return true,change_list
end

local function is_pure_sequence(card_id_list,joker_cnt)
    local change_list = {}
    local card_list = table_clone(card_id_list)
    table.sort(card_list)

	if All_cards[card_list[1]].num == 1 and #card_list >= 2 and All_cards[card_list[2]].num > 3 then
		local new_card = card_list[1] + 13    --去组合 QKA
		table.remove(card_list,1)
		table.insert(card_list,new_card)
    end
    
    local cur_num = card_list[1]
	local cur_pos = 2
	while cur_pos <= #card_list do
		if All_cards[cur_num].suit ~= All_cards[card_list[cur_pos]].suit then
			return false
		end
		if All_cards[card_list[cur_pos]].num - All_cards[cur_num].num == 1 then
			cur_num = card_list[cur_pos]
		else
			if joker_cnt > 0 then
				cur_num = cur_num + 1
				joker_cnt = joker_cnt - 1
                cur_pos = cur_pos - 1
                table.insert(change_list,cur_num)
			else
				return false
			end
		end
		cur_pos = cur_pos + 1
    end
    if joker_cnt == 1 then
        if All_cards[card_list[1]].num == 13 then
            table.insert(change_list,(All_cards[card_list[1]].suit << 4) + 12)
        elseif All_cards[card_list[1]].num == 12 then
            table.insert(change_list,(All_cards[card_list[1]].suit << 4) + 1)
        else
            table.insert(change_list,(All_cards[card_list[1]].suit << 4) + All_cards[card_list[2]].num + 1)
        end
    end
    return true,change_list
end

local function is_sequence(card_id_list,joker_cnt)
    local change_list = {}
    local card_list = table_clone(card_id_list)
    table.sort(card_list,function(a,b) return All_cards[a].num < All_cards[b].num end)

	if All_cards[card_list[1]].num == 1 and #card_list >= 2 and All_cards[card_list[2]].num > 3 then
		local new_card = card_list[1] + 13    --去组合 QKA
		table.remove(card_list,1)
		table.insert(card_list,new_card)
    end
    
    local cur_num = card_list[1]
	local cur_pos = 2
	while cur_pos <= #card_list do
		if All_cards[card_list[cur_pos]].num - All_cards[cur_num].num == 1 then
			cur_num = card_list[cur_pos]
		else
			if joker_cnt > 0 then  --中间
				cur_num = cur_num + 1
				joker_cnt = joker_cnt - 1
                cur_pos = cur_pos - 1
                table.insert(change_list,(Suit_type.Spade << 4) + All_cards[cur_num].num)
			else
				return false
			end
		end
		cur_pos = cur_pos + 1
    end
    
    if joker_cnt == 1 then
        if All_cards[card_list[1]].num == 13 then
            table.insert(change_list,(Suit_type.Spade << 4) + 12)
        elseif All_cards[card_list[1]].num == 12 then
            table.insert(change_list,(Suit_type.Spade << 4) + 1)
        else
            table.insert(change_list,(Suit_type.Spade << 4) + All_cards[card_list[2]].num + 1)
        end
    end
    return true,change_list
end

local function is_color(card_id_list,joker_cnt)
    local change_list = {}
    local card_list = card_id_list
    local cur_num = card_list[1]
    local cur_pos = 2
    local card_num_filter_map = {}
    for _,card in ipairs(card_id_list) do
        card_num_filter_map[All_cards[card].num] = true
    end

	while cur_pos <= #card_list do
        if All_cards[cur_num].suit ~= All_cards[card_list[cur_pos]].suit then
                return false
		end
		cur_pos = cur_pos + 1
	end

	if joker_cnt == 1 then
		for _,num in ipairs(Card_grade_list) do
			if not card_num_filter_map[num] then
				table.insert(change_list,(All_cards[cur_num].suit << 4) + num)
				break
			end
		end
	end
    return true,change_list
end

local function is_pair(card_id_list,joker_cnt)
    local change_list = {}
    if joker_cnt == 1 then
        local change_num = 0
        if All_cards[card_id_list[1]].grade > All_cards[card_id_list[2]].grade then
            change_num = card_id_list[1]
        else
            change_num = card_id_list[2]
        end
        if All_cards[change_num].suit ~= Suit_type.Spade then
            table.insert(change_list,(Suit_type.Spade << 4) + All_cards[change_num].num)
        else
            table.insert(change_list,(Suit_type.Heart << 4) + All_cards[change_num].num)
        end

        return true,change_list
    end
    for i = 1,#card_id_list - 1 do
        for j = i + 1,#card_id_list do
            if All_cards[card_id_list[i]].num == All_cards[card_id_list[j]].num then
                return true,{}
            end
        end
    end

    return false
end

function rule.get_card_type(card_id_list,joker_list)
    if #card_id_list ~= 3 then
        print("card count err")
        return 0
    end

    local joker_card_map = {}
    for _,card in ipairs(joker_list) do
        joker_card_map[All_cards[card].num] = true
    end

    local joker_cnt = 0
    local temp_card_list = {}

    for _,card in ipairs(card_id_list) do
        if joker_card_map[All_cards[card].num] or All_cards[card].num > 13 then
            joker_cnt = joker_cnt + 1
        else
            table.insert(temp_card_list,card)
        end
    end
    local ret,change_list
    ret,change_list = is_trail_set(temp_card_list,joker_cnt)
    if ret then
        return Card_type.trail_set,change_list,temp_card_list
    end
    ret,change_list = is_pure_sequence(temp_card_list,joker_cnt) 
    if ret then
        return Card_type.pure_sequence,change_list,temp_card_list
    end
    ret,change_list = is_sequence(temp_card_list,joker_cnt) 
    if ret then
        return Card_type.sequence,change_list,temp_card_list
    end
    
    ret,change_list = is_color(temp_card_list,joker_cnt) 
    if ret then
        return Card_type.color,change_list,temp_card_list
    end

    ret,change_list = is_pair(temp_card_list,joker_cnt) 
    if ret then
        return Card_type.pair,change_list,temp_card_list
	end

    return Card_type.high_card,{},temp_card_list
end

local SOME_CARD_TYPE_COMPARE_FUC = {}

-- _a                   没有用到
-- one_temp_card_list   分离出赖子剩余的手牌
-- one_change_list		赖子变出来的牌
-- _b				
-- two_temp_card_list 
-- two_change_list
local function compare_pure_sequence(_a,one_temp_card_list,one_change_list,_b,two_temp_card_list,two_change_list)
	--先比逐个比牌值，再逐个比花色
	local one_card_list = table_clone(one_temp_card_list)
	for _,card in ipairs(one_change_list) do
		table.insert(one_card_list,card)
	end
	local two_card_list = table_clone(two_temp_card_list)
	for _,card in ipairs(two_change_list) do
		table.insert(two_card_list,card)
	end

	table.sort(one_card_list,function(a,b) return All_cards[a].grade > All_cards[b].grade end)
	table.sort(two_card_list,function(a,b) return All_cards[a].grade > All_cards[b].grade end)

	for i,card in ipairs(one_card_list) do
		if All_cards[card].grade > All_cards[two_card_list[i]].grade then
			return true
		elseif All_cards[card].grade < All_cards[two_card_list[i]].grade then
			return false
		end
	end

	for i,card in ipairs(one_card_list) do
		if All_cards[card].suit > All_cards[two_card_list[i]].suit then
			return true
		elseif All_cards[card].suit < All_cards[two_card_list[i]].suit then
			return false
		end
	end

	--全部相同比不是赖子的牌谁大
	local one_max_card = 0
	local two_max_card = 0 
	for _,card in ipairs(one_temp_card_list) do
		if All_cards[card].grade > one_max_card then
			one_max_card = card
		end
	end
	
	for _,card in ipairs(two_temp_card_list) do
		if All_cards[card].grade > two_max_card then
			two_max_card = card
		end
	end
	
	return compare_grade_t(one_max_card,two_max_card)
end
SOME_CARD_TYPE_COMPARE_FUC[Card_type.pure_sequence] = compare_pure_sequence

local function compare_trail_set(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
	--比比谁的豹子大
	local one_max_grade = 0
	local two_max_grade = 0
	for _,card in ipairs(one_change_list) do
		if All_cards[card].grade > one_max_grade then
			one_max_grade = All_cards[card].grade
			break
		end
	end

	for _,card in ipairs(two_change_list) do
		if All_cards[card].grade > two_max_grade then
			two_max_grade = All_cards[card].grade
			break
		end
	end

	--比比谁不是赖牌的花色大
	local one_max_suit = 0
	local two_max_suit = 0
	for _,card in ipairs(one_temp_card_list) do
		if All_cards[card].suit > one_max_suit then
			one_max_suit = All_cards[card].suit
		end
		if All_cards[card].grade > one_max_grade then
			one_max_grade = All_cards[card].grade
		end
	end

	for _,card in ipairs(two_temp_card_list) do
		if All_cards[card].suit > two_max_suit then
			two_max_suit = All_cards[card].suit
		end
		if All_cards[card].grade > two_max_grade then
			two_max_grade = All_cards[card].grade
		end
	end

	if one_max_grade > two_max_grade then
		return true
	elseif one_max_grade < two_max_grade then
		return false
	end

	if one_max_suit > two_max_suit then
		return true
	elseif one_max_suit == two_max_suit then
		return compare_pure_sequence({},one_card_list,{},{},two_card_list,{})    --2个人全是赖就比所以赖子的牌值吧
	end

	return false
end
SOME_CARD_TYPE_COMPARE_FUC[Card_type.trail_set] = compare_trail_set

local function compare_sequence(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
	return compare_pure_sequence(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
end
SOME_CARD_TYPE_COMPARE_FUC[Card_type.sequence] = compare_sequence

local function compare_color(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
	return compare_pure_sequence(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
end
SOME_CARD_TYPE_COMPARE_FUC[Card_type.color] = compare_color

local function compare_pair(_a,one_temp_card_list,one_change_list,_b,two_temp_card_list,two_change_list)
	local one_card_list = table_clone(one_temp_card_list)
	for _,card in ipairs(one_change_list) do
		table.insert(one_card_list,card)
	end
	local two_card_list = table_clone(two_temp_card_list)
	for _,card in ipairs(two_change_list) do
		table.insert(two_card_list,card)
	end

	table.sort(one_card_list,function(a,b) return All_cards[a].grade > All_cards[b].grade end)
	table.sort(two_card_list,function(a,b) return All_cards[a].grade > All_cards[b].grade end)

	local one_pair_grade = 0
	local one_dan_card = 0
	local two_pair_grade = 0
	local two_dan_card = 0
	if All_cards[one_card_list[1]].grade == All_cards[one_card_list[2]].grade then
		one_pair_grade = All_cards[one_card_list[1]].grade
		one_dan_card = one_card_list[3]
	else
		one_pair_grade = All_cards[one_card_list[2]].grade
		one_dan_card = one_card_list[1]
	end

	if All_cards[two_card_list[1]].grade == All_cards[two_card_list[2]].grade then
		two_pair_grade = All_cards[two_card_list[1]].grade
		two_dan_card = two_card_list[3]
	else
		two_pair_grade = All_cards[two_card_list[2]].grade
		two_dan_card = two_card_list[1]
	end
	--先比对子  再比单牌
	if one_pair_grade > two_pair_grade then
		return true
	elseif one_pair_grade == two_pair_grade then
		return compare_grade_t(one_dan_card,two_dan_card)
	end
	return false
end
SOME_CARD_TYPE_COMPARE_FUC[Card_type.pair] = compare_pair

local function compare_high_card(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
	return compare_pure_sequence(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
end
SOME_CARD_TYPE_COMPARE_FUC[Card_type.high_card] = compare_high_card

local function is_one_same_type_greater(card_type,one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
	local func = SOME_CARD_TYPE_COMPARE_FUC[card_type]
	if not func then
		print("not find SOME_CARD_TYPE_COMPARE_FUC tpye = " .. card_type)
		return false
	end
	return func(one_card_list,one_temp_card_list,one_change_list,two_card_list,two_temp_card_list,two_change_list)
end

function rule.is_one_greater_two_cards(one_card_list,two_card_list,joker_card_list)
	local one_card_type,one_change_list,one_temp_card_list = rule.get_card_type(one_card_list,joker_card_list)
	local two_card_type,two_change_list,two_temp_card_list = rule.get_card_type(two_card_list,joker_card_list)
	if one_card_type > two_card_type then
		return true
	elseif one_card_type == two_card_type then
		local temp_one_card_list = table_clone(one_card_list)
		local temp_two_card_list = table_clone(two_card_list)
		return is_one_same_type_greater(one_card_type,temp_one_card_list,one_temp_card_list,one_change_list,temp_two_card_list,two_temp_card_list,two_change_list)
	end

	return false
end

function rule.is_one_greater_two_cards_by_lowest(one_card_list,one_joker_card_list,two_card_list,two_joker_card_list)
	local one_card_type,one_change_list,one_temp_card_list = rule.get_card_type(one_card_list,one_joker_card_list)
	local two_card_type,two_change_list,two_temp_card_list = rule.get_card_type(two_card_list,two_joker_card_list)
	if one_card_type > two_card_type then
		return true
	elseif one_card_type == two_card_type then
		local temp_one_card_list = table_clone(one_card_list)
		local temp_two_card_list = table_clone(two_card_list)
		return is_one_same_type_greater(one_card_type,temp_one_card_list,one_temp_card_list,one_change_list,temp_two_card_list,two_temp_card_list,two_change_list)
	end

	return false
end

function rule.draw_out_max_card_list(seat_cards_list,joker_card_list)
	local temp_seat_cards_list = {}
	for i,card_list in ipairs(seat_cards_list) do
		table.insert(temp_seat_cards_list,{card_list = table_clone(card_list),index = i})
	end

	table.sort(temp_seat_cards_list,function(a,b) return rule.is_one_greater_two_cards(a.card_list,b.card_list,joker_card_list) end)
	local ret_card_list = table.remove(seat_cards_list,temp_seat_cards_list[1].index)
	return ret_card_list
end

function rule.draw_out_min_card_list(seat_cards_list,joker_card_list)
	local temp_seat_cards_list = {}
	for i,card_list in ipairs(seat_cards_list) do
		table.insert(temp_seat_cards_list,{card_list = table_clone(card_list),index = i})
	end

	table.sort(temp_seat_cards_list,function(a,b) return rule.is_one_greater_two_cards(a.card_list,b.card_list,joker_card_list) end)
	local ret_card_list = table.remove(seat_cards_list,temp_seat_cards_list[#temp_seat_cards_list].index)
	return ret_card_list
end

function rule.get_min_card_list(card_list)
	local temp_card_list = table_clone(card_list)
	local ret_card_list = {}
	table.sort(temp_card_list,function (a,b) return compare_grade_t(a,b) end)
	if All_cards[temp_card_list[1]].num == All_cards[temp_card_list[3]].num then
		table.insert(ret_card_list,temp_card_list[1])
	end
	if All_cards[temp_card_list[2]].num == All_cards[temp_card_list[3]].num then
		table.insert(ret_card_list,temp_card_list[2])
	end
	table.insert(ret_card_list,temp_card_list[3])
	return ret_card_list
end

function rule.get_card_list_point(card_list)
-- 	在这种变化中，玩家必须使手牌最接近999。在这种变化中，最佳手牌是任何组合的9-9-9
--  规则：所有面卡K，Q，J和10的值= 0，值9（♠♥♦）= 9，8（♠♥♦）= 8，7（♠♥♦）= 7…。等等。A的值（♠♥♦）= 1
	local temp_card_list = table_clone(card_list)
	table.sort(temp_card_list,function (a,b) return All_cards[a].point > All_cards[b].point end)
	local ret_point = ''
	for i,card in ipairs(temp_card_list) do
		ret_point = ret_point .. All_cards[card].point
	end

	return ret_point
end

function rule.is_one_greater_two_cards_by_999(one_card_list,two_card_list)
	local one_card_point = rule.get_card_list_point(one_card_list)
	local two_card_point = rule.get_card_list_point(two_card_list)
	one_card_point = tonumber(one_card_point)
	two_card_point = tonumber(two_card_point)
	if one_card_point > two_card_point then
		return true
	elseif one_card_point == two_card_point then
		return compare_pure_sequence({},one_card_list,{},{},two_card_list,{})  --点数相同就逐个比牌值吧
	end
	return false
end

function rule.draw_out_max_card_list_by_999(seat_cards_list)
	local temp_seat_cards_list = {}
	for i,card_list in ipairs(seat_cards_list) do
		table.insert(temp_seat_cards_list,{card_list = table_clone(card_list),index = i})
	end

	table.sort(temp_seat_cards_list,function(a,b) return rule.is_one_greater_two_cards_by_999(a.card_list,b.card_list) end)
	local ret_card_list = table.remove(seat_cards_list,temp_seat_cards_list[1].index)
	return ret_card_list
end

function rule.draw_out_max_card_list_by_low(seat_cards_list)
	local temp_seat_cards_list = {}
	for i,card_list in ipairs(seat_cards_list) do
		table.insert(temp_seat_cards_list,{card_list = table_clone(card_list),index = i})
	end
	table.sort(temp_seat_cards_list,function(a,b)
		local a_joker_list = rule.get_min_card_list(a.card_list)
		local b_joker_list = rule.get_min_card_list(b.card_list)
		 return rule.is_one_greater_two_cards_by_lowest(a.card_list,a_joker_list,b.card_list,b_joker_list)
		 end)
	local ret_card_list = table.remove(seat_cards_list,temp_seat_cards_list[1].index)
	return ret_card_list
end

return rule