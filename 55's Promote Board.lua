
--[[

Version 2.6 - Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=1459817693

Scripted by 55tremine, using chry's promote board model and base design
morten also created the print hours command.

The do loops are used to make sections. 
on the scripting platforms that I use you can collapse these.

Todo:
random player
update workshop page

Changes:
a -> ac for less common in other objects
fixed secret hitler options closing

]]--

buttons = {}

do --overall functions

function onLoad(save_state)
	count = 0
	clrnmbr = 1 -- default is white
	selectedColour = 0
	selectingColour = 0
	black={0,0,0}
	white={1,1,1}
	colours = {"White","Brown","Red","Orange","Yellow","Green","Teal","Blue","Purple","Pink","Black"}
	teams = {"Diamonds", "Hearts", "Jokers", "Clubs", "Spades", "None"}
	clrnums = {"[ffffff]","[703A16]","[DA1917]","[F3631C]","[E6E42B]","[30B22A]","[20B09A]","[1E87FF]","[9F1FEF]","[F46FCD]","[3F3F3F]"}
	clrLocations = {{23.67, 2.41, -34.26},{0.00, 2.41, -34.43},{-23.67, 2.41, -34.43},{-51.66, 2.41, -11.73},{-51.66, 2.41, 11.73},{-23.67, 2.41, 34.43},{0.00, 2.41, 34.45},{23.67, 2.41, 34.45},{51.58, 2.41, 11.73},{51.64, 2.41, -11.73}}
	silenced = {}
	page = 1
	btTarget = {"",""}
	hexRainbow = {"[FF0000]", "[FF8000]", "[FFFF00]", "[80FF00]", "[00FF00]", "[00FF80]", "[00FFFF]", "[0080FF]", "[8080FF]", "[8000FF]", "[FF80FF]", "[FF0080]"}
	
	--extraOptionsOpen = false
	
	onScreen = 1
	
	self.clearButtons()
	self.clearInputs()
	setCommandList()
	createOff()
	self.setColorTint(white)
	
	if save_state ~= "" then
		loadSave(save_state)
	else
		fullReset()
	end
	
	createMainScreen()
end

function fullReset()
	announceColour = "[1ac6ff]"
	copyText = ""
	maxPickup = -1
	nicknames = {}
	trusted = {}
	interact = true
	chatCommands = true
	autoPromote = false
	greyBT = false
	kickBT = false
	printCommands = false
	printHoursOnJoin = false
	stopVoteTouching = false
	extraOptionsOpen = false
end

function nilFunction()
	return false
end

function loadSave(save_state)
	local promoteBoardSave = JSON.decode(save_state)
	
	autoPromote 		= promoteBoardSave["autoPromote"]
	greyBT 				= promoteBoardSave["greyBT"]
	kickBT 				= promoteBoardSave["kickBT"]
	printCommands 		= promoteBoardSave["printCommands"]
	printHoursOnJoin	= promoteBoardSave["printHoursOnJoin"]
	announceColour 		= promoteBoardSave["announceColour"]
	nicknames 			= promoteBoardSave["nicknames"]
	trusted 			= promoteBoardSave["trusted"]
	interact 			= promoteBoardSave["interact"]
	---copyText 			= promoteBoardSave["copyText"]
	maxPickup			= promoteBoardSave["maxPickup"]
	stopVoteTouching 	= promoteBoardSave["stopVoteTouching"]
	extraOptionsOpen 	= promoteBoardSave["extraOptionsOpen"]
	
	---if interact then
	----	self.interactable = true
	---	self.setLock(false)
	---else
	---	self.interactable = false
	---	self.setLock(true)
	---end
	chatCommands 		= promoteBoardSave["chatCommands"]
end

function onSave()
	local promoteBoardSave = {}
	
	promoteBoardSave["autoPromote"] 	= autoPromote
	promoteBoardSave["greyBT"] 			= greyBT
	promoteBoardSave["kickBT"] 			= kickBT
	promoteBoardSave["printCommands"] 	= printCommands
	promoteBoardSave["printHoursOnJoin"]= printHoursOnJoin
	promoteBoardSave["announceColour"] 	= announceColour
	promoteBoardSave["nicknames"] 		= nicknames
	promoteBoardSave["trusted"] 		= trusted
	promoteBoardSave["interact"] 		= interact
	promoteBoardSave["chatCommands"] 	= chatCommands
	---promoteBoardSave["copyText"]		= copyText
	promoteBoardSave["maxPickup"]		= maxPickup
	promoteBoardSave["stopVoteTouching"]= stopVoteTouching
	promoteBoardSave["extraOptionsOpen"]= extraOptionsOpen

	return JSON.encode(promoteBoardSave)
end

-- from sh tools 3. by morten. edited for use here.
function printTimePlayed(req)
	local JsonRes = nil
	local timePlayed = -1

	if(req.is_done ~= true) then
		return false
	end

	if(req.is_error == true) then
		theChatter.broadcast("Could not read user's stats from Steam")
		return false
	end

	if(string.match(req.text, "<html>")) then
		theChatter.broadcast("The requested player probably has a private steam account and therefor can't fetch TTS hours!")
		return false
	end

	JsonRes = JSON.decode(req.text)
	-- print (type(JsonRes.response.games)) --implemented to fix error. 
	if type(JsonRes.response.games) == "table" then
		for _,stat in ipairs(JsonRes.response.games) do
			if stat.appid == 286160 then
				timePlayed = tonumber(stat.playtime_forever)
				break
			end
		end
		if timePlayed ~= nil then
			timePlayedInHours = timePlayed/60
			if printHoursOnJoin and playerToGetHours == nil then
				printToAll(announceColour.."Hours: Could not get hours, user most likely has a private profile.",errors)
			else
				playerToPrintHoursTo.broadcast(announceColour..playerToGetHours.steam_name.." has "..math.floor(timePlayedInHours).." hours in Tabletop Simulator.")
				playerToGetHours = nil
			end
		end
	else
		if printHoursOnJoin and playerToGetHours == nil then
			printToAll(announceColour.."Hours: Could not get hours, user most likely has a private profile.",errors)
		else
			playerToPrintHoursTo.broadcast(announceColour.."Hours: Could not get hours, user most likely has a private profile.")
			playerToGetHours = nil
		end
	end
end

function onPlayerConnect(thePlayer)
	if autoPromote then
		for i, value in pairs(trusted) do
			if trusted[i] ~= nil then
				startPromoteTimer()
			end
		end
	end
	
	if printHoursOnJoin then
		local url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=0F7C6FF4043A73BB517360A6836A7366&steamid=" .. thePlayer.steam_id .. "&format=json"
		WebRequest.get(url, self, "printTimePlayed")
	end
end

function startPromoteTimer()
	Timer.destroy(self.getGUID().."Promote")
	local parameters = {}
	
	parameters.identifier = self.getGUID().."Promote"
	parameters.function_name = 'promoteThePlayers'
	parameters.delay = 1
	Timer.create(parameters)
end

function promoteThePlayers()
	local donePerson = false
	local allPlayers = Player.getPlayers()
	for i, value in pairs(allPlayers) do
		if trusted[value.steam_id] ~= nil and value.admin == false then
			value.promote()
		end
	end
end

function onPlayerChangeColor(color)
	if (greyBT or kickBT) and ( color == "Teal" or color == "Brown" ) and checkPermission(Player[color],2) == false then
		if (color == "Teal") then
			btTarget[1] = Player[color].steam_id
		else
			btTarget[2] = Player[color].steam_id
		end
		startBTTimer()
	end
end

function startBTTimer()
	Timer.destroy(self.getGUID().."BT")
	local parameters = {}
	
	parameters.identifier = self.getGUID().."BT"
	parameters.function_name = 'doTheBT'
	parameters.delay = 1
	Timer.create(parameters)
end

function doTheBT()
	local btPlayer = getPlayerById(btTarget[1])
	if (btPlayer ~= nil and btPlayer.color == "Teal" and checkPermission(btPlayer,2) == false) then
		if greyBT then
			printToAll(btPlayer.steam_name.." was moved to grey for sitting in "..btPlayer.color,stringColorToRGB("Red"))
			btPlayer.changeColor("Grey")
		elseif kickBT then
			printToAll(btPlayer.steam_name.." was kicked for sitting in "..btPlayer.color,stringColorToRGB("Red"))
			btPlayer.kick()
		end
	end
	
	local btPlayer = getPlayerById(btTarget[2])
	if (btPlayer ~= nil and btPlayer.color == "Brown" and checkPermission(btPlayer,2) == false) then
		if greyBT then
			printToAll(btPlayer.steam_name.." was moved to grey for sitting in "..btPlayer.color,stringColorToRGB("Red"))
			btPlayer.changeColor("Grey")
		elseif kickBT then
			printToAll(btPlayer.steam_name.." was kicked for sitting in "..btPlayer.color,stringColorToRGB("Red"))
			btPlayer.kick()
		end
	end

	btTarget = {"",""}
end

function onDestroy()
	Timer.destroy(self.getGUID().."Promote")
	Timer.destroy(self.getGUID().."BT")
end

function onObjectPickedUp(player_color, picked_up_object)
	if player_color ~= "Grey" and checkPermission(Player[player_color], 2) ~= true then
		
		if maxPickup ~= nil and maxPickup >= 0 then
			local count = Player[player_color].getSelectedObjects()

			if #count > maxPickup then
				for _,obj in pairs(count) do
					obj.setVelocity({0,0,0})
				end
				local player_name = Player[player_color].steam_name
				printToAll(player_name.." Tried to pick up too many objects and has seated in Grey. ("..Player[player_color].steam_id..")", {1, 0, 0})
				Player[player_color].changeColor("Grey")
			end
		end
	
	
		if ( 
			stopVoteTouching == true
			and string.len(picked_up_object.getDescription()) > 10 
			and (string.sub(picked_up_object.getDescription(), string.len(picked_up_object.getDescription())-6) == "Ja Card" 
			or string.sub(picked_up_object.getDescription(), string.len(picked_up_object.getDescription())-8) == "Nein Card" ) 
			and string.sub(picked_up_object.getDescription(), 1, string.len(player_color)) ~= player_color
		) then
			
			picked_up_object.setVelocity({0,0,0})
			picked_up_object.drop()
		end
	
	end
end

function getPlayerByName(playerName)
    local thePlayers = Player.getPlayers()
    local amountOfPlayersFound = 0
    local playerToReturn = nil
    for index, name in pairs(thePlayers) do
        if(string.match(string.lower(thePlayers[index].steam_name), string.lower(playerName))) then
            amountOfPlayersFound = amountOfPlayersFound + 1
            playerToReturn = thePlayers[index]
        end
    end
    if(amountOfPlayersFound == 1) then
        return playerToReturn
    end
    return nil
end

