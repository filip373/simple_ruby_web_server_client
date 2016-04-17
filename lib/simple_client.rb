require 'socket'      # Sockets are in standard library
require 'json'

def request_and_print_response(request)
  server = TCPSocket.open('localhost', 2000)
  server.print(request)
  while line = server.gets   # Read lines from the socket
    puts line.chomp      # And print with platform line terminator
  end
  server.close               # Close the socket when done
end

def get(path)
  request = "GET #{path} HTTP/1.0\r\n\r\n"
  request_and_print_response(request)
end

def post(name, email)
  request = "POST / HTTP/1.0\r\n"
  content = {viking: {name: name, email: email}}.to_json
  request << "Content-Length: #{content.length}\r\n\r\n"
  request << "#{content}\r\n\r\n"
  request_and_print_response(request)
end

input = ''
until input == 'x'
  print 'command or x to exit: '
  input = gets.chomp
  parts = input.split(' ')
  case parts[0]
  when 'g' then get(parts[1])
  when 'p' then post(parts[1], parts[2])
  else "Uknown command: #{parts[0]}"
  end
end
