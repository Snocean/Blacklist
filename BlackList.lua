BlackList = {}
BlackListedPlayers = {}
BlackListOptions = {}

BlackList.realm = GetRealmName()

--BlackList.debug = true

local BL_Blocked_Channels = {"SAY", "YELL", "WHISPER", "WHISPER_INFORM", "PARTY", "RAID", "RAID_WARNING", "EMOTE", "TEXT_EMOTE", "CHANNEL", "CHANNEL_JOIN", "CHANNEL_LEAVE"}

local Already_Warned_For = {}
Already_Warned_For["WHISPER"] = {}
Already_Warned_For["TARGET"] = {}
Already_Warned_For["PARTY_INVITE"] = {}
Already_Warned_For["PARTY"] = {}
Already_Warned_For["MOUSEOVER"] = {}
Already_Warned_For["GUILD_MSG"] = {}

local Orig_FriendsFrame_Update
local Orig_ChatFrame_MessageEventHandler

local BL_Default = {
	Sound = true,
	Center = true,
	Chat = true,
	Tooltip = true,
	MItem = true,
}

-- Function to handle onload event
function BlackList:OnLoad()

	--C_ChatInfo.RegisterAddonMessagePrefix("BlackList")
	if (not BlackListConfig) then BlackListConfig = BL_Default end
	if BlackListConfig.Sound == nil or "" then BlackListConfig.Sound = true end
	if BlackListConfig.Center == nil or "" then BlackListConfig.Center = true end
	if BlackListConfig.Chat == nil or "" then BlackListConfig.Chat = true end
	if BlackListConfig.Tooltip == nil or "" then BlackListConfig.Tooltip = true end


	-- constructions
	BlackList:InsertUI()
	BlackList:RegisterEvents()
	BlackList:HookFunctions()
	BlackList:RegisterSlashCmds()
	BlackList:AddMessage("************", "red")
	BlackList:AddMessage("Simple Blacklist for Classic loaded! Type /blhelp for more info!", "green")
	--BlackList:AddMessage(syncDate .. " is current sync database date, use /blsync to sync if desired!", "green")
	BlackList:AddMessage("************", "red")


	return
end

-- Registers events to be recieved
function BlackList:RegisterEvents()

	local frame = _G["BlackListTopFrame"]

	-- register events
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("PARTY_INVITE_REQUEST")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	frame:RegisterEvent("WHO_LIST_UPDATE")
	frame:RegisterEvent("CHAT_MSG_SYSTEM")
	--frame:RegisterEvent("CHAT_MSG_ADDON")
	frame:RegisterEvent("CHAT_MSG_GUILD")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("CHAT_MSG_WHISPER")

	return
end

local function blackListButton(self)
if self.value == "BlacklistButton" then
	local dropdownMenu = _G["UIDROPDOWNMENU_INIT_MENU"]
		if(dropdownMenu.name ~= UnitName("player")) then
			BlackList:AddPlayer(dropdownMenu.name)
 		end
	 else
	end
   end

   hooksecurefunc("UnitPopup_ShowMenu", function()
	if (UIDROPDOWNMENU_MENU_LEVEL > 1) then
	 return
	end
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Add to BlackList"
	info.owner = which
	info.notCheckable = 1
	info.func = blackListButton
	info.colorCode = "|cffff0000"
	info.value = "BlacklistButton"
	UIDropDownMenu_AddButton(info)
end)


-- Hooks onto the functions needed
function BlackList:HookFunctions()
	GameTooltip:HookScript("OnTooltipSetUnit",
	function(self)
		local name, unitid = self:GetUnit()
		if (not unitid) then
			unitid = "mouseover"
		end
		BlackList:TooltipInfo(self, unitid)
	end)
end

function BlackList:HideBlackListFrame()
	-- Hide other subframes
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			_G[value]:Show()
		elseif ( value == "RaidFrame" ) then
			if ( RaidFrame:GetParent() == FriendsFrame ) then
				RaidFrame:Hide();
			end
		elseif ( value == "CommunitiesFrame") then
			if ( CommunitiesFrame and CommunitiesFrame:IsVisible() ) then
				CommunitiesFrame:Hide();
			end
		else
			_G[value]:Hide();
		end
	end

	if BlackListFrame:IsShown() then
		BlackListFrame:Hide()
	end
