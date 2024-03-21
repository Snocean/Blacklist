function BlackList:AddPlayer(player, realm, reason, level, class, race)
	local name, added
	
	if(string.find(player, "(.*)-(.*)") ~= nil) then
		 _, _, player, realm = string.find(player, "(.*)-(.*)")
	end

	if (player == nil or player == "") then
		return
	end
	
	if(realm == nil and (player == UnitName("player") or UnitName("target") == UnitName("player"))) then
				return
	end

	if (player == "target" or player == UnitName("target")) then
		if UnitIsPlayer("target") then
			name, realm = UnitName("target")
			level = tostring(UnitLevel("target"))
			_, class = UnitClass("target")
			_, race = UnitRace("target")
			
		else
			StaticPopup_Show("BL_PLAYER")
			return
		end
	else
		name = player
	end
	
	-- check double
	if (BlackList:GetIndexByName(name, realm) > 0) then
		BlackList:AddMessage(name .. " " .. "is already in Black List.", "yellow")
	else

		-- handle realm
		if (realm == nil) then
			realm = BlackList.realm
		end
		
		-- handle level
		if (level == nil) then
			level = ""
		end
		
		-- handle class
		if (class == nil) then
			class = ""
		end
		
		-- handle race
		if (race == nil) then
			race = ""
		end	
		
		-- handle race Scourge
		if (race == "Scourge") then
			race = "UNDEAD"
		end
	
		-- handle reason
		if (reason == nil) then
			reason = ""
		end
	
		-- timestamp
		added = time()
	
		-- lower the name and upper the first letter, not for chinese and korean though
		if ((GetLocale() ~= "zhTW") and (GetLocale() ~= "zhCN") and (GetLocale() ~= "koKR")) then
			local _, len = string.find(name, "[%z\1-\127\194-\244][\128-\191]*")
			name = string.upper(string.sub(name, 1, len)) .. string.lower(string.sub(name, len + 1))
		end
		
		player = {["name"] = name, ["realm"] = realm, ["level"] = level, ["class"] = class, ["race"] = race, ["added"] = added, ["reason"] = reason}
		table.insert(BlackListedPlayers, player)
		BlackList:sort()
		
		BlackList:HandleEvent("GROUP_ROSTER_UPDATE")
	
		BlackList:AddMessage(name .. " " .. "added to Black List.", "yellow")
	end

	--[[PanelTemplates_Tab_OnClick(FriendsTabHeaderTab3, FriendsTabHeader)
	if(not BlackListOptionsFrame:IsVisible()) then
		FriendsFrame:Show()
	end]]
	
	BlackList:SetSelectedBlackList(BlackList:GetIndexByName(name))
	FriendsFrame_Update()
	BlackList:ShowDetails()
end

function BlackList:RemovePlayer(index)
	local index = BlackList:GetSelectedBlackList()

	if (index == 0) then
		BlackList:AddMessage("Player not found.", "yellow")
		return
	end

	local name = BlackListedPlayers[index]["name"]

	table.remove(BlackListedPlayers, index)

	BlackList:AddMessage(name .. " removed from Black List.", "yellow")

	BlackList:UpdateUI()
	FriendsFrame_Update()
end

function BlackList:UpdateDetails(index, realm, reason, level, class, race)

	if(not realm) then 
		local realm = GetRealmName()
	end 
	
	-- update player
	local player = BlackList:GetPlayerByIndex(index)
	-- for old version i have to convert old name format (there was no format...) in new "Name" format
	if ((GetLocale() ~= "zhTW") and (GetLocale() ~= "zhCN") and (GetLocale() ~= "koKR")) then
		local _, len = string.find(player["name"], "[%z\1-\127\194-\244][\128-\191]*")
		player["name"] = string.upper(string.sub(player["name"], 1, len)) .. string.lower(string.sub(player["name"], len + 1))
	end
	
	if (realm ~= nil) then
		player["realm"] = realm
	else
		player["realm"] = BlackListedPlayers[index]["realm"]
	end		
		
	if (level ~= nil) then
		player["level"] = level
	else
		player["level"] = BlackListedPlayers[index]["level"]
	end
	
	if (class ~= nil) then
		player["class"] = class
	else
		player["class"] = BlackListedPlayers[index]["class"]
	end
	
	if (race ~= nil) then
		player["race"] = race
	else
		player["race"] = BlackListedPlayers[index]["race"]
	end

	if (reason ~= nil) then
		player["reason"] = reason
	else
		player["reason"] = BlackListedPlayers[index]["reason"]
	end

	tremove(BlackListedPlayers, index)
	tinsert(BlackListedPlayers, index, player)
