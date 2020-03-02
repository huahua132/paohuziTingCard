

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

Debug = function(...)
    local msg = ""
	msg = "LUA: "
	for __index , __value in ipairs{...} do   --> {...} 表示一个由所有变长参数构成的数组
		if __index > 1 then
			msg = msg .. " " 
		end
		
		if __value then
			if type(__value) == "table" then
				msg = msg .. "\n" .. TableToString(__value)
			else
				msg = msg .. tostring(__value)
			end
		elseif __value == false then
			msg = msg .. "false"
		else
			msg = msg .. "nil"
		end
	end
	if  msg == "LUA: " then
		msg = "LUA: nil "
	end 
	print(msg)
end

function TableToString ( t )  
    local print_r_cache={}
    local str = ""
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            str = indent.."*"..tostring(t) .. "\n"
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        str = str .. (indent.."["..pos.."] => "..tostring(t).." {") .. "\n"
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        str = str .. (indent..string.rep(" ",string.len(pos)+6).."}") .. "\n"
                    elseif (type(val)=="string") then
                        str = str .. (indent.."["..pos..'] => "'..val..'"') .. "\n"
                    else
                        str = str .. (indent.."["..pos.."] => "..tostring(val)) .. "\n"
                    end
                end
            else
                str = str .. (indent..tostring(t)) .. "\n"
            end
        end
    end
    if (type(t)=="table") then
        str = str .. (tostring(t).." {") .. "\n"
        sub_print_r(t,"  ")
        str = str .. ("}\n")
    else
        sub_print_r(t,"  ")
    end
    return str 
end