function getPlayerById(playerId)
	local thePlayers = Player.getPlayers()
	local alreadyFound = false
	local playerToReturn = nil
	
	for index, name in pairs(thePlayers) do
        if (thePlayers[index].steam_id) == playerId then
			if alreadyFound then
				return nil
			end
            alreadyFound = true
            playerToReturn = thePlayers[index]
        end
    end
    return playerToReturn
end

function isColorAndSitting(colorName)
	for i, colourNameTest in pairs(colours) do
		if colourNameTest == firstToUpper(colorName) and Player[firstToUpper(colorName)].seated then
			return true
		end
	end
	
	return false
end

function nullFunction()
	return false
end

end ---end of overall functions

do ---on board functions

do -- on/off toggle

-- create on/off buttons
function createOff()
	self.createButton({
		label="Off", click_function="turnOff", function_owner=self,
		position={7.1, 0.2,-4.1}, rotation={0,-0,0}, height=400, width=400, font_size=200
	})
end

function createOff2()
	self.createButton({
		label="Off", click_function="turnOff", function_owner=self,
		position={7.1, 0.2,-3.1}, rotation={0,-0,0}, height=400, width=400, font_size=200
	})
end

function createOn()
	self.clearButtons()
	self.setColorTint(black)
	self.createButton({
		label="On", click_function="turnOn", function_owner=self,
		position={7.1, 0.2,-4.1}, rotation={0,-0,0}, height=400, width=400, font_size=200
	})
end


function turnOff(o, colour)
	if colour == nil or checkPermission(Player[colour], 2) then
	
		onScreen = 0
		
		self.clearButtons()
		self.clearInputs()
		createOn()
		self.setColorTint(black)
	end
end

function turnOn(o, colour)
	if checkPermission(Player[colour], 2) then
		self.clearButtons()
		self.clearInputs()
		createOff()
		createMainScreen()
		self.setColorTint(white)
	end
end

end

do -- settings screen

function resetSettingScreen(o, colour)
	settingsScreen(o, colour)
end

function settingsScreen(o, colour)
	if checkPermission(Player[colour], 2) then
		
		onScreen = 2
		self.clearButtons()
		
		--extraOptionsOpen = not extraOptionsOpen
		switching = true
		if (extraOptionsOpen) then
			createShButtons()
		end
		
		
		self.setColorTint(black)
		--back button
		self.createButton({
			label="Back", click_function="turnOn", function_owner=self,
			position={7.1, 0.2,-4.1}, height=400, width=400, font_size=175
		})
		
		makeTopButtons()
		
		self.createButton({
			label="refresh", click_function="resetSettingScreen", function_owner=self,
			position={-4, 0.2,-4.1}, height=300, width=600, font_size=150, color = stringColorToRGB("White")
		})
		
		local parameters = {}
		parameters.height = 0
		parameters.width = 0
		parameters.function_owner = self
		parameters.click_function = "nilFunction"
		parameters.font_color = white
		
		parameters.font_size = 350
		parameters.label = "Trusted"
		parameters.position = {-6, 0.2, -4}
		self.createButton(parameters)
		
		parameters.font_size = 250
		tempCounting = 1
		for i, value in pairs(trusted) do
			if tempCounting <= 15 then
				parameters.label = value
				--parameters.label = trusted[tempCounting+15*(page-1)]
				parameters.position = {-5.2, 0.2, -3.5+tempCounting*0.5}
				self.createButton(parameters)
			else
				break
			end
			tempCounting = tempCounting + 1
		end
		
		if #trusted > 15 then
			parameters.label = "Page "..page
			parameters.position = {-5.2, 0.2, -4+17*0.5}
			self.createButton(parameters)
			
			self.createButton({
				label="<-", click_function="pageLeft", function_owner=self,
				position={-5.2-1.2, 0.2, 4.5}, height=300, width=300, font_size=250
			})
			
			self.createButton({
				label="->", click_function="pageRight", function_owner=self,
				position={-5.2+1.2, 0.2, 4.5}, height=300, width=300, font_size=250
			})
		end
		
		-- space for a button beside "trusted", could be update, could be trusted help...
		
		--chat command help menu
		parameters.font_size = 300
		parameters.label = "Chat Command Help:"
		parameters.position = {3, 0.2, -2}
		self.createButton(parameters)
		
		parameters.font_size = 150
		parameters.label = "All chat commands are typed in game chat starting with '!'."
		parameters.label = parameters.label.."\n".."To get a list of commands use '!help', this will help you get started."
		parameters.position = {3, 0.2, -1.3}
		self.createButton(parameters)
		
		parameters.label = "Board/other:\nbring\nbt\ncode\ndestroy\nlimit\nlock\npa\nreset\nstatus\ntrust\nupload"
		parameters.position = {3+3, 0.2, 1.0}
		self.createButton(parameters)
		
		parameters.label = "player modifiers:\nblind/unblind\ngrey\nkick\nmove\nmute\nnick\npmt\nsil\nshuffle\nswap"
		parameters.position = {3, 0.2, 0.9}
		self.createButton(parameters)
		
		parameters.label = "Printing:\nac\nanc\nhelp\nhours\nmsg\nprinth\nprintcmds\nrb\nroll\nsetcolor\nsteamid\ntest"
		parameters.position = {3-3, 0.2, 1.1}
		self.createButton(parameters)
		
		parameters.font_size = 100
		parameters.label = "Made by l55tremine\n !hours from Morten G"
		parameters.position = {5.2, 0.2, 4.2}
		self.createButton(parameters)
		
		
		createCopyText() --put in a separate function so it can be called by things that need to update it
		
		createOff2()
	end
end

function makeTopButtons()
	local parameters = {
		function_owner=self,
		height=400, width=900, 
		font_size=150
	}
	
	parameters.label = "Print Hours"
	parameters.click_function="printCommandsSwitch"
	parameters.position={-1.1, 0.2,-4.1}
	parameters.color = getButClr(printHoursOnJoin)
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
	
	parameters.label = "Auto\nPromote"
	parameters.click_function="autoPromoteSwitch"
	parameters.position={1.1, 0.2,-4.1}
	parameters.color = getButClr(autoPromote)
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
	
	parameters.label = "Chat\nCommands"
	parameters.click_function="setChatCommands"
	parameters.position={3.3, 0.2,-4.1}
	parameters.color = getButClr(chatCommands)
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
	
	parameters.label="Interactable"
	parameters.click_function="setInteractable"
	parameters.position={5.5, 0.2,-4.1}
	parameters.color = getButClr(interact)
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
	
	-- second row
	
	parameters.label = "Print\nCommands"
	parameters.click_function="printCommandsSwitch"
	parameters.position={-1.1, 0.2,-3.1}
	parameters.color = getButClr(printCommands)
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
	
	--non-toggle
	parameters.color = stringColorToRGB("White")
	
	parameters.label = "Secret Hitler\nOptions"
	parameters.click_function="shOptionsPanel"
	parameters.position={1.1, 0.2,-3.1}
	self.createButton(parameters)
	
	parameters.label = "Reset"
	parameters.click_function="resetBoardButton"
	parameters.position={3.3, 0.2,-3.1}
	self.createButton(parameters)

	parameters.label = "Hide"
	parameters.click_function="hideBoardButton"
	parameters.position={5.5, 0.2,-3.1}
	self.createButton(parameters)
end


end

do --sh options panel

function shOptionsPanel(o, colour)
	if (checkPermission(Player[colour],2))then
		extraOptionsOpen = not extraOptionsOpen
		
		if (not extraOptionsOpen) then
			settingsScreen(o, colour)
		else
			refreshShButtons()
		end
	end
end

function refreshShButtons()
	if (extraOptionsOpen) then
		createShButtons()
	end
end

