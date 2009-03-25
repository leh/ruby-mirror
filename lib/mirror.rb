f = File.open('/dev/hidraw3', 'r')

mode = :waiting
direction = nil
data = []

while true
  begin
    b = f.read(2)
    if mode == :waiting
      if b[0] == 2
        direction = b[1] == 1 ? :in : :out
        puts direction
        mode = :border
      end
    elsif mode == :border
      mode = :payload
    elsif mode == :payload
      if b[0] == 0 && b[1] == 0
        mode = :waiting
        puts data.join
        data = []
      else
        data << b[0].to_s(16) 
        data << b[1].to_s(16) 
      end
    end
  end
end

