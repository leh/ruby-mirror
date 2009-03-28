f = File.open('/dev/hidraw3', 'r')

while true
  begin
    a,b = f.read(2).split('').collect {|i| i[0]}                              # read 2 bytes, transform to array and cast to int
    if a == 2
      direction = b == 1 ? :in : :out                                         # get the direction
      size = f.read(3)[2]                                                     # two 0-bytes (unused) and the payload size
      payload = f.read(size).split('')                                        # read and transform in array
      payload.collect! {|i| i[0].to_s(16)}                                    # cast to int and cast to hex values
      payload = payload.inject {|memo,i| memo += (i.length == 1 ? "0"+i : i)} # prepend 0 to create valid hex values
      zero_byte = f.read(1)                                                   # unused 0-byte


      puts "#{direction}\t#{payload} (rfid#{payload}@things.violet.net)"
    end
  rescue Errno::EAGAIN
    puts "test"
  rescue Errno::EIO, Interrupt
    puts "\nbye."
    exit(0)
  end
end

