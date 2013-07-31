http = require "socket.http"
require "socket"
socket.http.TIMEOUT=360


local output = assert(io.open("steam_specials.txt", "w"), "Failed to open output file")

local games = os.date() .. "\nGame\tOrignal Price\tReduced Price\tDiscount\n"

local response = http.request("http://store.steampowered.com/search/?specials=1")


for element in string.gmatch(response, "<h4>(.-)</h4>") do



	local start = string.find(response, element)

	local original = string.match(response, "</h4>.-<strike>&#163;(.-)</strike>", start)

	local reduced = string.match(response, "</strike>.-<br>&#163;(.-)</div>", start)


	if element and original and reduced then

		local priceDiff = original - reduced

		local percentageDiff = priceDiff / original * 100

		local percentageDiff = tonumber(string.format("%." .. 0 .. "f", percentageDiff))

		games = games .. element .. "\t£" .. original .. "\t£" .. reduced .. "\t" .. percentageDiff .. "%\n"

	end


end

local gone = output:write(games)

local smtp = require("socket.smtp")

from = "<reminder@steam.com>"

rcpt = {
  "<dbenstock@gmail.com>",
}

mesgt = {
  headers = {
    to = "Daniel Benstock <dbenstock@gmail.com>",
    subject = "Games you want are on offer"
  },
  body = games
}

r, e = smtp.send{
  from = from,
  rcpt = rcpt, 
  source = smtp.message(mesgt)
}
