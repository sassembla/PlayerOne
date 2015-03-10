--[[]
	context for all connecting players.
	you can use local parameters and table(dictionary)s like local application.
]]
local M = {}


local json = require "json.json"
connections = {}
status = {}

count = 0




function M.onConnect(from, publish)
	ngx.log(ngx.ERR, "connect from:", from)
end

function M.onMessage(from, data, publish)

	local decodedJsonData = json:decode(data)


	-- run commands
	if decodedJsonData.command == "setId" then setNewOrReconnectedPlayerId(decodedJsonData, from)
	elseif decodedJsonData.command == "logging" then logging(decodedJsonData)
	

	else publish(data) end



	
end

function M.onDisconnect(from, reason, publish)
	local playerId = "not match"
	
	for i,v in ipairs(connections) do
		ngx.log(ngx.ERR, "isemp????:", i, "	", v, "	vs	", from)
		if v == from then
			playerId = i
		end
	end

	if playerId == "not match" then
		ngx.log(ngx.ERR, "playerId did not found, but disconnected:", from, "	reason:", reason)
	else
		status[playerId] = "disconnected"
		ngx.log(ngx.ERR, "player drop!:", playerId, ":", from, "	reason:", reason)
	end

end


-- 100f/s で動く処理
function M.onFrame(publish)
	
	if count % 100 == 0 then
		for i,v in ipairs(status) do
			ngx.log(ngx.ERR, "playerId:", i, ":", v, "	is:", status[i])
		end

		publish("data!:" .. count)
	end


	count = count + 1
end









-- commands

-- クライアントから送られてきた情報をもとに、playerId : connectionId のペアを更新する
function setNewOrReconnectedPlayerId (decodedJsonData, connectionId)
	local playerId = decodedJsonData.playerId

	-- すでにplayerIdが存在する場合は、connectionIdが切り替わっている可能性があるので上書きする。
	connections[playerId] = connectionId
	status[playerId] = "alive"

	ngx.log(ngx.ERR, "player set!:", playerId, ":", connectionId, "	status:", status[playerId])
end


-- playerIdと紐づけたロギングを行う
function logging (decodedJsonData)
	local playerId = decodedJsonData.playerId
	local log = decodedJsonData.log

	ngx.log(ngx.ERR, playerId, ":", log)
end




return M