end


-- Returns the number of blacklisted players
function BlackList:GetNumBlackLists()
	if(BlackListedPlayers == nil) then 
		return 0 
	end
	
	return table.getn(BlackListedPlayers)
end

-- Returns the index of the player given by name (and realm)
function BlackList:GetIndexByName(name, realm)
	if (name == nil) then 
		return 0
	end
	
	if(BlackListedPlayers == nil) then 
		return 0 
	end	
	
	if (realm ~= nil and realm ~= "") then
		for i = 1, BlackList:GetNumBlackLists() do
			if (strlower(BlackListedPlayers[i]["name"]) == strlower(name) and strlower(BlackListedPlayers[i]["realm"]) == strlower(realm)) then
				return i
			end	
		end
	else
		for i = 1, BlackList:GetNumBlackLists() do
			if (strlower(BlackListedPlayers[i]["name"]) == strlower(name) and strlower(BlackListedPlayers[i]["realm"]) == strlower(BlackList.realm)) then	
				return i
			end
		end
	end

	return 0
end

function BlackList:GetPlayerByIndex(index)

	if (index ~= nil and index < 1 or index > BlackList:GetNumBlackLists()) then
		return nil
	end

	return BlackListedPlayers[index]
end

function BlackList:AddMessage(msg, color)

	if (not BlackListConfig.Chat) then return end

	local r, g, b = 0, 0, 0

	if (color == "red") then
		r = 1
	elseif (color == "yellow") then
		r, g = 1, 1
	elseif (color == "green") then
		g = 1
	end

	DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b)
end

function BlackList:AddErrorMessage(msg, color, timeout)
	if (not BlackListConfig.Center) then return end

	local r, g, b = 0, 0, 0

	if (color == "red") then
		r = 1
	elseif (color == "yellow") then
		r, g = 1, 1
	end

	UIErrorsFrame:AddMessage(msg, r, g, b, nil, timeout)
end

function BlackList:AddSound()
	if (not BlackListConfig.Sound) then return end
	PlaySound(SOUNDKIT.PVPTHROUGHQUEUE or 8459)
end

function BlackList:TooltipInfo(tooltip, unitid)
	if (BlackListConfig.Tooltip == true and unitid and UnitIsPlayer(unitid)) then
		local name, realm = UnitName(unitid)
		
		local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name, realm))
		local ttline

		if(player ~= nil) then
			local reason = player["reason"]
			if(reason ~= "") then
				if reason:len() > 30 then reason = reason:sub(1, 30) .. "..." end
				ttline = "Black List: |cFFFFFFFF"..reason
			else
				ttline = "on your Black List"
			end
		
			GameTooltip:AddLine(ttline, 1, 0, 0, 0)
			GameTooltip:Show()
			return
		end
	end
end

function BlackList:GetFaction(race)

	local faction = 0

	if (race == "Human" or race == "Dwarf" or race == "NightElf" or race == "Gnome") then
		faction = 1
	elseif (race == "Orc" or race == "Undead" or race == "Tauren" or race == "Troll") then
		faction = 2
	end

	return faction
end

function BlackList:Convert()

	local converted = {}

	-- each realm
	for rindex,rvalue in pairs(BlackListedPlayers) do
		-- each player on realm
		if(type(rindex) == "string" and rvalue ~= nil) then 
			for pindex,pvalue in pairs(BlackListedPlayers[rindex]) do 
				BlackListedPlayers[rindex][pindex]["realm"] = rindex
				BlackListedPlayers[rindex][pindex]["warn"] = nil
				table.insert(converted, BlackListedPlayers[rindex][pindex])
			end
		end
	end	
	
	BlackListedPlayers = {}
	BlackListedPlayers = converted
	BlackList:sort()
