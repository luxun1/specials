http = require "socket.http"
require "socket"
socket.http.TIMEOUT=360

local output = assert(io.open("steam_specials.txt", "w"), "Failed to open output file")

local games = os.date() .. "\nGame\tOrignal Price\tReduced Price\n"

local response = http.request("http://store.steampowered.com/search/?specials=1")


for element in string.gmatch(response, "<h4>(.-)</h4>") do



  local start = string.find(response, element)

	local original = string.match(response, "</h4>.-<strike>&#163;(.-)</strike>", start)

	local reduced = string.match(response, "</strike>.-<br>&#163;(.-)</div>", start)

	if element and original and reduced then

		games = games .. element .. "\t£" .. original .. "\t£" .. reduced .. "\n"

	end


end

local gone = output:write(games)
