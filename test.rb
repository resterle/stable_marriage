class Model
  def men option, *args
    object :man, option, args
  end 

  def women option, *args
    object :women, option, args
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

if __FILE__ == $0
  if ARGV.size>1
    puts 'Usage: match <model.rb>'
    exit 1
  end
  model = Model.new
  model.instance_eval(File.open(ARGV.shift).read)
end