end

function BlackList:sort()
	table.sort(BlackListedPlayers, BlackList.comparator)
end

function BlackList.comparator(a, b)
    -- Early exit if either value is nil to prevent errors
    if a == nil or b == nil then
        print("Warning: Nil value detected in comparator")
        return false
    end

    -- Directly compare the names
    return a["name"]:lower() < b["name"]:lower()
end

--[[function BlackList.comparator(a, b)
	if a == nil or b == nil then
		print("Warning: Nil value detected in comparator")
		return false
	end
	local strA = a["name"]
	local strB = b["name"]
	print("comparing " .. strA .. " to " .. strB)
	local lenA = strlen(strA)
	local lenB = strlen(strB)
	
	local length = 0
	if (lenA > lenB) then
		length = lenA
		print("length set to lenA")
	else
		length = lenB
		print("length set to lenB")
	end
	
	local byteA = 0
	local byteB = 0
	
	local returnValue = true
	for i=1,length do
		byteA = strbyte(strA, i)
		print("byteA set to " .. tostring(byteA))
		byteB = strbyte(strB, i)
		print("byteB set to " .. tostring(byteB))
		
		if (byteA == nil) then byteA = 0 end
		if (byteB == nil) then byteB = 0 end
		
		if (byteA < byteB) then
			print("byteA smaller than byteB")
			returnValue = true
			break
			
		elseif (byteA > byteB) then
			returnValue = false
			print("byteA greater than byteB")
			break
		end
	end
	return returnValue
end]]

