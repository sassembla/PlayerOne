IDENTIFIER_CENTRAL = "central"
IDENTIFIER_CLIENT = "client"


STATE_CONNECT = "connect"
STATE_MESSAGE = "message"
STATE_DISCONNECT_1 = "disconnect1"
STATE_DISCONNECT_2 = "disconnect2"


-- entrypoint for WebSocket client connecttion.


-- setup redis pub-sub
local redis = require "redis.redis"
local uuid = require "uuid.uuid"
local json = require "json.json"


local serverId = uuid.getUUID()


subRedisCon = redis:new()
local ok, err = subRedisCon:connect("127.0.0.1", 6379)
if not ok then
	ngx.log(ngx.ERR, "connection:", serverId, " failed to generate subscriver")
	return
end
subRedisCon:set_timeout(1000 * 60 * 60)
local ok, err = subRedisCon:subscribe(IDENTIFIER_CLIENT)
if not ok then
	ngx.log(ngx.ERR, "connection:", serverId, " failed to start subscriver")
	return
end


pubRedisCon = redis:new()
local ok, err = pubRedisCon:connect("127.0.0.1", 6379)
if not ok then
	ngx.log(ngx.ERR, "connection:", serverId, " failed to generate publisher")
	return
end


-- setup websocket client
local wsServer = require "ws.websocketServer"

wb, wErr = wsServer:new{
	timeout = 10000000,
	max_payload_len = 65535
}

if not wb then
	ngx.log(ngx.ERR, "connection:", serverId, " failed to new websocket: ", wErr)
	return
end



function connectWebSocket()
	-- start subscribe
	ngx.thread.spawn(subscribe)

	-- send connected
	local jsonData = json:encode({connectionId = serverId, state = STATE_CONNECT})
	pubRedisCon:publish(IDENTIFIER_CENTRAL, jsonData)

	-- start websocket serving
	while true do
		local recv_data, typ, err = wb:recv_frame()

		if wb.fatal then
			local jsonData = json:encode({connectionId = serverId, state = STATE_DISCONNECT_1})
			pubRedisCon:publish(IDENTIFIER_CENTRAL, jsonData)
			ngx.log(ngx.ERR, "connection:", serverId, " failed to send ping: ", err)
			break
		end
		if not recv_data then
			local bytes, err = wb:send_ping()
			if not bytes then
				ngx.log(ngx.ERR, "connection:", serverId, " failed to send ping: ", err)
				break
			end
		end

		if typ == "close" then
			local jsonData = json:encode({connectionId = serverId, state = STATE_DISCONNECT_2})
			pubRedisCon:publish(IDENTIFIER_CENTRAL, jsonData)

			-- start close.
			break
		elseif typ == "ping" then
			local bytes, err = wb:send_pong()
			if not bytes then
				ngx.log(ngx.ERR, "connection:", serverId, " failed to send pong: ", err)
				break
			end
		elseif typ == "pong" then
			ngx.log(ngx.INFO, "client ponged")

		elseif typ == "text" then
			-- post message to central.
			local jsonData = json:encode({connectionId = serverId, data = recv_data, state = STATE_MESSAGE})
			pubRedisCon:publish(IDENTIFIER_CENTRAL, jsonData)
		end
	end

	wb:send_close()
	ngx.log(ngx.ERR, "connection:", serverId, " connection closed")
end

-- subscribe loop
-- waiting data from central.
function subscribe ()
	while true do
		local res, err = subRedisCon:read_reply()
		if not res then
			ngx.log(ngx.ERR, "connection:", serverId, " redis subscribe read error:", err)
			break
		else
			if not wb:is_connecting() then
				subRedisCon:unsubscribe(IDENTIFIER_CLIENT)
				ngx.log(ngx.ERR, "connection:", serverId, " redis unsubscribed by websocket closed.")
				break
			end

			-- for i,v in ipairs(res) do
			-- 	ngx.log(ngx.ERR, "client i:", i, " v:", v)
			-- end

			-- send message with WebSocket for all subscribers.
			local decoded = json:decode(res[3])

			local targetIds = decoded.targets
			local data = decoded.data

			if not targetIds then
				local bytes, err = wb:send_text(data)
				if not bytes then
					ngx.log(ngx.ERR, "connection:", serverId, " failed to send text 1:", err)
					break
				end
			elseif contains(targetIds, serverId) then
				local bytes, err = wb:send_text(data)
				if not bytes then
					ngx.log(ngx.ERR, "connection:", serverId, " failed to send text 2:", err)
					break
				end
			end
		end
	end
end

function contains(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

connectWebSocket()
