require "base64"
require "socket"

# $ ruby -e '
# require "./bobflake.rb"
# flake = Snowflake.new
# put_flake flake.next_id
# put_flake flake.next_id
# sleep(0.1)
# put_flake flake.next_id
# '

class Snowflake
  # 2018-01-01T00:00:00.00Z
  EPOCH = 151476480000

  def initialize
    @machine_id = Socket
      .ip_address_list
      .detect{ |intf| intf.ipv4_private? }
      .to_sockaddr[6..7]
      .unpack('S')
      .fetch(0)
    @sequence = 0
    @time = now
  end

  def next_id
    @sequence = (@sequence + 1 & 0x7FF)
    now << 27 | @sequence << 16 | @machine_id
  end

  def now
    ((Time.now.utc.to_f * 100).to_i - EPOCH) & 0x1FFFFFFFFF
  end
end

def put_flake(id)
  puts "#{Base64.urlsafe_encode64([id].pack('Q'), padding: false)} || #{id}"
end