end

function FriendsFrame_BLUpdate()
	local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame) or FRIEND_TAB_FRIENDS;

	FriendsTabHeader:SetShown(selectedTab == FRIEND_TAB_FRIENDS);

	if selectedTab == FRIEND_TAB_FRIENDS then
		local selectedHeaderTab = PanelTemplates_GetSelectedTab(FriendsTabHeader) or FRIEND_HEADER_TAB_FRIENDS;

		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -83);

		if selectedHeaderTab == FRIEND_HEADER_TAB_FRIENDS then
			C_FriendList.ShowFriends();
			FriendsFrameTitleText:SetText(FRIENDS_LIST);
			FriendsFrame_ShowSubFrame("FriendsListFrame");
		elseif selectedHeaderTab == FRIEND_HEADER_TAB_QUICK_JOIN then
			FriendsFrameTitleText:SetText(QUICK_JOIN);
			FriendsFrame_ShowSubFrame("QuickJoinFrame");
		elseif selectedHeaderTab == FRIEND_HEADER_TAB_IGNORE then
			FriendsFrameIgnorePlayerButton:SetWidth(131);
			FriendsFrameUnsquelchButton:SetWidth(134);
			FriendsFrameTitleText:SetText(IGNORE_LIST);
			FriendsFrame_ShowSubFrame("IgnoreListFrame");
			IgnoreList_Update();
		end
	--[[elseif ( selectedTab == FRIEND_TAB_WHO ) then
		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -80);
		FriendsFrameTitleText:SetText(WHO_LIST);
		FriendsFrame_ShowSubFrame("WhoFrame");
		WhoList_Update();
	elseif ( selectedTab == FRIEND_TAB_GUILD ) then
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -80);
		local guildName;
		guildName = GetGuildInfo("player");
		if (guildName) then
			FriendsFrameTitleText:SetText(guildName);
		end
		FriendsFrame_ShowSubFrame("GuildFrame");
		GuildStatus_Update();
		GuildFrame.hasForcedNameChange = GetGuildRenameRequired();
		GuildFrame_CheckName();]]
	elseif ( selectedTab == FRIEND_TAB_RAID ) then
		ButtonFrameTemplate_ShowButtonBar(FriendsFrame);
		FriendsFrameInset:SetPoint("TOPLEFT", 4, -60);
		FriendsFrameTitleText:SetText(RAID);
		ClaimRaidFrame(FriendsFrame);
		FriendsFrame_ShowSubFrame("RaidFrame");
	elseif ( selectedTab == FRIEND_TAB_BLIZZARDGROUPS ) then
		-- Hide the current frame and swap to the Communities Frame.
		FriendsFrame_ToggleToCommunities(selectedTab);
	end
end

hooksecurefunc("FriendsFrame_Update", function(self)
	if PanelTemplates_GetSelectedTab(FriendsFrame) == 100 then
        BlackList:ShowBlackListFrame()
		FriendsTabHeader:Hide()
		BlackList:UpdateUI()
		--ButtonFrameTemplate_ShowButtonBar(FriendsFrame)
		FriendsFrameTitleText:SetText("Black List")
		--FriendsFrameInset:SetPoint("TOPLEFT", 4, -80)
	else
		if BlackListFrame:IsShown() then
			BlackList:HideBlackListFrame()
		end
	FriendsFrame_BLUpdate()
    end
end)

