require "http/web_socket"
require "json"

API_URL = "wss://api.dogehouse.tv/socket"
TIMEOUT = 8

ws = HTTP::WebSocket.new(URI.parse(API_URL))

def join_room(socket : HTTP::WebSocket, room : String)
  join = JSON.build do |json|
    json.object do
      json.field "op", "room:join"
      json.field "d" do
        json.object do
          json.field "roomId", room
        end
      end
      json.field "ref", "[uuid]"
      json.field "v", "0.2.0"
    end
  end

  socket.send join
end

ws.on_message do |msg|
  puts msg
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

auth = JSON.build do |json|
  json.object do
    json.field "op", "auth"
    json.field "d", do
      json.object do
        json.field "accessToken", ENV["ACCESS_TOKEN"]
        json.field "refreshToken", ENV["REFRESH_TOKEN"]
        json.field "reconnectToVoice", false
        json.field "currentRoomId", ENV["ROOM_ID"]
        json.field "muted", true
        json.field "platform", "dogehouse-cr"
      end
    end
  end
end

ws.send auth

join_room ws, "c1089644-cc15-4204-8935-336b5a7fa83c"

ws.run
