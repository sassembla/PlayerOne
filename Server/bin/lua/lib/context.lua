--[[]
	context for all connecting players.
	you can use local parameters and table(dictionary)s like local application.
]]
local M = {}


local json = require "json.json"
connections = {}
status = {}
count = 0


-- fire when message received.
function M.onMessage(from, data, publish)
	local decodedJsonData = json:decode(data)

	-- run commands
	if decodedJsonData.command == "setId" then setNewOrReconnectedPlayerId(decodedJsonData, from) 
	elseif decodedJsonData.command == "move" then setMove(decodedJsonData)
	elseif decodedJsonData.command == "logging" then logging(decodedJsonData)
	-- add other command here!
	else publish(data) end
end


-- 100f/s loop by server.
function M.onFrame(publish)
	if count % 5 == 0 then -- 20fps
		local data = gameLogic(count)
		publish(data, getAliveConnections())
	end

	count = count + 1
end




gameData = {}

function gameLogic(count)
	gameData["counter"] = count
	return json:encode(gameData)
end


function getAliveConnections()
	local livingConnections = {}
	local count = 1
	for i in pairs(status) do
		ngx.log(ngx.ERR, "playerId checking:", i, " con:", status[i])
		if status[i] == "alive" then
			livingConnections[count] = connections[i]
			count = count + 1
		end
	end
	return livingConnections
end



-- commands

-- クライアントから送られてきた情報をもとに、playerId : connectionId のペアを更新する
function setNewOrReconnectedPlayerId (decodedJsonData, connectionId)
	local playerId = decodedJsonData.playerId

	-- すでにplayerIdが存在する場合は、connectionIdが切り替わっている可能性があるので上書きする。
	connections[playerId] = connectionId
	status[playerId] = "alive"

	gameData[playerId] = {move={x = 0, y = 0}, hp=100}

	ngx.log(ngx.ERR, "connected new player is:", playerId, " connectionId:", connectionId)
end

function setMove (decodedJsonData)
	local playerId = decodedJsonData.playerId

	if not status[playerId] == "alive" then
		 return
	end


	local addX = decodedJsonData.addX
	local addY = decodedJsonData.addY

	local beforeX = gameData.playerId.move.x
	local beforeY = gameData.playerId.move.y
	
	local afterX = beforeX + addX
	local afterY = beforeY + addY

	gameData.playerId.move = {x = afterX, y = afterY}
end



-- playerIdと紐づけたロギングを行う
function logging (decodedJsonData)
	local playerId = decodedJsonData.playerId
	local log = decodedJsonData.log

	-- ngx.log(ngx.ERR, "p:", playerId, ":", log)
end




-- connect, disconnect
function M.onConnect(from, publish)
	ngx.log(ngx.ERR, "connect from:", from)
end


function M.onDisconnect(from, reason, publish)
	local disconnectedPlayerId = "not match"
	
	for playerId in pairs(connections) do
		if from == connections[playerId] then
			disconnectedPlayerId = playerId
			break
		end
	end

	if disconnectedPlayerId == "not match" then
		ngx.log(ngx.ERR, "playerId did not found, but disconnected:", from, "	reason:", reason)
	else
		status[disconnectedPlayerId] = "disconnected"
		ngx.log(ngx.ERR, "player drop!:", disconnectedPlayerId, ":", from, "	reason:", reason)
	end

end



return M