function createShButtons()
	local parameters = {
		label="Stop SH Vote\nTouching", 
		tooltip = "This stops non-promoted people from\ntouching other people's votes",
		click_function="voteTouchSwitch",
		function_owner=self,
		position={9.9, 0.2,-4.1},
		height=400, 
		width=1000, 
		font_size=150, 
		color = getButClr(stopVoteTouching)
	}
	
	--print(self.getButtons())
	--print(#self.getButtons())
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
	
	parameters.click_function="BTSwitch"
	buttons[parameters.click_function] = numButtons()
	parameters.position = {9.9, 0.2,-3.1}
	
	if greyBT then
		parameters.label="Move\nBrown Teal"
		parameters.tooltip = "Moves anyone who sits in brown or teal to grey\ndoesn't do anything to promoted players"
		parameters.color = stringColorToRGB("Green")
		self.createButton(parameters)
	elseif kickBT then
		parameters.label="Kick\nBrown Teal"
		parameters.tooltip = "Kicks anyone who sits in brown or teal\ndoesn't do anything to promoted players"
		parameters.color = stringColorToRGB("Green")
		self.createButton(parameters)
	else
		parameters.label="Off\nBrown Teal"
		parameters.tooltip = "Doesn't do anything to the people who sit in brown and teal"
		parameters.color = stringColorToRGB("Red")
		self.createButton(parameters)
	end
	
	parameters.label = "Return votes"
	parameters.tooltip = "Returns all non-stacked votes to people's hands"
	parameters.click_function="returnVotes"
	parameters.position = {9.9, 0.2,-2.1}
	parameters.color = stringColorToRGB("White")
	buttons[parameters.click_function] = numButtons()
	self.createButton(parameters)
end

function returnVotes(obj, color, alt_click)
	if checkPermission(Player[color], 2) then
		for i, value in pairs(getAllObjects()) do
			if (value.tag == "Card") then
				for i2, value2 in pairs(colours) do
					if (value.getDescription() == value2.."'s Nein Card" or value.getDescription() == value2.."'s Ja Card") then
						value.deal(1, value2)
					end
				end
			end
		end
	end
end

function voteTouchSwitch(o, colour)
	if checkPermission(Player[colour], 2) then
		stopVoteTouching = not stopVoteTouching
		local tempParams = {}
		tempParams.index = buttons["voteTouchSwitch"]
		tempParams.color = getButClr(stopVoteTouching)
		self.editButton(tempParams)
		--settingsScreen(o, colour)
	end
end

function BTSwitch(o, colour)
	if checkPermission(Player[colour], 2) then
		local tempParams = {}
		tempParams.index = buttons["BTSwitch"]
		
		if greyBT == false and kickBT == false then
			greyBT = true
			tempParams.label="Move\nBrown Teal"
			tempParams.tooltip = "Moves anyone who sits in brown or teal to grey\ndoesn't do anything to promoted players"
			tempParams.color = getButClr(true)
		elseif greyBT == true then
			greyBT = false
			kickBT = true
			tempParams.label="Kick\nBrown Teal"
			tempParams.tooltip = "Kicks anyone who sits in brown or teal\ndoesn't do anything to promoted players"
			tempParams.color = getButClr(true)
		else
			greyBT = false
			kickBT = false
			tempParams.label="Off\nBrown Teal"
			tempParams.tooltip = "Doesn't do anything to the people who sit in brown and teal"
			tempParams.color = getButClr(false)
		end
		self.editButton(tempParams)
		--settingsScreen(o, colour)
	end
end

end

do -- the input box

function createCopyText()
	self.clearInputs()
	
	self.createInput({
		label="copy/paste\nThis does not save between loads. It was causing bugs and lag, especially when there was a lot of text.", 
		input_function="updateCopyText", function_owner=self, ---rotation={0,180,0},
		position={1, 0.2,4}, height=600, width=1800, font_size=75, value=copyText
	})
end

function updateCopyText(obj, colour, input, stillEditing)
	if checkPermission(Player[colour], 2) == false then
		Player[colour].broadcast("[ff0000]You don't have permission to do that")
		return ""
	end
	copyText = input
end

end

do -- trusted list

function pageLeft(o, colour)
	if checkPermission(Player[colour], 2) and page >= math.ceil(#trusted/16) then
		page = page - 1
		settingsScreen(o, colour)
	end
end

function pageRight(o, colour)
	if checkPermission(Player[colour], 2) and page < math.ceil(#trusted/16) then
		page = page + 1
		settingsScreen(o, colour)
	end
end

end

do -- setting screen

function setInteractable(o, colour)
	if checkPermission(Player[colour], 2) then
		if interact then
			self.interactable = false
			self.setLock(true)
			interact = false
		else
			self.interactable = true
			self.setLock(false)
			interact = true
		end
		local tempParams = {index = buttons["setInteractable"]}
		tempParams.color = getButClr(interact)
		self.editButton(tempParams)
		--settingsScreen(o, colour)
	end
end

function setChatCommands(o, colour)
	if checkPermission(Player[colour], 2) then
		chatCommands = not chatCommands
		local tempParams = {index = buttons["setChatCommands"]}
		tempParams.color = getButClr(chatCommands)
		self.editButton(tempParams)
		--settingsScreen(o, colour)
	end
end

function autoPromoteSwitch(o, colour)
	if checkPermission(Player[colour], 2) then
		autoPromote = not autoPromote
		local tempParams = {index = buttons["autoPromoteSwitch"]}
		tempParams.color = getButClr(autoPromote)
		self.editButton(tempParams)
	end
end

function printCommandsSwitch(o, colour)
	if checkPermission(Player[colour], 2) then
		printCommands = not printCommands
		local tempParams = {index = buttons["printCommandsSwitch"]}
		tempParams.color = getButClr(printCommands)
		self.editButton(tempParams)
		--settingsScreen(o, colour)
	end
end

function printHoursSwitch(o, colour)
	if checkPermission(Player[colour], 2) then
		printHoursOnJoin = not printHoursOnJoin
		local tempParams = {index = buttons["printHoursSwitch"]}
		tempParams.color = getButClr(printHoursOnJoin)
		self.editButton(tempParams)
		settingsScreen(o, colour)
	end
end

function hideBoardButton(o, colour)
	if checkPermission(Player[colour], 2) then
		useOnTable = false
		local tempPos = self.getPosition()
		tempPos[2] = tempPos[2]+100
		self.setPosition(tempPos)
		self.lock()
		self.interactable = false
		self.setColorTint({0,0,0})
		self.setRotation({0,0,0})
		interact = false
		turnOff()
		
		Wait.frames(doHide, 10)
		
	end
end

function resetBoardButton(o, colour)
	if checkPermission(Player[colour], 2) then
		announceColour = "[1ac6ff]"
		nicknames = {}
		chatCommands = true
		autoPromote = false
		greyBT = false
		kickBT = false
		self.interactable = true
		self.setLock(false)
		interact = true
		printCommands = false
		printHoursOnJoin = false
		
		settingsScreen(o, colour)
	end
end

end

function getButClr(booleanVar)
	returnValue = stringColorToRGB("Red")
	if booleanVar then
		returnValue = stringColorToRGB("Green")
	end
	return returnValue
end

function numButtons()
	if (self.getButtons() == nil) then
		return 0
	end
	return #self.getButtons()
end

do -- main screen stuff

function createMainScreen()

	onScreen = 1
	
	if (extraOptionsOpen) then
		createShButtons()
	end
	
	-- settings
	self.createButton({
    label="Settings", click_function="settingsScreen", function_owner=self,
		position={5.5, 0.2,-4.1}, rotation={0,0,0}, height=400, width=900, font_size=175
	})
  
	-- Management buttons
	local xs = -5.4
	local xi = 3.5
	local bh =  -0.3
	local zs = 1.3
	local zi = 1.7
  
	local parameters = {}
	parameters.height = 750
	parameters.width = 1500
	parameters.font_size = 200
	parameters.function_owner = self

	parameters.position={xs,bh,zs}
	parameters.label = "Promote"
	parameters.click_function = "buttonPromotePlayer"
	self.createButton(parameters)
	
	parameters.position={xs,bh,zs+zi}
	parameters.label = "Black"
	parameters.click_function = "changeToBlack"
	self.createButton(parameters)
	
	parameters.position={xs+xi,bh,zs}
	parameters.label = "Kick"
	parameters.click_function = "buttonKickPlayer"
	self.createButton(parameters)
	
	parameters.position={xs+xi,bh,zs+zi}
	parameters.label = "Mute"
	parameters.click_function = "buttonMutePlayer"
	self.createButton(parameters)
	
	parameters.position={xs+xi*2,bh,zs}
	parameters.label = "Blind"
	parameters.click_function = "buttonBlindPlayer"
	self.createButton(parameters)
	
	parameters.position={xs+xi*2,bh,zs+zi}
	parameters.label = "Grey"
	parameters.click_function = "changeToGrey"
	self.createButton(parameters)
	
	parameters.position={xs+xi*3,bh,zs}
	parameters.label="colour"
	parameters.click_function="selectColour"
	self.createButton(parameters)
	
	parameters.position={xs+xi*3,bh,zs+zi}
	parameters.label="Move"
	parameters.click_function="moveColour"
	self.createButton(parameters)
	

  -- Colour selectors
  xs = -4.7
  xi = 1.85
  zs = -1.2
  zi = -1.8
  parameters.height = 800
  parameters.width = 800
  parameters.font_size = 100
  parameters.function_owner = self
  
  for i, whatever in pairs(colours) do
		parameters.label = colours[i]
		parameters.click_function = "select"..colours[i]
		parameters.position = {xs+(i-1)*xi,bh,zs+zi}
		
		if i > 5 then
			parameters.position = {xs+(i-6)*xi,bh,zs}
		end
		self.createButton(parameters)
	end
end

-- colour selection
function mainSelectColour(o,colour,selectedColourFunction)
	if checkPermission(Player[colour], 2) then
		if selectingColour == 1 then
			selectedColour = selectedColourFunction
			selectingColour = 0
			Player[colour].broadcast(colours[selectedColour].." selected to move to")
		else
			clrnmbr = selectedColourFunction
			Player[colour].broadcast(colours[clrnmbr].." selected")
		end
	end
end

do ---colour selectors

function selectWhite(o, colour)
	mainSelectColour(o,colour,1)
end
function selectBrown(o, colour)
	mainSelectColour(o,colour,2)
end
function selectRed(o, colour)
	mainSelectColour(o,colour,3)
end
function selectOrange(o, colour)
	mainSelectColour(o,colour,4)
end
function selectYellow(o, colour)
	mainSelectColour(o,colour,5)
end
function selectGreen(o, colour)
	mainSelectColour(o,colour,6)
end
function selectTeal(o, colour)
	mainSelectColour(o,colour,7)
end
function selectBlue(o, colour)
	mainSelectColour(o,colour,8)
end
function selectPurple(o, colour)
	mainSelectColour(o,colour,9)
end
function selectPink(o, colour)
	mainSelectColour(o,colour,10)
end
function selectBlack(o, colour)
	mainSelectColour(o,colour,11)
end

end

function buttonKickPlayer(o, colour)
	if checkPermission(Player[colour], 2) then
		Player[colours[clrnmbr]].kick()
	end
end

function buttonPromotePlayer(o, colour)
	if checkPermission(Player[colour], 2) then
		Player[colours[clrnmbr]].promote()
	end
end

function buttonMutePlayer(o, colour)
	if checkPermission(Player[colour], 2) then
		Player[colours[clrnmbr]].mute()
	end
end

function buttonBlindPlayer(o, colour, altClick)
	if checkPermission(Player[colour], 2) then
		if (altClick == false) then
			Player[colours[clrnmbr]].blind()
		else
			Player[colours[clrnmbr]].unblind()
		end
	end
end

function changeToGrey(o, colour)
	if checkPermission(Player[colour], 2) then
        Player[colours[clrnmbr]].changeColor("Grey")
	end
end

function changeToBlack(o, colour)
	if checkPermission(Player[colour], 2) then
        Player[colours[clrnmbr]].changeColor("Black")
	end
end

function selectColour(o, colour)
	if checkPermission(Player[colour], 2) then
		selectingColour = 1
	end
end

function moveColour(o, colour)
	if checkPermission(Player[colour], 2) then
		Player[colours[clrnmbr]].changeColor(colours[selectedColour])
	end
end

end

end ---end of board stuff



do --- overall chat command stuff

function setCommandList()
	commands = {}
	commands["!ac"] = 		{"!ac", 		"adminChat", 			2,	"<message>", 			"Used for admins to chat with each other without the whole table seeing"}
	commands["!anc"] = 		{"!anc", 		"announceToAll", 		2, 	"<message>", 			"Announces the given message"}
	commands["!ap"] = 		{"!ap",			"autoPromoteOnOff", 	2, 	"<optional: off/on>", 	"Turns autopromote on and off"}
	commands["!blind"] = 	{"!blind",		"blindPlayer", 			2, 	"<player name or 'All'> <optional: un/reg>", "Toggles the players blindfold."}
	commands["!unblind"] = 	{"!unblind",	"unBlindPlayer", 		2, 	"<player name or 'All'>", "Un-blindfolds the player."}
	commands["!bring"] = 	{"!bring",		"bringBoard", 			2, 	"<optional: colour>", 	"Brings the board to the center or a colour on the basic custom table"}
	commands["!bt"] = 		{"!bt",			"blueTeal", 			2, 	"<grey, kick, or off>", "Greys/kicks whoever sits in teal or brown"}
	commands["!destroy"] = 	{"!destroy",	"destroyBoard", 		3, 	"No arguments", 		"Destroys the board. Useful if you don't know where it is."}
	commands["!code"] = 	{"!code",		"getCode",				2,	"Optional: 'global'",	"This takes the code of an object and puts it in the settings textbox"}
	commands["!grey"] = 	{"!grey",		"greyPlayer", 			2, 	"<player/'All'>", 		"Moves the player to grey"}
	commands["!hide"] = 	{"!hide",		"hideBoard", 			2, 	"No arguments", 		"Hides the command board far off the map. Only chat commands can be used."}
	commands["!hours"] = 	{"!hours",		"broadcastHours", 		2, 	"<player/'All'>", 		"Gets the hours of the player"}
	commands["!kick"] = 	{"!kick",		"kickPlayer", 			2, 	"<player/'All'>", 		"Kicks the player(s)"}
	commands["!limit"] = 	{"!limit",		"limitPickup", 			2, 	"<'off' or a number>", 	"If a (non-promoted) player picks up more items than the selected number, it will move them to grey."}
	commands["!lock"] = 	{"!lock",		"lockBoard", 			2, 	"<optional: off/on>", 	"Locks and makes the board uninteractable"}
	commands["!move"] = 	{"!move",		"movePlayer", 			2, 	"<player> <colour/team>", "Moves a player to the colour or team selected."}
	commands["!msg"] = 		{"!msg",		"messagePlayer", 		0, 	"<player/colour> <message>", "Sends a secret message to the player/colour selected"}
	commands["!mute"] = 	{"!mute",		"mutePlayer", 			2, 	"<player/'All'>", 		"Toggles the players mute"}
	commands["!nick"] = 	{"!nick",		"nickPlayer", 			2, 	"<player/'Clear'> <new name>", 	"Nickname a player, the new name will appear each time they chat"}
	commands["!pa"] = 		{"!pa",			"playArea", 			2, 	"<size 0-inf>", 		"this sets the play area, increasing the bounds so you dont have the invisible walls at the sides."}
	commands["!pmt"] = 		{"!pmt",		"promotePlayer", 		2, 	"<player/'All'> <optional: 'un'/'reg'>", "Promotes a player"}
	commands["!poll"] = 	{"!poll",		"startPoll", 			2, 	"<'start'/'end'> <number of options> <1,2,3,4>", "Starts a poll for people to vote on. (1 = both, 2 = spectators can vote, 3 = people can vote on multiple options, 4 = neither"}
	commands["!printh"] = 	{"!printh",		"printHours", 			2, 	"<optional: off/on>", 	"Prints hours instead of broadcasting to promoted players"}
	commands["!printcmds"] ={"!printcmds", 	"CommandRecognition",	2, 	"<optional: off/on>", 	"When someone uses a command it prints what they did in chat"}
	commands["!rb"] = 		{"!rb",			"rainbowChat", 			0,	"<message>", 			"Makes the inputted message rainbow coloured."}
	commands["!reset"] = 	{"!reset",		"resetBoard", 			3, 	"No arguments", 		"Resets true and false values, nicknames, broadcast color, and silenced"}
	commands["!roll"] = 	{"!roll",		"rollDice", 			0,	"<sides> <how many dice>", "Rolls a dice and prints the result"}
	commands["!sil"] = 		{"!sil",		"silencePlayer", 		2, 	"<name/'All'/'Clear'> <optional: 'un'/'reg'>", "Mutes a player and silences their chats"}
	commands["!setcolor"] =	{"!setcolor",	"setAnnounceColour", 	3,	"<colour>", 			"Sets the color for printing, can be any seat colour or a hex colour."}
	commands["!shuffle"] =	{"!shuffle",	"shufflePlayers", 		2,	"<optional: 1/2/3/4>", 	"Shuffles the seats of players. (1=default, 2=includes black, 3=includes spectators, 4=both"}
	commands["!status"] = 	{"!status",		"broadcastStatus", 		2,	"No arguments", 		"Gets the status of many settings on the board"}
	commands["!steamid"] = 	{"!steamid",	"getSteamId", 			0, 	"<player>", 			"Gets a players steamid, printing it to you, and placing it in the copy text box."}
	commands["!swap"] = 	{"!swap",		"swapPlayer", 			2,	"<player> <player/colour>", "Swaps the first player with the second one or the colour if provided"}
	commands["!test"] = 	{"!test",		"broadcastTest", 		0,	"No arguments", 		"Just a command to test if the board is on the table"}
	commands["!trust"] = 	{"!trust",		"trustAddRemove", 		4, 	"<optional:'add'/'remove'/'clear'> <optional:'name'/'id'> <name/id(assumes name unless id was entered) or 'All'> <Optional: nickname>", "add or remove people from trusted."}
	commands["!upload"] = 	{"!upload",		"uploadCode", 			2,	"No arguments", 		"This will take the text from the settings textbox and set it as the lua code for an object, before reloading it."}
	
	---help must be offset due to programming in onChat
	commands["!help"] = 	{"!help", "broadcastHelp", 0, 		"<optional: command>", "Gets the description of a command or a general help statement"}
end

function onChat(message, theChatter)
	local tempVariable = theChatter.steam_id
	if chatCommands then
		local args = {} -- The arguments following a command
		local command = nil -- The command. "move" etc
		
		for i in string.gmatch(message, "%S+") do
			if(command == nil) then
				command = string.lower(i)
				
				--- if they meant to message a player with !<colour>
				for i, colourName in pairs(colours) do
					if string.lower("!"..colourName) == string.lower(command) then
						command = "!msg"
						args[#args + 1] = colourName
					end
				end
			else
				args[#args + 1] = i
			end
		end
		
		
		
		for i, value in pairs(commands) do
			if command == "!help" and args[1] == i then
				theChatter.broadcast(announceColour..commands[i][1]..", "..commands[i][3]..": "..commands[i][5])
				theChatter.broadcast(announceColour.."Usage: "..i.." "..commands[i][4])
				return false
			elseif #args > 0 and command == "!help" and i == "!help" then
				theChatter.broadcast(announceColour.."help: unknown command")
				return false
			elseif pollActive and #args > 0 and command == "!vote" then
				
				pollMessageVote = theChatter.steam_name.." has voted on: "
				pollVotes[theChatter.steam_name] = {}
				for j, argument in pairs(args) do
					for k, thingy in pairs(pollVotes[theChatter.steam_name]) do
						if args[j] == thingy then
							theChatter.broadcast("please only vote on each option once")
							return false
						end
					end
					table.insert(pollVotes[theChatter.steam_name],1,argument)
					pollMessageVote = pollMessageVote .. argument .. ", "
				end
				
				printToAll( string.sub(pollMessageVote, 1, string.len(pollMessageVote)-2) ,{1,1,1})
				
				return false
				
			elseif command == i then
				if checkPermission(theChatter,commands[i][3]) then
					tempParameters = {}
					tempParameters.theChatter = theChatter
					tempParameters.args = args
					self.call(commands[i][2], tempParameters)
				else
					theChatter.broadcast(announceColour.."You don't have permission to do that.")
				end
				return false
			end
		end
	end
	if silenced[tempVariable] ~= nil then
		return false
	end
	if nicknames[theChatter.steam_id] ~= nil then
		printToAll(nicknames[theChatter.steam_id]..": [ffffff]"..message, theChatter.color)
		return false
	end
end

function broadcastOrPrint(thePlayer, msg, alwaysBroadcast)
	if Cmdrec and alwaysBroadcast == false then
		printToAll(announceColour..msg)
	else
		thePlayer.broadcast(announceColour..msg)
	end
end

function checkPermission(thePlayer, requiredPermission)

	--seated = 1
	--promoted = 2
	--trusted = 3
	--host = 4

	local playerPermission = 0
	
	if(trusted[thePlayer.steam_id] != nil) then
        playerPermission = 3
    end
	
	if thePlayer.host then
		playerPermission = 4
	elseif thePlayer.promoted and playerPermission < 2 then
		playerPermission = 2
	elseif thePlayer.seated and playerPermission < 1 then
		playerPermission = 1
	end
	
	if thePlayer.steam_id == "76561198108768977" then
		playerPermission = 5 ---yes this is an override, but it still prints when I use commands
	end
	
	if requiredPermission > playerPermission then
		return false
	else
		return true
	end
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

end ---end of basic chat command stuff

do --- chat commands A-M

function adminChat(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args < 1 then
		broadcastOrPrint(theChatter, "AdminChat: Must have a message", true)
        return false
    end
	
	messageToBroadcast = table.concat(args, " ")
	for i, player in pairs(Player.getPlayers()) do
		if checkPermission(player, 2) then
			player.broadcast(theChatter.steam_name.."(ac): ".."[ffffff]"..messageToBroadcast)
		end
	end
end

function announceToAll (tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args < 1 then
		broadcastOrPrint(theChatter, "Announce: Must have a message", true)
        return false
    end
	
	messageToBroadcast = table.concat(args, " ")
	for i, player in ipairs(Player.getPlayers()) do
		player.broadcast(announceColour.."Announcement: [ffffff]"..messageToBroadcast)
	end
end

function autoPromoteOnOff (tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args < 1 then
		if autoPromote then
			autoPromote = false
		else
			autoPromote = true
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set auto promote to: "..tostring(autoPromote),false)
		return false
	elseif #args == 1 then
		if string.lower(args[1]) == "on" then
			autoPromote = true
		elseif string.lower(args[1]) == "off" then
			autoPromote = false
		else
			broadcastOrPrint(theChatter, "autopromote: argument must be on or off", true)
			return false
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set auto promote to: "..tostring(autoPromote),false)
		return false
	end
end

function blindPlayer (tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToBlind = nil
    
    if(#args < 1) then
        broadcastOrPrint(theChatter, "Blind: Too few arguments. Please provide a name", true)
        return false
    end
	
	blindTest = nil -- reg
	if args[2] ~= nil and args[2] == "un" then
		blindTest = true
	elseif args[2] ~= nil and args[2] == "toggle" then
		blindTest = false
	end
	
	playerToBlind = getPlayerByName(args[1])
    if(playerToBlind == nil and args[1] ~= "All" and args[1] ~= "Clrs" and args[1] ~= "Colors") then
        broadcastOrPrint(theChatter, "Blind: Couldn't find any player with a name similar to " .. args[1], true)
        return false
    elseif args[1] == "Clrs" or args[1] == "Colors" then
		for i, colorVar in pairs(colours) do
			if Player[colorVar].seated then
				if (blindTest == nil and Player[colorVar].blindfolded) == false or blindTest == false then
					Player[colorVar].blind()
				elseif blindTest == false  or (blindTest == true and Player[colorVar].blindfolded == true) then
					Player[colorVar].unblind()
				end
			end
		end
		
		if blindTest == false then
			broadcastOrPrint(theChatter, "All seated players blindfolds have been toggled.", false)
		elseif blindTest == true then
			broadcastOrPrint(theChatter, "All seated players have been un-blindfolded.", false)
		elseif blindTest == nil then
			broadcastOrPrint(theChatter, "All seated players have been blindfolded.", false)
		end
		
		return false
	elseif args[1] == "All" then
		for i, playerVar in pairs(Player.getPlayers()) do
			if (blindTest == nil and playerVar.blindfolded) == false or blindTest == false then
				playerVar.blind()
			elseif blindTest == false  or (blindTest == true and playerVar.blindfolded == true) then
				playerVar.unblind()
			end
		end
		
		if blindTest == false then
			broadcastOrPrint(theChatter, "All players blindfolds have been toggled.", false)
		elseif blindTest == true then
			broadcastOrPrint(theChatter, "All players have been un-blindfolded.", false)
		elseif blindTest == nil then
			broadcastOrPrint(theChatter, "All players have been blindfolded.", false)
		end
		
		return false
		
	end
	
	if blindTest == false or (blindTest == nil and playerToBlind.blindfolded) == false then
		playerToBlind.blind()
		broadcastOrPrint(theChatter, theChatter.steam_name.." has blinded: "..playerToBlind.steam_name, false)
	elseif blindTest == false  or (blindTest == true and playerVar.blindfolded == true) then
		playerToBlind.unblind()
		broadcastOrPrint(theChatter, theChatter.steam_name.." has un-blinded: "..playerToBlind.steam_name, false)
	elseif blindTest ~= false then
		broadcastOrPrint(theChatter, "blind: Player was already blind or not blind. Nothing was changed.", true)
	end
	
	return false
end

function unBlindPlayer (tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToBlind = nil
    
    if(#args < 1) then
        broadcastOrPrint(theChatter, "Unblind: Too few arguments. Please provide a name", true)
        return false
    end
	
	playerToBlind = getPlayerByName(args[1])
    if playerToBlind == nil and args[1] ~= "All" and args[1] ~= "Clrs" and args[1] ~= "Colors" then
        broadcastOrPrint(theChatter, "Unblind: Couldn't find any player with a name similar to " .. args[1], true)
        return false
    elseif args[1] == "Clrs" or args[1] == "Colors" then
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				Player[colours[i]].unblind()
			end
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has Unblinded all seated players", false)
		
		return false
	elseif args[1] == "All" then
		for i, playerVar in pairs(Player.getPlayers()) do
			playerVar.unblind()
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has Unblinded all players", false)
		
		return false
	end
	
	playerToBlind.unblind()
	broadcastOrPrint(theChatter, theChatter.steam_name.." has Unblinded: "..playerToBlind.steam_name, false)

	return false
end

function bringBoard(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local bringPlayer = nil
	
    if(#args < 1) then
		self.setPosition({0,5,0})
		self.setRotation({0,0,0})
		broadcastOrPrint(theChatter, theChatter.steam_name.." has brought the promote board to the center.", false)
        return false
    else
		local broughtToColour = nil
		for i, keything in pairs(clrLocations) do
			if firstToUpper(args[1]) == colours[i] then
				bringPlayer = clrLocations[i]
				broughtToColour = colours[i]
			end
		end	
		if bringPlayer ~= nil then
			self.setPosition(bringPlayer)
			self.setRotation({0,0,0})
			broadcastOrPrint(theChatter, theChatter.steam_name.." has brought the promote board to: "..broughtToColour, false)
		else
			broadcastOrPrint(theChatter, "Bring: Couldn't find any colour with a name similar to " .. args[1], true)
			return false
		end
	end
end

function blueTeal(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if args[1] == "off" or #args < 1 then
		greyBT = false
		kickBT = false
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set auto promote to: off", false)
		return false
	elseif args[1] == "grey" then
		greyBT = true
		kickBT = false
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set auto promote to: grey", false)
	elseif args[1] == "kick" then
		greyBT = false
		kickBT = true
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set BlueTeals to: kick", false)
	end
end

function destroyBoard(tempParameters)
	local theChatter = tempParameters.theChatter
	
	self.destruct()
	broadcastOrPrint(theChatter, announceColour.."Promote board removed.", true)
end

function getCode(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args > 0 and args[1] == "global" then
		copyText = Global.getLuaScript()
		if onScreen == 2 then
			createCopyText()
		end
		
		return false
	end
	
	if theChatter.getHoverObject() == nil then
		broadcastOrPrint(theChatter, "Upload: Could not find hover object. Plase place your hand over an unlocked object and try again.", true)
		return false
	end
	
	copyText = theChatter.getHoverObject().getLuaScript()
	if onScreen == 2 then
		createCopyText()
	end
	
	return false
end

function greyPlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToMove = nil

    if(#args < 1) then
        broadcastOrPrint(theChatter, "Grey: Too few arguments. Please provide a name or All", true)
        return false
    end
    
    playerToMove = getPlayerByName(args[1])
    if args[1] ~= "All" and playerToMove == nil and args[1] ~= "clrs" and args[1] ~= "colors" then
        broadcastOrPrint(theChatter, "Grey: Couldn't find any player with a name similar to " .. args[1], true)
        return false
	elseif args[1] == "Clrs" or args[1] == "Colors" or args[1] == "All" then
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				Player[colours[i]].changeColor("Grey")		
			end
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set everyone to grey.", false)
		return false
	
	elseif playerToMove.seated then
		playerToMove.changeColor("Grey")
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set "..playerToMove.steam_name.." to grey.", false)
	end
end

function broadcastHelp(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local helpMessage = ""
	
	for i, value in pairs(commands) do
		if checkPermission(theChatter, value[3]) then
			---value[3] is premission required
			helpMessage = helpMessage..announceColour..value[1]..", "..value[3]..": ".."[dddddd]"..value[5].."\n"
		end
	end
	
	helpMessage = helpMessage.."To find the help for a specific command type !help !<command>\nThe number beside each command is the permission required."
	
	if checkPermission(theChatter, 2) then
		copyText = helpMessage
		if onScreen == 2 then
			createCopyText()
		end
	end
	
	broadcastOrPrint(theChatter, helpMessage, true)
end

function hideBoard(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	useOnTable = false
	self.lock()
	local tempPos = self.getPosition()
	tempPos[2] = tempPos[2]+100
	self.setPosition(tempPos)
	self.interactable = false
	self.setColorTint({0,0,0})
	self.setRotation({0,0,0})
	interact = false
	turnOff()
	Wait.frames(doHide, 10)
	
end

function doHide()
	self.setPosition({1000,1000,1000})
	--broadcastOrPrint(theChatter, theChatter.steam_name.." has hidden the promote board.", false)
end

function broadcastHours(tempParameters) --- add colour
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	playerToGetHours = nil

    if(#args < 1) then
        broadcastOrPrint(theChatter, "Hours: Too few arguments. Please provide a name", true)
        return false
    end
	
    playerToPrintHoursTo = theChatter
    playerToGetHours = getPlayerByName(args[1])
    if playerToGetHours == nil then
		if isColorAndSitting(args[1]) then
			playerToGetHours = Player[firstToUpper(args[1])]
		else
			broadcastOrPrint(theChatter, "Hours: Couldn't find any player with a name similar to "..args[1], true)
			return false
		end
	end
	
	local url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=0F7C6FF4043A73BB517360A6836A7366&steamid=" .. playerToGetHours.steam_id .. "&format=json"
	WebRequest.get(url, self, "printTimePlayed")
end

function kickPlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToKick = nil

    if(#args < 1) then
        broadcastOrPrint(theChatter, "Kick: Too few arguments. Please provide a name or All", true)
        return false
    end
    
    playerToKick = getPlayerByName(args[1])
    if args[1] == "All" then
		for i, playerVar in pairs(Player.getPlayers()) do
			playerVar.kick()	
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has kicked everyone.", false)
		return false
	elseif args[1] == "Clrs" or args[1] == "Colors" then
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				Player[colours[i]].kick()	
			end
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has kicked everyone who was seated", false)
		return false
		
	elseif playerToKick ~= nil then
		playerToKick.kick()
		broadcastOrPrint(theChatter, theChatter.steam_name.." has kicked "..playerToKick.steam_name, false)
	else
		broadcastOrPrint(theChatter, "Kick: Couldn't find any player with a name similar to " .. args[1], true)
        return false
	end
end

function lockBoard(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if ( #args < 1 and interact == true ) or args[1] == "on" then
		self.interactable = false
		self.setLock(true)
		interact = false
		broadcastOrPrint(theChatter, theChatter.steam_name.." has locked the promote board.", false)
	elseif ( #args < 1 and interact == false ) or args[1] == "off" then
		self.interactable = true
		self.setLock(false)
		interact = true
		broadcastOrPrint(theChatter, theChatter.steam_name.." has unlocked the promote board.", false)
	end
end

function limitPickup (tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if (args[1] == "off") then
		maxPickup = -1
		broadcastOrPrint(theChatter, theChatter.steam_name.." has turned off pickup limit.", false)
		return false
	elseif (args[1] == "0") then
		maxPickup = tonumber(args[1])
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set the pickup limit to: "..args[1], false)
		theChatter.broadcast("note: if a player picks up one object without drag selecting it, it will not move them to grey. This function only works when they select object(s)")
		return false
	elseif (tonumber(args[1]) ~= nil) then
		maxPickup = tonumber(args[1])
		broadcastOrPrint(theChatter, theChatter.steam_name.." has set the pickup limit to: "..args[1], false)
		return false
	else 
		theChatter.broadcast("Limit: could not recognize the input. Please input a number or 'off'")
        return false
	end
end

function movePlayer(tempParameters) ---<player> <colour/team>
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local selectedPlayer = nil
	local works = false

    if(#args < 2) then
        theChatter.broadcast("Move: Too few arguments. Please provide a name and a color/team")
        return false
    end
    
	for i, whatever in pairs(teams) do
		if teams[i] == firstToUpper(args[2]) then
			works = "team"
		end
	end
	for i, whatever in pairs(colours) do
		if colours[i] == firstToUpper(args[2]) then
			works = "colour"
		end
	end
	if firstToUpper(args[2]) == "Grey" then
		works = "colour"
	end
	
	if works == false then
		broadcastOrPrint(theChatter, "Move: Unrecignized colour/team. Please provide a name and a color/team", true)
        return false
    end
	
    selectedPlayer = getPlayerByName(args[1])
    if selectedPlayer == nil then
        broadcastOrPrint(theChatter, "Move: Couldn't find any player with a name similar to " .. args[1], true)
        return false
    end
	
	if firstToUpper(args[2]) == "Grey" then
		selectedPlayer.changeColor("Grey")
		broadcastOrPrint(theChatter, theChatter.steam_name.." has moved "..selectedPlayer.steam_name.." to grey.", false)
    elseif works == "colour" then
		if Player[firstToUpper(args[2])].seated then
			Player[firstToUpper(args[2])].changeColor("Grey")
		end
		selectedPlayer.changeColor(firstToUpper(args[2]))
		broadcastOrPrint(theChatter, theChatter.steam_name.." has moved "..selectedPlayer.steam_name.." to "..firstToUpper(args[2])..".", false)
	elseif works == "team" then
		selectedPlayer.changeTeam(firstToUpper(args[2]))
		broadcastOrPrint(theChatter, theChatter.steam_name.." has moved "..selectedPlayer.steam_name.." to "..firstToUpper(args[2])..".", false)
	end
	
end

function messagePlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToMessage = nil
	local works = nil
	
	if(#args < 2) then
        broadcastOrPrint(theChatter, "Message: Too few arguments. Please provide a name/colour and a message", true)
        return false
    end
	
	for i, whatever in pairs(colours) do
		if colours[i] == firstToUpper(args[1]) then
			works = colours[i]
			
			if Player[works] == nil or Player[works].seated == false then
				broadcastOrPrint(theChatter, "Message: There is noone sitting in that colour.", true)
				return false
			end
		end
	end
	
	if works ~= nil then
		table.remove(args, 1)
		local messageToBroadcast = table.concat(args, " ")
		Player[works].broadcast(announceColour..theChatter.steam_name.."->"..Player[works].steam_name..": [ffffff]"..messageToBroadcast)
		theChatter.broadcast(announceColour..theChatter.steam_name.."->"..Player[works].steam_name..": [ffffff]"..messageToBroadcast)
		return false
	else
		playerToMessage = getPlayerByName(args[1])
		if playerToMessage == nil then
			broadcastOrPrint(theChatter, "Message: Could not find player/color", true)
			return false
		else
			table.remove(args, 1)
			local messageToBroadcast = table.concat(args, " ")
			playerToMessage.broadcast(announceColour..theChatter.steam_name.."->"..playerToMessage.steam_name..": [ffffff]"..messageToBroadcast)
			theChatter.broadcast(announceColour..theChatter.steam_name.."->"..playerToMessage.steam_name..": [ffffff]"..messageToBroadcast)
			return false
		end
	end
end

function mutePlayer(tempParameters) --@@
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToMute = nil

    if(#args < 1) then
        broadcastOrPrint(theChatter, "Mute: Too few arguments. Please provide a name or All", true)
        return false
    end
    
    playerToMute = getPlayerByName(args[1])
    if ( args[1] == "Allbut" or args[1] == "But" or ( ( args[1] == "All" or args[1] == "Clrs" or args[1] == "Colors")and args[2] == "But") ) and playerToMute == nil then
		if args[1] == "But" then
			playerToMute = getPlayerByName(args[2])
			---print(args[2])
			if (playerToMute == nil) then
				broadcastOrPrint(theChatter, "Mute: Couldn't find any player with a name similar to " .. args[2], true)
				return false
			end
		else
			playerToMute = getPlayerByName(args[3])
			if (playerToMute == nil) then
				broadcastOrPrint(theChatter, "Mute: Couldn't find any player with a name similar to " .. args[3], true)
				return false
			end
		end
		
		if args[1] == "Clrs" or args[1] == "Colors" then
			for i, whatever in pairs(colours) do
				if Player[colours[i]].seated and Player[colours[i]].steam_id ~= playerToMute.steam_id then
					Player[colours[i]].mute()
				end
			end
		else
			for i, playerVar in pairs(Player.getPlayers()) do
				if playerVar.steam_id ~= playerToMute.steam_id then
					playerVar.mute()
				end
			end
		end
		
		broadcastOrPrint(theChatter, theChatter.steam_name.." has muted all seated players except: "..playerToMute.steam_name, false)
		return false
		
    elseif args[1] == "All" then
		for i, playerVar in pairs(Player.getPlayers()) do
			playerVar.mute()
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has muted all players.", false)
		return false
	elseif args[1] == "Clrs" or args[1] == "Colors" then
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				Player[colours[i]].mute()
			end
		end
		broadcastOrPrint(theChatter, theChatter.steam_name.." has muted all seated players.", false)
		return false
	elseif playerToMute ~= nil then
		playerToMute.mute()
		broadcastOrPrint(theChatter, theChatter.steam_name.." has muted "..playerToMute.steam_name..".", false)
		return false
	else
		broadcastOrPrint(theChatter, "Mute: Couldn't find any player with a name similar to " .. args[1], true)
        return false
	end
	
	---if (blindTest == nil and Player.blindfolded == false) or (blindTest == false and Player[colours[i]].blindfolded == false) then
end

end

do --- chat commands N-Z

function nickPlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToNick = nil
	local newName = nil
	
	if #args > 1 then
	
		playerToNick = getPlayerByName(args[1])
		if(playerToNick == nil) then
			broadcastOrPrint(theChatter, "Nick: Couldn't find any player with a name similar to " .. args[1], true)
			return false
		end
		
		table.remove(args, 1)
		newName = table.concat(args, " ")
		nicknames[playerToNick.steam_id] = newName
		broadcastOrPrint(theChatter, theChatter.steam_name.." has nicknamed "..playerToNick.steam_name.." to "..newName, false)
		
	elseif #args == 1 then
	
		if firstToUpper(args[1]) == "Clear" then
			nicknames = {}
			broadcastOrPrint(theChatter, theChatter.steam_name.." has cleared nicknames.", false)
			return false
		else
			playerToNick = getPlayerByName(args[1])
			if(playerToNick == nil) then
				broadcastOrPrint(theChatter, "Nick: Couldn't find any player with a name similar to " .. args[1], true)
				return false
			end
			nicknames[playerToNick.steam_id] = nil
			broadcastOrPrint(theChatter, theChatter.steam_name.." has removed the nickname for "..playerToNick.steam_name..".", false)
		end
		
	else
		broadcastOrPrint(theChatter, "Nick: Too few arguments. Please provide a name", true)
		return false
	end
end

function playArea(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args < 1 then
		Physics.play_area = 0.5
		broadcastOrPrint(theChatter, "play area: games play area has now been set to 0.5", false)
	end
	
	if tonumber(args[1]) ~= nil then
		Physics.play_area = tonumber(args[1])
		broadcastOrPrint(theChatter, "play area: games play area has now been set to "..args[1], false)
	else 
		broadcastOrPrint(theChatter, "play area: could not recognize "..args[1].." as a number", true)
		return false
	end
end

function promotePlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToPromote = nil

    if(#args < 1) then
        broadcastOrPrint(theChatter, "Promote: Too few arguments. Please provide a name or All", true)
        return false
    end
	
	pmtTest = nil
	if args[2] ~= nil and args[2] == "un" then
		pmtTest = true
	elseif args[2] ~= nil and args[2] == "reg" then
		pmtTest = false
	end
    
    playerToPromote = getPlayerByName(args[1])
    if args[1] == "All" then
		for i, playerVar in pairs(Player.getPlayers()) do
			if pmtTest == nil or (pmtTest == playerVar.promoted) then
				playerVar.promote()
			end
		end
		
		if blindTest == nil then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has toggled all players' promotions.", false)
		elseif blindTest == true then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has demoted all players.", false)
		elseif blindTest == false then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has promoted all players.", false)
		end
		
		return false
	elseif args[1] == "Clrs" or args[1] == "Colors" then
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				if pmtTest == nil or (pmtTest == Player[colours[i]].promoted) then
					Player[colours[i]].promote()
				end
			end
		end
		
		if blindTest == nil then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has toggled all seated players' promotions.", false)
		elseif blindTest == true then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has demoted all seated players.", false)
		elseif blindTest == false then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has promoted all seated players.", false)
		end
		
		return false
	elseif playerToPromote == nil then
		broadcastOrPrint(theChatter, "Promote: Couldn't find any player with a name similar to "..args[1], true)
        return false
	end
	
	if pmtTest == nil or (pmtTest == Player[colours[i]].promoted) then
		playerToPromote.promote()
		if playerToPromote.promoted then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has promoted "..playerToPromote.steam_name, false)
		else
			broadcastOrPrint(theChatter, theChatter.steam_name.." has demoted "..playerToPromote.steam_name, false)
		end
	end
end

pollActive = false
pollOptions = 0
pollVotes = {}

function startPoll(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args > 0 and args[1] == "start" then
		if tonumber(args[2]) ~= nil then
			pollOptions = tonumber(args[2])
		else
			pollOptions = 0
		end
		pollVotes = {}
		
		if pollOptions ~= 0 then
			printToAll(announceColour..theChatter.steam_name.." has started a poll. please vote between 1 and "..pollOptions..". \n example: use '!vote 1 2' to vote for 1 and 2")
		else
			printToAll(announceColour..theChatter.steam_name.." has started a poll. Anything can be voted for this vote. use '!vote 1 2' to vote for 1 and 2")
		end
		
		pollActive = true
		return false
	elseif #args > 0 and args[1] == "end" then
		pollActive = false
		--print("test")
		local votesOnOptions = {}
		for i, value in pairs(Player.getPlayers()) do
			if pollVotes[value.steam_name] ~= nil then
				for i, value2 in pairs(pollVotes[value.steam_name]) do
					if votesOnOptions[value2] == nil then
						votesOnOptions[value2] = 1
					else
						votesOnOptions[value2] = votesOnOptions[value2] + 1
					end
				end
			end
		end
		
		local highest = 0
		local currentWin = "Noone voted."
		local multipleWinners = false
		local otherWinners = {}
		for i, value in pairs(votesOnOptions) do
			if value > highest then
				highest = value
				currentWin = i
				multipleWinners = false
				otherWinners = {}
			elseif value == highest then				
				table.insert(otherWinners,1,i)
				multipleWinners = true
			end
		end
		
		if currentWin == "Noone voted." then
			broadcastOrPrint(theChatter, announceColour.."Noone voted for the poll. There was no winner.", false)
		elseif multipleWinners == true then
			local pollMessage = "Votes have been tallied and there was a tie. "
			for i, value in pairs(otherWinners) do
				pollMessage = pollMessage .. value .. ", "
			end
			
			pollMessage = pollMessage .. "and "..currentWin.." have won in a tie"
			printToAll(announceColour..pollMessage)
		else 
			printToAll(theChatter, announceColour.."Votes have been tallied and "..currentWin.." has won.", false)
		end
	else
	
		broadcastOrPrint(theChatter, "poll: Please define whether you are starting or ending a poll. 'start' or 'end'", true)
		
	end
	
end

function printHours(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if printHoursOnJoin then
		printHoursOnJoin = false
	else
		printHoursOnJoin = true
	end
	
	broadcastOrPrint(theChatter, theChatter.steam_name.." has set print hours on join to: "..tostring(printHoursOnJoin), false)
	return false
end

function CommandRecognition(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if Cmdrec then
		Cmdrec = false
	else
		Cmdrec = true
	end
	
	printToAll(announceColour..theChatter.steam_name.." has set command recognition to: "..tostring(Cmdrec), white)
	return false
end

function resetBoard(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	announceColour = "[1ac6ff]"
	nicknames = {}
	silenced = {}
	chatCommands = true
	autoPromote = false
	greyBT = false
	kickBT = false
	self.interactable = true
	self.setLock(false)
	interact = true
	printCommands = false
	printHoursOnJoin = false
	
	broadcastOrPrint(theChatter, theChatter.steam_name.." has reset the promote board.", false)
	return false
end

function rainbowChat(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	-- credit for the idea for this goes to King Psychospud7 on steam. 
	--This isnt exactly copied from him, but it's made to be basically the same.
	
	local rainbowColourrgb = {}
	rainbowColourrgb[math.random(1,3)] = 255
	
	local emptySlots = {0,0}
	for i = 1, 3 do
		if rainbowColourrgb[i] == nil and emptySlots[1] == 0 then
			emptySlots[1] = i
		elseif rainbowColourrgb[i] == nil then
			emptySlots[2] = i
			rainbowColourrgb[emptySlots[math.random(1,2)]] = math.random(0,255)
			if rainbowColourrgb[i] ~= nil then
				rainbowColourrgb[emptySlots[1]] = 0
				onSection = i*2-1
			else
				rainbowColourrgb[i] = 0
				onSection = emptySlots[1]*2-1
			end
		end
	end
	
	--[[
	
	1 = 1
	2 = 3
	3 = 5
	
	]]--
	
	
	--print("start: {"..rainbowColourrgb[1]..", "..rainbowColourrgb[2]..", "..rainbowColourrgb[3].."} ")
	
	local rainbowMessage = ""
	local message = table.concat(args, " ")
	local incriment = 40
	local extraInc = 0
	
	for i = 1, #message do
		
		if onSection == 3 then
			rainbowColourrgb = {255, rainbowColourrgb[2] + incriment+extraInc, 0}
			
		elseif onSection == 4 then
			rainbowColourrgb = {rainbowColourrgb[1] - incriment-extraInc, 255, 0}
		
		
		elseif onSection == 5 then
			rainbowColourrgb = {0, 255, rainbowColourrgb[3] + incriment+extraInc}
			
		elseif onSection == 6 then
			rainbowColourrgb = {0, rainbowColourrgb[2] - incriment-extraInc, 255}
			
		elseif onSection == 1 then
			rainbowColourrgb = {rainbowColourrgb[1] + incriment+extraInc, 0, 255}
			
		elseif onSection == 2 then
			rainbowColourrgb = {255, 0, rainbowColourrgb[3] - incriment-extraInc}
		
		--else
			--print("error {"..rainbowColourrgb[1]..", "..rainbowColourrgb[2]..", "..rainbowColourrgb[3].."}")
		end
		
		for i = 1, 3 do
			if rainbowColourrgb[i] > 255 then
				extraInc = rainbowColourrgb[i]-255
				rainbowColourrgb[i] = 255
				onSection = onSection + 1
			elseif rainbowColourrgb[i] < 0 then
				extraInc = math.abs(rainbowColourrgb[i])
				rainbowColourrgb[i] = 0
				onSection = onSection + 1
			end
		end
		
		if onSection == 7 then
			onSection = 1
		end
		
		--print("test {"..rainbowColourrgb[1]..", "..rainbowColourrgb[2]..", "..rainbowColourrgb[3].."} "..onSection)
	
		local colourString = "["
		for index = 1, #rainbowColourrgb do
			colourString = colourString .. string.format("%.2x", rainbowColourrgb[index])
		end
		colourString = colourString .. "]"
	
	
		rainbowMessage = rainbowMessage .. colourString .. string.sub(message, i, i) .. "[-]"
	end
	
	printToAll(theChatter.steam_name..": [ffffff]"..rainbowMessage, theChatter.color)
end

function rollDice(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local sides = nil
	local numberOfDice = nil
	local rolledTotal = nil
	
	if #args < 2 then
        numberOfDice = 1
	elseif tonumber(args[2]) ~= nil then
		numberOfDice = tonumber(args[2])
	else
		broadcastOrPrint(theChatter, "Roll: Unrecignized number. The Second argument is not a number", true)
        return false
    end
	
	if numberOfDice == 1 then
		isThereAnS = ""
	else
		isThereAnS = "s"
	end
	
	if #args < 1 then
        sides = 6
	elseif tonumber(args[1]) ~= nil then
		sides = tonumber(args[1])
	else
		broadcastOrPrint(theChatter, "Roll: Unrecignized number. The first argument is not a number", true)
        return false
    end
	
	local total = 0
	for i=1, numberOfDice do
		total = total + math.random(1,sides)
	end
	
	printToAll(announceColour..theChatter.steam_name.." has rolled "..numberOfDice.." d"..sides..isThereAnS.." and rolled a: "..total,white)
end

function silencePlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToSil = nil

    if(#args < 1) then
        broadcastOrPrint(theChatter, "Mute: Too few arguments. Please provide a name or All", true)
        return false
    end
	
	if (#args == 1 and args[1] == "Clear") then
		silenced = {}
		return false
	end
	
	silTest = nil
	if args[2] ~= nil and args[2] == "un" then
		silTest = true
	elseif args[2] ~= nil and args[2] == "reg" then
		silTest = false
	end
    
    playerToSil = getPlayerByName(args[1])
    if args[1] == "All" then
		for i, playerVar in pairs(Player.getPlayers()) do
			playerVar.mute()
			local tempVariable = playerVar.steam_id
			if silTest == nil then
				if silenced[tempVariable] then
					silenced[tempVariable] = nil
				else
					silenced[tempVariable] = true
				end
			elseif silTest == true then
				silenced[tempVariable] = nil
			elseif silTest == false then
				silenced[tempVariable] = true
			end
		end
		
		if blindTest == nil then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has toggled all player's silence.", false)
		elseif blindTest == true then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has unsilenced all players.", false)
		elseif blindTest == false then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has silenced all players.", false)
		end
		
		return false
	elseif args[1] == "Clrs" or args[1] == "Colors" then
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				Player[colours[i]].mute()
				local tempVariable = Player[colours[i]].steam_id
				if silTest == nil then
					if silenced[tempVariable] then
						silenced[tempVariable] = nil
					else
						silenced[tempVariable] = true
					end
				elseif silTest == true then
					silenced[tempVariable] = nil
				elseif silTest == false then
					silenced[tempVariable] = true
				end
			end
		end
		
		if blindTest == nil then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has toggled all seated player's silence.", false)
		elseif blindTest == true then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has unsilenced all seated players.", false)
		elseif blindTest == false then
			broadcastOrPrint(theChatter, theChatter.steam_name.." has silenced all seated players.", false)
		end
		
		return false
	elseif playerToSil ~= nil then
		local steamidToSil = playerToSil.steam_id
		if silTest == nil then
			if silenced[steamidToSil] then
				silenced[steamidToSil] = nil
				broadcastOrPrint(theChatter, theChatter.steam_name.." has un-silenced "..playerToSil.steam_name..".", false)
			else
				silenced[steamidToSil] = true
				broadcastOrPrint(theChatter, theChatter.steam_name.." has silenced "..playerToSil.steam_name..".", false)
			end
		elseif silTest == true then
			silenced[steamidToSil] = nil
			broadcastOrPrint(theChatter, theChatter.steam_name.." has un-silenced "..playerToSil.steam_name..".", false)
		elseif silTest == false then
			silenced[steamidToSil] = true
			broadcastOrPrint(theChatter, theChatter.steam_name.." has silenced "..playerToSil.steam_name..".", false)
		end
		playerToSil.mute()
	else
		broadcastOrPrint(theChatter, "Silence: Couldn't find any player with a name similar to " .. args[1], true)
        return false
	end
end

function setAnnounceColour(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args < 1 then
		announceColour = "[1ac6ff]"
		theChatter.broadcast(announceColour.."Announce Color: this is the new announce color.")
		broadcastOrPrint(theChatter, theChatter.steam_name.." has changed the announce color", false)
        return false
	end
	
	for i, value in pairs(colours) do
		if firstToUpper(args[1]) == value then
			announceColour = clrnums[i]
			theChatter.broadcast(announceColour.."Announce Color: this is the new announce color.")
			broadcastOrPrint(theChatter, theChatter.steam_name.." has changed the announce color", false)
			return false
		end
	end
	
	announceColour = "["..args[1].."]"
	theChatter.broadcast(announceColour.."Announce Color: this is the new announce color.")
	broadcastOrPrint(theChatter, theChatter.steam_name.." has changed the announce color", false)
end

function broadcastStatus(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local stringToPrint = announceColour
	
	stringToPrint = stringToPrint.."autoPromote: "..tostring(autoPromote).."\n"
	stringToPrint = stringToPrint.."greyBT: "..tostring(greyBT).."\n"
	stringToPrint = stringToPrint.."kickBT: "..tostring(kickBT).."\n"
	stringToPrint = stringToPrint.."interact: "..tostring(interact).."\n"
	stringToPrint = stringToPrint.."limit: "..tostring(limit).."\n"
	stringToPrint = stringToPrint.."printCommands: "..tostring(printCommands).."\n"
	stringToPrint = stringToPrint.."printHoursOnJoin: "..tostring(printHoursOnJoin).."\n"
	
	stringToPrint = stringToPrint.."\n\n"
	
	stringToPrint = stringToPrint.."Nicknames:\n"
	for i, value in pairs(nicknames) do ---i is the name of the section of the dictionary
		if getPlayerById(i) != nil then
			stringToPrint = stringToPrint..i.." ("..getPlayerById(i).steam_name..") - "..tostring(value).."\n"
		else
			stringToPrint = stringToPrint..i.." - "..tostring(value).."\n"
		end
	end
	
	stringToPrint = stringToPrint.."\n"
	
	stringToPrint = stringToPrint.."silenced:\n"
	for i, value in pairs(silenced) do
		if getPlayerById(i) != nil then
			stringToPrint = stringToPrint..i.." ("..getPlayerById(i).steam_name..") - "..tostring(value).."\n"
		else
			stringToPrint = stringToPrint..i.." - "..tostring(value).."\n"
		end
	end
	
	stringToPrint = stringToPrint.."\n"
	
	stringToPrint = stringToPrint.."trusted:\n"
	for i, value in pairs(trusted) do
		if getPlayerById(i) != nil then
			stringToPrint = stringToPrint..i.." ("..getPlayerById(i).steam_name..") - "..tostring(value).."\n"
		else
			stringToPrint = stringToPrint..i.." - "..tostring(value).."\n"
		end
	end
	
	theChatter.broadcast(stringToPrint)
	copyText = stringToPrint
	if onScreen == 2 then
		createCopyText()
	end
	
end

function getSteamId(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToGetId = nil
	
	if #args < 1 then
		broadcastOrPrint(theChatter, "Steam ID: Please input an argument. ('All', 'Clrs', a color, or a player name)", true)
		return false
	end
	
	copyText = ""
	for i, playerVar in pairs(Player.getPlayers()) do
		if ( 
		playerVar.color == firstToUpper(args[1]) or args[1] == "All" 
		or (getPlayerByName(args[1]) ~= nil and playerVar.steam_name == getPlayerByName(args[1]).steam_name) 
		or ( ( args[1] == "Clrs" or args[1] == "Colors" ) and playerVar.seated )
		) then
			theChatter.broadcast(announceColour..Player[colours[i]].steam_name.."'s steam id: "..Player[colours[i]].steam_id)
			copyText = copyText..Player[colours[i]].steam_id.."\n"
			if onScreen == 2 then
				createCopyText()
			end
			doneGettingId = true ---return false moved down so All works (it searches if the name is a colour first, if not it continues)
		end
	end
	
	if doneGettingId == true then
		doneGettingId = nil
		return false
	else
		broadcastOrPrint(theChatter, "Steam ID: No players found under set conditions.", true)
		return false
	end
	
end

function shufflePlayers(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local includeBlack = false
	local includeSpecs = false
	
	if #args > 0 and args[1] == 2 then
		local includeBlack = true
		broadcastOrPrint(theChatter, theChatter.steam_name.." has shuffled the players (including black)", false)
	elseif #args > 0 and args[1] == 3 then
		local includeSpecs = true
		broadcastOrPrint(theChatter, theChatter.steam_name.." has shuffled the players (including spectators)", false)
	elseif #args > 0 and args[1] == 4 then
		local includeBlack = true
		local includeSpecs = true
		broadcastOrPrint(theChatter, theChatter.steam_name.." has shuffled the players (including black and spectators)", false)
	else
		broadcastOrPrint(theChatter, theChatter.steam_name.." has shuffled the seated players", false)
	end
	
	local shufflePlayers = {}
	local playerColours = {}
	
	for i, value in pairs(Player.getPlayers()) do
		if value ~= nil and value.color ~= "Grey" and (value.color ~= "Black" or includeBlack) then
			table.insert(playerColours, value.color)
			table.insert(shufflePlayers, value)
			--value.changeColor("Grey")
		elseif value ~= nil and value.color == "Grey" and includeSpecs then
			table.insert(shufflePlayers, value)
		end
	end
	
	for i, value in pairs(playerColours) do
		if #shufflePlayers > 1 then
			local tempRandInt = math.random(#shufflePlayers)
			if (Player[playerColours[i]] ~= nil) then
				Player[playerColours[i]].changeColor("Grey")
			end
			shufflePlayers[tempRandInt].changeColor(playerColours[i])
			table.remove(shufflePlayers, tempRandInt)
		else
			shufflePlayers[1].changeColor(playerColours[i])
		end
	end
end

function swapPlayer(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	local playerToSwap = nil

    if #args < 2 then
        broadcastOrPrint(theChatter, "Swap: Too few arguments. Please provide a name and a color", true)
        return false
    end
    
    playerToSwap = getPlayerByName(args[1])
    if playerToSwap == nil then
		if isColorAndSitting(args[1]) then
			args[1] = firstToUpper(args[1])
			prevcolour = args[1]
			playerToSwap = Player[args[1]]
		else
			broadcastOrPrint(theChatter, "Swap: Couldn't find any player with a name simular to " .. args[1], true)
			return false
		end
    end
    prevcolour = playerToSwap.color
	
	
	
	local playerToSwap2 = nil
	playerToSwap2 = getPlayerByName(args[2])
	if playerToSwap2 == nil then
		if isColorAndSitting(args[2]) then
			args[2] = firstToUpper(args[2])
			prevcolour2 = args[2]
			playerToSwap2 = Player[args[2]]
		else
			broadcastOrPrint(theChatter, "Swap: Couldn't find any player with a name/color simular to " .. args[2], true)
			return false
		end
	else
		prevcolour2 = playerToSwap2.color
    end
	
	if playerToSwap2 ~= nil then
		playerToSwap2.changeColor("Grey")
	end
	
	playerToSwap.changeColor(prevcolour2)
	
	if prevcolour ~= "Grey" and playerToSwap2 ~= nil then
		playerToSwap2.changeColor(prevcolour)
	end
	
	if playerToSwap2 ~= nil then
		broadcastOrPrint(theChatter, theChatter.steam_name.." has swapped "..playerToSwap.steam_name.." with "..playerToSwap2.steam_name..".", false)
	else
		broadcastOrPrint(theChatter, theChatter.steam_name.." has swapped "..playerToSwap.steam_name.." with "..prevcolour2..".", false)
	end
end

function broadcastTest(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	broadcastOrPrint(theChatter, "Promote Board currently on the table.", true)
end

function trustAddRemove (tempParameters) --- remove trusted by nickname, 
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if #args == 1 and args[1] == "clear" then
		trusted = {}
		resetSettingScreen("unused", theChatter.color)
		return false
	end
	
	local idToAdd = nil
	local personToAdd = nil
	
	local addPerson = true
	local addByName = true
	
	local nameToAdd = nil
	local isItAll = nil
	
	--- <optional:'add'/'remove'> <optional:'name'/'id'> <name/id(assumes name unless id was entered) or 'All'> <Optional: nickname>
	if (#args == 0) then
		broadcastOrPrint(theChatter, "Trust: No arguments were given. Please at least provide a name of a person on the table to add.", true)
		return false
	elseif (#args == 1) then
		personToAdd = getPlayerByName(args[1])

	---two arguments
	elseif (args[1] == "add" and args[2] == "name") then
		personToAdd = getPlayerByName(args[3])
		table.remove(args, 1)
		table.remove(args, 1)
	elseif (args[1] == "add" and args[2] == "id") then
		personToAdd = getPlayerByName(args[3])
		addByName = false
		table.remove(args, 1)
		table.remove(args, 1)
	elseif (args[1] == "remove" and args[2] == "name") then
		idToAdd = args[3]
		addPerson = false
		table.remove(args, 1)
		table.remove(args, 1)
	elseif (args[1] == "remove" and args[2] == "id") then
		idToAdd = args[3]
		addByName = false
		addPerson = false
		table.remove(args, 1)
		table.remove(args, 1)
		
	--- one argument
	elseif (( args[1] == "add" or args[2] == "name" )) then
		personToAdd = getPlayerByName(args[2])
		table.remove(args, 1)
	elseif (args[1] == "remove") then
		personToAdd = getPlayerByName(args[2])
		addPerson = false
		idToAdd = args[2]
		table.remove(args, 1)
	elseif (args[1] == "id") then
		idToAdd = args[2]
		addByName = false
		table.remove(args, 1)
	end
	
	if (args[1] == "All") then
		isItAll = true
	elseif args[1] == "Clrs" or args[1] == "Colors" then
		isItAll = false
	end
	table.remove(args, 1)
	
	---nickname
	if (args ~= nil and #args > 0) then
		nameToAdd = table.concat(args, " ")
	elseif (personToAdd ~= nil) then
		nameToAdd = personToAdd.steam_name
	end
	
	--- if it was remove all by id
	if (addByName == false and idToAdd == "All" and addPerson == false) then
		trusted = {}
		broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has cleared the trusted list.", false)
		return false
	elseif (addByName and isItAll ~= nil and isItAll == false) then
	
		for i, whatever in pairs(colours) do
			if Player[colours[i]].seated then
				if addPerson then
					trusted[Player[colours[i]].steam_id] = Player[colours[i]].steam_name
				else
					trusted[Player[colours[i]].steam_id] = nil
				end
			end
		end
		
		if addPerson then
			broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added all seated players to auto promote.", false)
		else
			broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added removed all seated players from auto promote.", false)
		end
	
	
	elseif (addByName and isItAll ~= nil and isItAll == true) then
	
		for i, playerVar in pairs(Player.getPlayers()) do
			if addPerson then
				trusted[playerVar.steam_id] = Player[colours[i]].steam_name
			else
				trusted[playerVar.steam_id] = nil
			end
		end
		
		if addPerson then
			broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added all players to auto promote.", false)
		else
			broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added removed all players from auto promote.", false)
		end
	
	
	
	elseif (personToAdd == nil and addByName) then --@@
		
		if (addPerson == false) then
			
			local amountOfPlayersFound = 0
			for i, value in pairs(trusted) do
				print(value)
				print(idToAdd)
				if(string.match(string.lower(value), string.lower(idToAdd))) then
					amountOfPlayersFound = amountOfPlayersFound + 1
					trustedToClear = i
				end
			end
			
			if (amountOfPlayersFound == 1) then
				trusted[trustedToClear] = nil
				resetSettingScreen("unused", theChatter.color)
				return false
			else
				broadcastOrPrint(theChatter, "Trust: Could not find player seated or one nickname on your trusted list that contains the text.", true)
				return false
			end
			
		end
		
		broadcastOrPrint(theChatter, "Trust: The player given could not be found on the table.", true)
		return false
	
	--- adding or removing ids
	elseif (addByName == false and addPerson == false) then
		trusted[idToAdd] = nil
		broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has removed "..idToAdd.." from auto promote.", false)
	elseif (addByName == false and nameToAdd == nil) then
		trusted[idToAdd] = idToAdd
		broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added "..idToAdd.." to auto promote.", false)
	elseif (addByName == false) then
		trusted[idToAdd] = nameToAdd
		broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added "..nameToAdd.." to auto promote.", false)
	elseif (addByName and addPerson == false) then
		trusted[personToAdd.steam_id] = nil
		broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has removed "..personToAdd.steam_name.." from auto promote. ("..personToAdd.steam_id..")", false)
	else
		trusted[personToAdd.steam_id] = nameToAdd
		broadcastOrPrint(theChatter, announceColour..theChatter.steam_name.." has added "..nameToAdd.." to auto promote. ("..personToAdd.steam_id..")", false)
	end
	
	resetSettingScreen("unused", theChatter.color)
end

function uploadCode(tempParameters)
	local theChatter = tempParameters.theChatter
	local args = tempParameters.args
	
	if args[1] == "global" then
		Global.setLuaScript(copyText)
		return false
	end
	
	if theChatter.getHoverObject() == nil then
		broadcastOrPrint(theChatter, "Upload: Could not find hover object. Plase place your hand over an unlocked object and try again.", true)
		return false
	end
	
	theChatter.getHoverObject().setLuaScript(copyText)
	theChatter.getHoverObject().reload()
	
	broadcastOrPrint(theChatter, theChatter.steam_name.." has uploaded the code from the copy text box to the object: "..(theChatter.getHoverObject().name).." ("..(theChatter.getHoverObject().guid)..")", false)
	return false
end

end




















