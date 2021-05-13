require "http/web_socket"
require "json"

API_URL = "wss://api.dogehouse.tv/socket"
TIMEOUT = 8

ws = HTTP::WebSocket.new(URI.parse(API_URL))

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
        json.field "currentRoomId", ""
        json.field "muted", true
        json.field "platform", "dogehouse-cr"
      end
    end
  end
end

ws.send auth

ws.run
