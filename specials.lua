http = require "socket.http"
require "socket"


local output = assert(io.open("steam_specials.txt", "w"), "Failed to open output file")

local games = ""

local response = http.request("http://store.steampowered.com/search/?specials=1")


for element in string.gmatch(response, "<h4>(.-)</h4>") do

  games = games .. element .. "\n"

end

local gone = output:write(games)
