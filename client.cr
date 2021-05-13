require "http/web_socket"
require "json"

API_URL = "wss://api.dogehouse.tv/socket"
TIMEOUT = 8

ws = HTTP::WebSocket.new(URI.parse(API_URL))

def join_room(socket : HTTP::WebSocket, room : String)
  socket.send(
    {
      "op" => "room:join",
       "d" => {
         "roomId" => room
       },
       "ref" => "[uuid]",
       "v" => "0.2.0"
    }.to_json
  )
end

def auth(socket : HTTP::WebSocket, token : String, refreshToken : String)
  socket.send(
    {
      "op" => "auth", 
      "d" => {
        "accessToken" => token, 
        "refreshToken" => refreshToken
      }, 
      "reconnectToVoice" => false,
      "muted" => true,
      "platform" => "dogehouse-cr"
    }.to_json
  )
end

def send_message(socket : HTTP::WebSocket, s : String)
  j = {"op" => "chat:send_msg", "d" => {"tokens": format(s)}, "v" => "0.2.0"}.to_json
  puts j
  socket.send j
end

def format(s : String)
  s.split(" ").map {|x| {"type" => "text", "value" => x}}
end

ws.on_message do |msg|
  puts msg
end

ws.on_close do |code|
  puts "Connection closed: #{code}"
  exit 1
end 

ws.on_ping do
  puts "Received ping"
end

# Send pings
spawn do
  loop do
    ws.send "ping"
    sleep TIMEOUT
  end
end

auth ws, ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
join_room ws, "c1089644-cc15-4204-8935-336b5a7fa83c"

# spawn do
#   sleep 1
#   10.times do |i|
#   send_message ws, "This is message #{i}/10"
#   sleep 1
#   end
# end

send_message ws, "I AM ALIVE!!!!!!!!"

ws.run
