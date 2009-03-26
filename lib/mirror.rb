f = File.open('/dev/hidraw3', 'r')

mode = :waiting
direction = nil
payload = []

while true
  begin
    b = f.read(2)
    if mode == :waiting
      if b[0] == 2
        direction = b[1] == 1 ? :in : :out
        mode = :payload
        f.read(2)
      end
    elsif mode == :payload
      if b[0] == 0 && b[1] == 0
        mode = :waiting
        puts "#{direction}\t#{payload.join}"
        puts payload
        payload = []
      else
        payload << b[0].to_s(16) 
        payload << b[1].to_s(16) 
      end
    end
  end
end

