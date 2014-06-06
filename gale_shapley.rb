class Model
  def men option, *args
    object :man, option, args
  end 

  def women option, *args
    object :women, option, args
  end
  
  def group arg
    key = @objects.keys[arg]
    @objects[key] 
  end

  def object group,  option, args
    @objects ||= {}
    @objects[group] ||= {} 
    case option
      when :get
        @objects[group]     
      when :set
        @objects[group] = {}
        args.each do |arg|
          @objects[group].store(arg, [])
        end
    end
  end
  
  def addPrefered object, group, prefered
    @objects[group][object] <<prefered
  end

  def objects
    @objects
  end

  def method_missing name, *args
    @objects.each do |k, v|
      if v.has_key?name.to_sym
        if args.shift == :prefers
          args.each do |obj|
            addPrefered name.to_sym, k, obj
          end
        end
        return
      end 
    end
    super.method_missing name args
  end

end

class Task

  def model= model
    @model = model
  end
  
  def propose obj_0, obj_1
    @proposes[obj_0] ||= []
    @proposes[obj_0] << obj_1
  end

  def make_proposes
    @proposes ||= {}
    @model.group(0).each do |k,v|
      puts "#{k} proposes #{v[0]}"
      propose v[0], k
    end
  end
  
  def process_proposes
  end

  def stable_match?
    @a ||= 0
    @a += 1
    puts "a: #{@a}"
    true if @a > 5
    false
  end

  def stable_matching 
    make_proposes
  end
end

if __FILE__ == $0
  if ARGV.size>1
    puts 'Usage: match <model.rb>'
    exit 1
  end
  model = Model.new
  model.instance_eval(File.open(ARGV.shift).read)

  task = Task.new
  task.model = model
  while !task.stable_match?
    puts '#'
    task.stable_matching
  end
end