function BlackList:ExportBlacklist()
    local exportFrame = CreateFrame("Frame", "BlackListExportFrame", UIParent, "BasicFrameTemplateWithInset")
    exportFrame:SetSize(500, 300)
    exportFrame:SetPoint("CENTER", 0, 200)
    exportFrame.title = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    exportFrame.title:SetPoint("CENTER", exportFrame.TitleBg, "CENTER", 0, 0)
    exportFrame.title:SetText("BlackList Export")
    exportFrame:SetMovable(true)
    exportFrame:EnableMouse(true)
    exportFrame:RegisterForDrag("LeftButton")
    exportFrame:SetScript("OnDragStart", exportFrame.StartMoving)
    exportFrame:SetScript("OnDragStop", exportFrame.StopMovingOrSizing)

    local scrollFrame = CreateFrame("ScrollFrame", "BlackListExportScrollFrame", exportFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(430, 220)
    scrollFrame:SetPoint("TOP", exportFrame, "TOP", 0, -30)

    exportFrame.editBox = CreateFrame("EditBox", nil, scrollFrame)
    exportFrame.editBox:SetMultiLine(true)
    exportFrame.editBox:SetFontObject(ChatFontNormal)
    exportFrame.editBox:SetWidth(430)
    exportFrame.editBox:SetAutoFocus(true)
    exportFrame.editBox:SetText(BlackList:GenerateCSV())
	exportFrame.editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

    scrollFrame:SetScrollChild(exportFrame.editBox)

    local copyButton = CreateFrame("Button", nil, exportFrame, "UIPanelButtonTemplate")
    copyButton:SetSize(100, 25)
    copyButton:SetText("Highlight")
    copyButton:SetPoint("BOTTOMLEFT", exportFrame, "BOTTOMLEFT", 20, 20)
	copyButton:SetScript("OnClick", function() exportFrame.editBox:HighlightText() end)

    local closeButton = CreateFrame("Button", nil, exportFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(100, 25)
    closeButton:SetText("Close")
    closeButton:SetPoint("BOTTOMRIGHT", exportFrame, "BOTTOMRIGHT", -20, 20)
    closeButton:SetScript("OnClick", function() exportFrame:Hide() end)

    exportFrame:Show()
end


-- Import function
function BlackList:ImportBlacklist(data)
	BlackList:AddMessage("***PLEASE MAKE SURE YOU'VE BACKED UP YOUR CURRENT BLACKLIST TO AVOID HAVING TO WIPE AND RESTART***", "red")
	BlackList:AddMessage("How to use:", "yellow")
	BlackList:AddMessage("Copy the text within a CSV formatted blacklist generated by this add-on by yourself or another user.", "yellow")
	BlackList:AddMessage("Paste into the Import window and hit Import.", "yellow")
    local importFrame = CreateFrame("Frame", "BlackListImportFrame", UIParent, "BasicFrameTemplateWithInset")
    importFrame:SetSize(500, 300)
    importFrame:SetPoint("CENTER", 0, 200)
    importFrame.title = importFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    importFrame.title:SetPoint("CENTER", importFrame.TitleBg, "CENTER", 0, 0)
    importFrame.title:SetText("BlackList Import")
	importFrame:SetMovable(true)
    importFrame:EnableMouse(true)
    importFrame:RegisterForDrag("LeftButton")
    importFrame:SetScript("OnDragStart", importFrame.StartMoving)
    importFrame:SetScript("OnDragStop", importFrame.StopMovingOrSizing)

    local scrollFrame = CreateFrame("ScrollFrame", "BlackListImportScrollFrame", importFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(430, 220)
    scrollFrame:SetPoint("TOP", importFrame, "TOP", 0, -30)

    importFrame.editBox = CreateFrame("EditBox", nil, scrollFrame)
    importFrame.editBox:SetMultiLine(true)
    importFrame.editBox:SetFontObject(ChatFontNormal)
    importFrame.editBox:SetWidth(430)
    importFrame.editBox:SetAutoFocus(true)
    importFrame.editBox:SetText(data or "") -- Set the default text if provided
	importFrame.editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

    scrollFrame:SetScrollChild(importFrame.editBox)

    importFrame.importButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
    importFrame.importButton:SetSize(100, 25)
    importFrame.importButton:SetText("Import")
    importFrame.importButton:SetPoint("BOTTOMLEFT", importFrame, "BOTTOMLEFT", 20, 20)
    importFrame.importButton:SetScript("OnClick", function() BlackList:ProcessImportData(importFrame.editBox:GetText()); importFrame:Hide() end)

    importFrame.closeButton = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
    importFrame.closeButton:SetSize(100, 25)
    importFrame.closeButton:SetText("Close")
    importFrame.closeButton:SetPoint("BOTTOMRIGHT", importFrame, "BOTTOMRIGHT", -20, 20)
    importFrame.closeButton:SetScript("OnClick", function() importFrame:Hide() end)

    importFrame:Show()
end

function BlackList:ImportDetails(index, name, realm, reason, level, class, race)
    if not realm then 
        realm = GetRealmName()
    end 

    -- update player
    local player = BlackList:GetPlayerByIndex(index)

    -- for old version i have to convert old name format (there was no format...) in new "Name" format
    if ((GetLocale() ~= "zhTW") and (GetLocale() ~= "zhCN") and (GetLocale() ~= "koKR")) then
        local _, len = string.find(player["name"], "[%z\1-\127\194-\244][\128-\191]*")
        player["name"] = string.upper(string.sub(player["name"], 1, len)) .. string.lower(string.sub(player["name"], len + 1))
    end

    if realm then
        player["realm"] = realm
    else
        player["realm"] = BlackListedPlayers[index]["realm"]
    end        

    if level then
        player["level"] = level
    else
        player["level"] = BlackListedPlayers[index]["level"]
    end

    if class then
        player["class"] = class
    else
        player["class"] = BlackListedPlayers[index]["class"]
    end

    if race then
        player["race"] = race
    else
        player["race"] = BlackListedPlayers[index]["race"]
    end

    if reason and reason ~= "" then
        local existingReason = BlackListedPlayers[index]["reason"]
        -- Append the new reason to the existing reason if the imported reason is not blank and different
        if existingReason ~= reason then
            player["reason"] = existingReason .. " AND " .. reason
        else
            player["reason"] = existingReason
        end
    else
        player["reason"] = BlackListedPlayers[index]["reason"]
    end

    tremove(BlackListedPlayers, index)
    tinsert(BlackListedPlayers, index, player)
end


function BlackList:RemoveSyncPlayer(index)
	table.remove(BlackListedPlayers, index)
end
			
-- Process imported data and add players
function BlackList:ProcessImportData(importData)
    if not importData or importData == "" then
        BlackList:AddMessage("No data to import.", "yellow")
        return
    end
	
    local lines = {strsplit("\n", importData)}
	
    for _, line in ipairs(lines) do
        local fields = {strsplit(",", line)}
        local playerName = fields[1]
        local playerRealm = fields[6]
        local playerReason = fields[5]
        local playerLevel = fields[2]
        local playerClass = fields[3]
        local playerRace = fields[4]
		
		
        if playerName and playerRealm then
            -- Check for duplicates
            local index = BlackList:GetIndexByName(playerName, playerRealm)
            if index > 0 and playerReason == "REMOVEFROMBL" then
				BlackList:RemoveSyncPlayer(index)
				BlackList:AddMessage(playerName .. " removed from blacklist.", "red")
			elseif index > 0 then
                -- Update Notes section if duplicate is found
                BlackList:ImportDetails(index, playerName, playerRealm, playerReason, playerLevel, playerClass, playerRace)
                BlackList:AddMessage(playerName .. " already in Black List, updated Notes section.", "yellow")
            elseif playerReason == "REMOVEFROMBL" then
				BlackList:AddMessage(playerName .. " ignored due to reason set to REMOVEFROMBL", "yellow")
			else
                -- Add player if not a duplicate
                BlackList:AddPlayer(playerName, playerRealm, playerReason, playerLevel, playerClass, playerRace)
            end
        end
    end
	BlackList:UpdateUI()
end

-- Function to generate CSV from BlackList table
function BlackList:GenerateCSV()
    local csv = ""
    for _, player in ipairs(BlackListedPlayers) do
        local sanitizedReason = string.gsub(player.reason, ",", ".") -- Replace commas with periods
        csv = csv .. player.name .. "," .. player.level .. "," .. player.class .. "," .. player.race .. "," .. sanitizedReason .. "," .. player.realm .. "\n"
    end
    return csv
end

-- Add this function at the end of your code
function BlackList:DataNuke()
    -- Show confirmation dialog
    BlackList:DataNukeConfirmation()
end

-- StaticPopupDialogs block and additional functions should be at the same level as DataNuke function
StaticPopupDialogs["BLACKLIST_CONFIRM_NUKE"] = {
    text = "Are you sure you want to nuke all data? This action cannot be undone.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BlackList:PerformDataNuke()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function BlackList:DataNukeConfirmation()
    StaticPopup_Show("BLACKLIST_CONFIRM_NUKE")
end

function BlackList:PerformDataNuke()
    local numPlayers = BlackList:GetNumBlackLists()

    for i = numPlayers, 1, -1 do
        BlackList:RemovePlayer(i)
    end

    BlackList:AddMessage("All data nuked. BlackList table is empty now.", "yellow")
end

-- Help Info
function BlackList:PrintHelpInfo()
	BlackList:AddMessage("************", "green")
	BlackList:AddMessage("Simple Blacklist for Classic -- developed by EffinOwen", "red")
	BlackList:AddMessage("************", "green")
	BlackList:AddMessage("Available Commands:", "yellow")
	BlackList:AddMessage("/blhelp, /blacklisthelp - Shows this info.", "green")
	BlackList:AddMessage("/blsync, /blacklistsync - Opens up an import prompt which allows you to import the default blacklist included with the add-on.", "green")
	BlackList:AddMessage("/bl, /blacklist - Add a player to the blacklist. Adds the currently targetted player first, if no target then it will pop up and ask for a name. Can also do /bl *name* to add a name quick.", "green")
	BlackList:AddMessage("/blexport, /blacklistexport - Starts the exporting process.", "green")
	BlackList:AddMessage("/blimport, /blacklistimport - Starts the importing process. Please backup your list before you do this just to be safe.", "green")
	BlackList:AddMessage("/bldatanuke, /blacklistdatanuke - Starts the data nuke process, has a confirmation dialog but once it is done it is not reversable. Use only when you need a clean slate.", "red")
	BlackList:AddMessage("More questions? Official discord server with community driven blacklists available at: https://discord.gg/9CMhszeJfu", "yellow")
	BlackList:AddMessage("************", "green")
end

--Color for Text

GREY = "|cff888888"
WHITE = "|cffffffff"
SUBWHITE = "|cffbbbbbb"
MAGENTA = "|cffff00ff"
YELLOW = "|cffffff00"
CYAN = "|cff00ffff"
LIGHTRED = "|cffff6060"
LIGHTBLUE = "|cff00ccff"
BLUE = "|cff0000ff"
GREEN = "|cff00ff00"
RED = "|cffff0000"
GOLD = "|cffffcc00"
ALICEBLUE = "|cFFF0F8FF"
ANTIQUEWHITE = "|cFFFAEBD7"
AQUA = "|cFF00FFFF"
AQUAMARINE = "|cFF7FFFD4"
AZURE = "|cFFF0FFFF"
BEIGE = "|cFFF5F5DC"
BISQUE = "|cFFFFE4C4"
BLACK = "|cFF000000"
BLANCHEDALMOND = "|cFFFFEBCD"
BLUE = "|cFF0000FF"
BLUEVIOLET = "|cFF8A2BE2"
BROWN = "|cFFA52A2A"
BURLYWOOD = "|cFFDEB887"
CADETBLUE = "|cFF5F9EA0"
CHARTREUSE = "|cFF7FFF00"
CHOCOLATE = "|cFFD2691E"
CORAL = "|cFFFF7F50"
CORNFLOWERBLUE = "|cFF6495ED"
CORNSILK = "|cFFFFF8DC"
CRIMSON = "|cFFDC143C"
CYAN = "|cFF00FFFF"
DARKBLUE = "|cFF00008B"
DARKCYAN = "|cFF008B8B"
DARKGOLDENROD = "|cFFB8860B"
DARKGRAY = "|cFFA9A9A9"
DARKGREEN = "|cFF006400"
DARKKHAKI = "|cFFBDB76B"
DARKMAGENTA = "|cFF8B008B"
DARKOLIVEGREEN = "|cFF556B2F"
DARKORANGE = "|cFFFF8C00"
DARKORCHID = "|cFF9932CC"
DARKRED = "|cFF8B0000"
DARKSALMON = "|cFFE9967A"
DARKSEAGREEN = "|cFF8FBC8B"
DARKSLATEBLUE = "|cFF483D8B"
DARKSLATEGRAY = "|cFF2F4F4F"
DARKTURQUOISE = "|cFF00CED1"
DARKVIOLET = "|cFF9400D3"
DEEPPINK = "|cFFFF1493"
DEEPSKYBLUE = "|cFF00BFFF"
DIMGRAY = "|cFF696969"
DODGERBLUE = "|cFF1E90FF"
FIREBRICK = "|cFFB22222"
FLORALWHITE = "|cFFFFFAF0"
FORESTGREEN = "|cFF228B22"
FUCHSIA = "|cFFFF00FF"
GAINSBORO = "|cFFDCDCDC"
GHOSTWHITE = "|cFFF8F8FF"
GOLD = "|cFFFFD700"
GOLDENROD = "|cFFDAA520"
GRAY = "|cFF808080"
GREEN = "|cFF008000"
GREENYELLOW = "|cFFADFF2F"
HONEYDEW = "|cFFF0FFF0"
HOTPINK = "|cFFFF69B4"
INDIANRED = "|cFFCD5C5C"
INDIGO = "|cFF4B0082"
IVORY = "|cFFFFFFF0"
KHAKI = "|cFFF0E68C"
LAVENDER = "|cFFE6E6FA"
LAVENDERBLUSH = "|cFFFFF0F5"
LAWNGREEN = "|cFF7CFC00"
LEMONCHIFFON = "|cFFFFFACD"
LIGHTBLUE = "|cFFADD8E6"
LIGHTCORAL = "|cFFF08080"
LIGHTCYAN = "|cFFE0FFFF"
LIGHTGRAY = "|cFFD3D3D3"
LIGHTGREEN = "|cFF90EE90"
LIGHTPINK = "|cFFFFB6C1"
LIGHTRED = "|cFFFF6060"
LIGHTSALMON = "|cFFFFA07A"
LIGHTSEAGREEN = "|cFF20B2AA"
LIGHTSKYBLUE = "|cFF87CEFA"
LIGHTSLATEGRAY = "|cFF778899"
LIGHTSTEELBLUE = "|cFFB0C4DE"
LIGHTYELLOW = "|cFFFFFFE0"
LIME = "|cFF00FF00"
LIMEGREEN = "|cFF32CD32"
LINEN = "|cFFFAF0E6"
MAGENTA = "|cFFFF00FF"
MAROON = "|cFF800000"
MEDIUMAQUAMARINE = "|cFF66CDAA"
MEDIUMBLUE = "|cFF0000CD"
MEDIUMORCHID = "|cFFBA55D3"
MEDIUMPURPLE = "|cFF9370DB"
MEDIUMSEAGREEN = "|cFF3CB371"
MEDIUMSLATEBLUE = "|cFF7B68EE"
MEDIUMSPRINGGREEN = "|cFF00FA9A"
MEDIUMTURQUOISE = "|cFF48D1CC"
MEDIUMVIOLETRED = "|cFFC71585"
MIDNIGHTBLUE = "|cFF191970"
MINTCREAM = "|cFFF5FFFA"
MISTYROSE = "|cFFFFE4E1"
MOCCASIN = "|cFFFFE4B5"
NAVAJOWHITE = "|cFFFFDEAD"
NAVY = "|cFF000080"
OLDLACE = "|cFFFDF5E6"
OLIVE = "|cFF808000"
OLIVEDRAB = "|cFF6B8E23"
ORANGE = "|cFFFFA500"
ORANGERED = "|cFFFF4500"
ORCHID = "|cFFDA70D6"
PALEGOLDENROD = "|cFFEEE8AA"
PALEGREEN = "|cFF98FB98"
PALETURQUOISE = "|cFFAFEEEE"
PALEVIOLETRED = "|cFFDB7093"
PAPAYAWHIP = "|cFFFFEFD5"
PEACHPUFF = "|cFFFFDAB9"
PERU = "|cFFCD853F"
PINK = "|cFFFFC0CB"
PLUM = "|cFFDDA0DD"
POWDERBLUE = "|cFFB0E0E6"
PURPLE = "|cFF800080"
RED = "|cFFFF0000"
ROSYBROWN = "|cFFBC8F8F"
ROYALBLUE = "|cFF4169E1"
SADDLEBROWN = "|cFF8B4513"
SALMON = "|cFFFA8072"
SANDYBROWN = "|cFFF4A460"
SEAGREEN = "|cFF2E8B57"
SEASHELL = "|cFFFFF5EE"
SIENNA = "|cFFA0522D"
SILVER = "|cFFC0C0C0"
SKYBLUE = "|cFF87CEEB"
SLATEBLUE = "|cFF6A5ACD"
SLATEGRAY = "|cFF708090"
SNOW = "|cFFFFFAFA"
SPRINGGREEN = "|cFF00FF7F"
STEELBLUE = "|cFF4682B4"
TAN = "|cFFD2B48C"
TEAL = "|cFF008080"
THISTLE = "|cFFD8BFD8"
TOMATO = "|cFFFF6347"
TRANSPARENT = "|c00FFFFFF"
TURQUOISE = "|cFF40E0D0"
VIOLET = "|cFFEE82EE"
WHEAT = "|cFFF5DEB3"
WHITE = "|cFFFFFFFF"
WHITESMOKE = "|cFFF5F5F5"
YELLOW = "|cFFFFFF00"
YELLOWGREEN = "|cFF9ACD32"
ColorClose = "|r"


function parseDate(str)
    local month, day, year = str:match("(%a+) (%d+) (%d+)")
    if not (month and day and year) then
        return nil -- Return nil if the date string is invalid
    end
    local months = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
    local monthNumber = months[month]

    return {year = tonumber(year), month = monthNumber, day = tonumber(day)}
end

function isDate2Bigger(dateStr1, dateStr2)
    local date1 = parseDate(dateStr1)
    local date2 = parseDate(dateStr2)

	if not date1 or not date2 then
        return false -- Return false if either date is invalid
    end

    return time(date2) >= time(date1)
end
