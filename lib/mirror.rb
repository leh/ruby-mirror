class RubyMirror

  @@device = "/dev/hidraw0"
  @@in = Hash.new
  @@out = Hash.new
  @@unknown = Array.new

  def self.device=(dev)
    raise "#{dev} doesn't exist or isn't readable." unless FileTest.exists?(dev) && FileTest.readable?(dev)
    @@device = dev
  end

  def self.device
    return @@device
  end

  def self.in(id, &block)
    @@in[id] = Array.new unless @@in[id]
    @@in[id] << block
  end

  def self.out(id, &block)
    @@out[id] = Array.new unless @@out[id]
    @@out[id] << block
  end

  def self.unknown(&block)
    @@unknown << block
  end

  def initialize(filename, options)
    RubyMirror.device = options[:device] if options[:device]
    @verbose = options[:verbose]
    load filename
  end

  def run
    f = File.open(self.class.device, 'r')

    while true
      a,b = f.read(2).split('').collect {|i| i[0]}                              # read 2 bytes, transform to array and cast to int
      if a == 2
        direction = b == 1 ? :in : :out                                         # get the direction
        size = f.read(3)[2]                                                     # two 0-bytes (unused) and the payload size
        payload = f.read(size).split('')                                        # read and transform in array
        payload.collect! {|i| i[0].to_s(16)}                                    # cast to int and cast to hex values
        payload = payload.inject {|memo,i| memo += (i.length == 1 ? "0"+i : i)} # prepend 0 to create valid hex values
        zero_byte = f.read(1)                                                   # unused 0-byte

        execute = direction == :in ? @@in : @@out
        if execute[payload]
          execute[payload].each { |block| block.call } 
        else
          @@unknown.each {|block| block.call(payload)} 
        end
        puts "#{direction}\t#{payload} (rfid#{payload}@things.violet.net)" if @verbose
      end
    end
  end
end

def device(dev)
  RubyMirror.device = dev
end

def tag_in(id, &block)
  RubyMirror.in(id, &block)
end

def tag_out(id, &block)
  RubyMirror.out(id, &block)
end

def unknown_tag(&block)
  RubyMirror.unknown(&block)
end