-- Registers slash cmds for adding players to blacklist
function BlackList:RegisterSlashCmds()
    SlashCmdList["BLACKLIST"] = function(args) BlackList:HandleSlashCmd("bl", args) end
    SLASH_BLACKLIST1 = "/blacklist"
    SLASH_BLACKLIST2 = "/bl"

    SlashCmdList["BL_EXPORT"] = function(args) BlackList:HandleSlashCmd("export", args) end
    SLASH_BL_EXPORT1 = "/blexport"
    SLASH_BL_EXPORT2 = "/blacklistexport"

    SlashCmdList["BL_IMPORT"] = function(args) BlackList:HandleSlashCmd("import", args) end
    SLASH_BL_IMPORT1 = "/blimport"
    SLASH_BL_IMPORT2 = "/blacklistimport"
	
	SlashCmdList["BL_NUKE"] = function(args) BlackList:HandleSlashCmd("nuke", args) end
    SLASH_BL_NUKE1 = "/bldatanuke"
    SLASH_BL_NUKE2 = "/blacklistdatanuke"
	
	SlashCmdList["BL_HELP"] = function(args) BlackList:HandleSlashCmd("help", args) end
    SLASH_BL_HELP1 = "/blhelp"
    SLASH_BL_HELP2 = "/blacklisthelp"
	
	SlashCmdList["BL_SYNC"] = function(args) BlackList:HandleSlashCmd("sync", args) end
    SLASH_BL_SYNC1 = "/blsync"
    SLASH_BL_SYNC2 = "/blacklistsync"
end

-- Handles the slash cmds
function BlackList:HandleSlashCmd(cmd, args)
    if cmd == "blacklist" or cmd == "bl" then
        if args == "" then
            BlackList:AddPlayer("target")
        else
            BlackList:AddPlayer(args)
        end
    elseif cmd == "export" or cmd == "blacklistexport" then
        -- Handle the export commands as needed
        BlackList:ExportBlacklist()
    elseif cmd == "import" or cmd == "blacklistimport" then
        -- Handle the import commands as needed
        BlackList:ImportBlacklist(args)
	elseif cmd == "nuke" or cmd == "blacklistdatanuke" then
        -- Handle the import commands as needed
        BlackList:DataNukeConfirmation()
	elseif cmd == "help" or cmd == "blacklisthelp" then
        -- Handle the import commands as needed
        BlackList:PrintHelpInfo()
	elseif cmd == "sync" or cmd == "blacklistsync" then
        -- Handle the import commands as needed
		if BLSyncFileExists == true then
        	BlackList:SyncPopup()
		else
			print("No sync file found in addon folder, visit the discord for more information")
		end
    end
end

function split(inputstr, sep) 
	local t={} 
	for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do 
		table.insert(t,field) 
		if s=="" then 
			return t 
		end 
	end 
end

--[[function split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end]]

