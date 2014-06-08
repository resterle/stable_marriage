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
    @model = model.dup
  end
  
  def propose obj_0, obj_1
    @proposes[obj_0] ||= []
    @proposes[obj_0] << obj_1
  end

  def pair obj1, obj0
    @pairs[obj1]=obj0
  end

  def make_proposes
    @proposes ||= {}
    @model.group(0).each do |obj, prefs|
      if is_free? obj
        propose prefs[0], obj
        prefs.delete_at 0
      end
    end
  end
  
  def is_free? obj
    @pairs ||= {}
    !@pairs.has_value? obj
  end

  def higher_ranked? obj, rank
    return true if !@pairs.has_key?obj
    @model.group(1)[obj].each do |place|
      return true if place==rank
      return false if place==@pairs[obj]
    end
  end

  def process_proposes
    @proposes.each do |obj, proposes|
      proposes.each do |prop|
        if higher_ranked? obj, prop
          pair obj, prop
        end
      end
    end
  end

  def stable_match?
    @model.group(0).each_key do |obj|
      return false if is_free? obj
    end
    true
  end

  def stable_matching 
    while not stable_match?
      make_proposes
      process_proposes
    end
    puts "stable: #{@pairs}"
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
  task.stable_matching
end
