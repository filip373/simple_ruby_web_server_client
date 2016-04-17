require 'socket'               # Get sockets from stdlib
require 'json'

def get_response(header, content)
  puts 'Handling the response'
  parts = header.split(' ')
  status = ''
  response_content = ''
  if parts[0] == 'GET' && parts[1] == '/index.html'
    status = '200 OK'
    response_content = File.read('index.html')
  elsif parts[0] == 'POST'
    params = JSON.parse(content)
    file = File.read('thanks.html')
    filled = file.sub('<%= yield %>', "<li>#{params['viking']['name']}</li><li>#{params['viking']['email']}</li>")
    status = '200 OK'
    response_content = filled
  else
    status = '404 Not Found'
    response_content = File.read('404.html')
  end
  response = "#{parts[2]} #{status}\r\n"
  response << "Date: #{Time.now}\r\n"
  response << "Content-Type: text/html\r\n"
  response << "Content-Length: #{content.size}\r\n"
  response << response_content
  response
end

server = TCPServer.open(2000)  # Socket to listen on port 2000
loop do                       # Servers run forever
  client = server.accept       # Wait for a client to connect
  puts 'New connection'
  header = client.gets("\r\n\r\n")
  request = ''
  header_parts = header.split("\r\n")
  if header_parts.any? { |p| p.include?('Content-Length') }
    length = header_parts.find { |s| s.include?('Content-Length') }.split(': ')[1]
    length.to_i.times do
      request << client.getc
    end
  end

  response = get_response(header, request)
  client.print response
  client.close                 # Disconnect from the client
  puts 'Connection closed'
end
