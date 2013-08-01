http = require "socket.http"
require "socket"
local smtp = require("socket.smtp")
local ssl = require 'ssl'
local https = require 'ssl.https'
local ltn12 = require 'ltn12'

socket.http.TIMEOUT=360


function sslCreate()
    local sock = socket.tcp()
    return setmetatable({
        connect = function(_, host, port)
            local r, e = sock:connect(host, port)
            if not r then return r, e end
            sock = ssl.wrap(sock, {mode='client', protocol='tlsv1'})
            return sock:dohandshake()
        end
    }, {
        __index = function(t,n)
            return function(_, ...)
                return sock[n](sock, ...)
            end
        end
    })
end

--local output = assert(io.open("steam_specials.txt", "w"), "Failed to open output file")

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

--local gone = output:write(games)


from = "<from>"

rcpt = {
  "<recipient>",
}

mesgt = {
  headers = {
    to = "Name",
    subject = "Games you want are on offer"
  },
  body = games
}

r, e = smtp.send{
	from = from,
	rcpt = rcpt,
	source = smtp.message(mesgt),
	user = 'username',
	password = 'password',
	server = 'smtp.gmail.com',
	port = 465,
	create = sslCreate
}