-- Function to handle events
function BlackList:HandleEvent(self, event, ...)

	local arg1 = ...

	if (event == "VARIABLES_LOADED") then

		if (BlackListedPlayers[BlackList.realm]) then
			BlackList:Convert()
			return
		end

		if (not BlackListedPlayers) then
			BlackListedPlayers = {}
		end
	--elseif (event == "PLAYER_ENTERING_WORLD") then
		--BlackList:InsertUI()
	elseif (event == "PLAYER_TARGET_CHANGED") then
		-- search for player name
		if (not UnitIsPlayer("target")) then
			return
		end

		local name, realm = UnitName("target")
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name, realm))

			-- warn player
			local alreadywarned = false
			for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
				if ((name == warnedname) and (GetTime() < timepassed+10)) then
					alreadywarned = true
				end
			end

			if (not alreadywarned) then
				Already_Warned_For["TARGET"][name]=GetTime()
				BlackList:AddSound()
				BlackList:AddErrorMessage(name .. " is on your Black List (targeted)", "red", 5)
				BlackList:AddMessage(name .. " is on your Black List for reason: " .. player["reason"], "yellow")
			end
		end
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		-- search for player name
		local name, realm = UnitName("mouseover")
		local index = BlackList:GetIndexByName(name, realm)
		if (index > 0) then
			local player = BlackList:GetPlayerByIndex(index)

			-- warn player
			local alreadywarned = false
			for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
				if ((name == warnedname) and (GetTime() < timepassed+30)) then
					alreadywarned = true
				end
			end

			if (not alreadywarned) then
				Already_Warned_For["TARGET"][name]=GetTime()
				BlackList:AddSound()
				BlackList:AddErrorMessage(name .. " is on your Black List (mouseover)", "red", 5)
				if(player["reason"] ~= "") then
					BlackList:AddMessage(name .. " is on your Black List for reason: " .. player["reason"], "red")
				else
					BlackList:AddMessage(name .. " is on your Black List.", "red")
				end
				-- also update character info
				local _, class = UnitClass("mouseover")
				local _, race = UnitRace("mouseover")
				BlackList:UpdateDetails(index, nil, nil, UnitLevel("mouseover"), class, race)
			end
		end
	elseif (event == "PARTY_INVITE_REQUEST") then
		-- search for player name
		local name = arg1
		local index = BlackList:GetIndexByName(name)
		if (index > 0) then
			local player = BlackList:GetPlayerByIndex(index)

			local alreadywarned = false
			for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
				if ((name == warnedname) and (GetTime() < timepassed+10))  then
					alreadywarned = true
				end
			end
			if (not alreadywarned) then
				Already_Warned_For["TARGET"][name]=GetTime()+300
				BlackList:AddSound()
				BlackList:AddErrorMessage(name .. " is on your Black List (invited to party).", "red", 10)
			end
		end
	elseif (event == "GROUP_ROSTER_UPDATE") then
		for i = 0, GetNumSubgroupMembers() do
			-- search for player name
			local name, realm = UnitName("party" .. i)
			local index = BlackList:GetIndexByName(name, realm)
			if (index > 0) then
				local player = BlackList:GetPlayerByIndex(index)

				local alreadywarned = false
				for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
					if ((name == warnedname) and (GetTime() < timepassed+10))  then
						alreadywarned = true
					end
				end
				if (not alreadywarned) then
					Already_Warned_For["TARGET"][name]=GetTime()+300
					BlackList:AddSound()
					BlackList:AddMessage(name .. " is on your Black List (in your party)", "red")
					if player["reason"] ~= "" then
						BlackList:AddMessage("for: " .. player["reason"], "red")
					end
				end
			end
		end
	elseif (event == "WHO_LIST_UPDATE") then
		local numWhos = C_FriendList.GetNumWhoResults()
		for i = 1, numWhos do
		  local info = C_FriendList.GetWhoInfo(i)
		  local whoname = info.fullName
		  
			if (BlackList:GetIndexByName(whoname) > 0) then
				BlackList:AddMessage(whoname .. " is on your Black List (from your who search).", "red")
			end
		end
	elseif (event == "CHAT_MSG_GUILD") then
		local name, realm = select(6, GetPlayerInfoByGUID(select(12, ...)))
		if BlackList:GetIndexByName(name, realm) == 0 then
			return
		end
		local index = BlackList:GetIndexByName(name)
		if (index > 0) then
			local player = BlackList:GetPlayerByIndex(index)
			local alreadywarned = false
		
		for key, warnedname in pairs(Already_Warned_For["GUILD_MSG"]) do
			if (name == warnedname) then
				alreadywarned = true
			end
		end
		if (not alreadywarned) then
			tinsert(Already_Warned_For["GUILD_MSG"], name)
			BlackList:AddSound()
			BlackList:AddMessage(name .. " is on your blacklist and in your guild", "red")
			if player["reason"] ~= "" then
				BlackList:AddMessage("for: " .. player["reason"], "red")
				end
			end
		end
	elseif (event == "CHAT_MSG_SYSTEM" and arg1 ~= nil) then
		local whoname = string.match(arg1, "(%a+)", 10)
		if (BlackList:GetIndexByName(whoname) > 0) then
			BlackList:AddMessage(whoname .. " is on your Black List", "red")
		end
	elseif (event == "CHAT_MSG_WHISPER") then
		local name, realm = select(6, GetPlayerInfoByGUID(select(12, ...)))
		if BlackList:GetIndexByName(name, realm) == 0 then
			return
		end
		local index = BlackList:GetIndexByName(name)
		if (index > 0) then
			local player = BlackList:GetPlayerByIndex(index)
			local alreadywarned = false
		for key, warnedname in pairs(Already_Warned_For["WHISPER"]) do
			if (name == warnedname) then
				alreadywarned = true
			end
		end
		if (not alreadywarned) then
			tinsert(Already_Warned_For["WHISPER"], name)
			BlackList:AddMessage(name .. " is on your blacklist", "red")
			if player["reason"] ~= "" then
				BlackList:AddMessage("for: " .. player["reason"], "red")
			end
		end
	end
end
end