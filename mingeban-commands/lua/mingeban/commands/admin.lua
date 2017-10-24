
if CLIENT then return end


mingeban.CreateCommand("rcon", function(caller, line)
	game.ConsoleCommand(line .. "\n")
end)

local cexec = mingeban.CreateCommand("cexec", function(caller, line, plys, cmd)
	if #plys < 2 then
		plys[1]:ConCommand(cmd)
	else
		for _, ply in next, plys do
			ply:ConCommand(cmd)
		end
	end
end)
cexec:AddArgument(ARGTYPE_PLAYERS)
cexec:AddArgument(ARGTYPE_STRING)
	:SetName("command")

mingeban.CreateCommand("maps", function(caller)
	for _, map in next, (file.Find("maps/*.bsp", "GAME")) do
		caller:PrintMessage(HUD_PRINTCONSOLE, map)
	end
end)

-- kick

local kick = mingeban.CreateCommand("kick", function(caller, line, ply, reason)
	local reason = reason or "byebye!!"
	mingeban.utils.print(mingeban.colors.Red,
		tostring(ply) .. "(" .. ply:SteamID() .. ")" ..
		" has been kicked " ..
		" by " .. tostring(caller) ..
		" for reason: '" .. reason ..
		"'."
	)
	ply:Kick(reason)
end)
kick:AddArgument(ARGTYPE_PLAYER)
kick:AddArgument(ARGTYPE_STRING)
	:SetName("reason")
	:SetOptional(true)

-- ban / unban

local ban = mingeban.CreateCommand("ban", function(caller, line, ply, time, reason)
	local foundPlayer = false
	if not ply:upper():Trim():match("^STEAM_0:%d:%d+$") then
		local results = mingeban.utils.findPlayer(ply)
		if results[1] then
			ply = results[1]
			foundPlayer = true
		end
	end
	if not foundPlayer then
		ply = ply:upper():Trim()
	end

	local timeNum = 0
	local timeInput = false
	for months in time:gmatch("(%d+)M") do
		timeNum = timeNum + (86400 * 30) * months
		timeInput = true
	end
	for days in time:gmatch("(%d+)d") do
		timeNum = timeNum + 86400 * days
		timeInput = true
	end
	for hours in time:gmatch("(%d+)h") do
		timeNum = timeNum + 3600 * hours
		timeInput = true
	end
	for minutes in time:gmatch("(%d+)m") do
		timeNum = timeNum + 60 * minutes
		timeInput = true
	end
	for seconds in time:gmatch("(%d+)s") do
		timeNum = timeNum + seconds
		timeInput = true
	end
	if not timeInput then
		return false, "Incorrect time"
	end

	local reason = reason or "byebye!!"
	mingeban.utils.print(mingeban.colors.Red,
		tostring(ply) .. (foundPlayer and "(" .. ply:SteamID() .. ")" or "") ..
		" has been banned " ..
		(timeNum == 0 and "permanently" or "for " .. string.NiceTime(timeNum)) ..
		" by " .. tostring(caller) ..
		" for reason: '" .. reason ..
		"'."
	)
	mingeban.Ban(ply, timeNum, reason)
	if foundPlayer then
		ply:Kick(reason)
	end
end)
ban:AddArgument(ARGTYPE_STRING)
	:SetName("player/steamid")
ban:AddArgument(ARGTYPE_STRING)
	:SetName("time")
ban:AddArgument(ARGTYPE_STRING)
	:SetName("reason")
	:SetOptional(true)

local unban = mingeban.CreateCommand("unban", function(caller, line, ply)
	ply = ply:upper():Trim()
	if not ply:match("^STEAM_0:%d:%d+$") then return false, "Invalid SteamID" end
	mingeban.utils.print(mingeban.colors.Cyan, tostring(caller) .. " unbanned " .. tostring(ply) .. ".")
	mingeban.Unban(ply)
end)
unban:AddArgument(ARGTYPE_STRING)
	:SetName("steamid")

-- rank

local rank = mingeban.CreateCommand("rank", function(caller, line, ply, rank)
	local ok, err = pcall(function()
		ply:SetUserGroup(rank)
	end)
	if ok then
		mingeban.utils.print(mingeban.colors.Cyan, tostring(caller) .. " ranked " .. tostring(ply) .. " to '" .. rank .. "'.")
	else
		ErrorNoHalt(err)
	end
	return ok, err
end)
rank:AddArgument(ARGTYPE_PLAYER)
rank:AddArgument(ARGTYPE_STRING)
	:SetName("rank")

-- map / restart

local restart = mingeban.CreateCommand("restart", function(caller, line, time)
	local txt = "Restart"
	mingeban.Countdown(time, function()
		timer.Simple(1, function()
			game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
		end)
	end, txt)
	mingeban.utils.print(mingeban.colors.Cyan, tostring(caller) .. " started countdown \"" .. txt .. "\"")
end)
restart:AddArgument(ARGTYPE_NUMBER)
	:SetName("time")

local map = mingeban.CreateCommand("map", function(caller, line, map, time)
	map = map:gsub(".bsp", "")
	if not file.Exists("maps/" .. map .. ".bsp", "GAME") then return false, "Map doesn't exist" end

	local txt = "Changing map to \"" .. map .. "\""
	mingeban.Countdown(time or 20, function()
		timer.Simple(1, function()
			game.ConsoleCommand("changelevel " .. map .. "\n")
		end)
	end, txt)
	mingeban.utils.print(mingeban.colors.Cyan, tostring(caller) .. " started countdown \"" .. txt .. "\"")
end)
map:AddArgument(ARGTYPE_STRING)
	:SetName("map")
map:AddArgument(ARGTYPE_NUMBER)
	:SetName("time")
	:SetOptional(true)

--[[ server stays dead with _restart rip

mingeban.CreateCommand("reboot",function(caller)
	if not caller:IsAdmin() then return end
	game.ConsoleCommand("_restart\n")
end)

]]
