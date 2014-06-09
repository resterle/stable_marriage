require 'graphviz'

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
  
  def result
    @pairs
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
    not @pairs.has_value? obj
  end

  def higher_ranked? obj, rank
    return true unless @pairs.has_key?obj
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
  end 
end

class Visualize
  
  def model= model
    @model = model
  end
  
  def pairs= pairs
    @pairs = pairs
  end

  def search_node name, group
    n = nil
    @graphs.each do |k, v|
       if k != group
         n = v.search_node name.to_s unless n
       end
    end
    n
  end 

  def create_edges
    @model.each do |group, obj|
      obj.each do |name, likes|
        n0 = @graphs[group].get_node name.to_s
        c = 1
        likes.each do |like|
          color = 'black'
          color = 'green' if @pairs[like] == name
          n1 = search_node like, group
          @graphs[group].add_edge(n0, n1, {:color => color, :label => c.to_s})
          c +=1
        end
      end
    end
  end

  def create_image name
    g = GraphViz.new(:G, :type => :digraph)
    @model.each do |k, v|
      if v.is_a? Hash
        @color = "blue" unless @color
        @graphs ||= {}
        @graphs[k] = g.add_graph(k.to_s, {:label => k.to_s, :color => @color.dup})
        v.each_key do |name|
          @graphs[k].add_node(name.to_s, :color => @color.dup)
        end
        @color = "red"
      else
        n0 = g.add_node(k.to_s)
        n1 = g.add_node(v.to_s)
        g.add_edges(n0, n1)
      end
    end
    create_edges if @graphs
    g.output( :png => "#{name}.png")
  end
end

if __FILE__ == $0
  if ARGV.size>2
    puts 'Usage: match <model.rb> <output.png>'
    exit 1
  end
  file = ARGV.shift
  model = Model.new
  model.instance_eval(File.open(file).read)

  task = Task.new
  task.model = model
  task.stable_matching
  
  model2 = Model.new
  model2.instance_eval(File.open(file).read)
  v = Visualize.new
  v.model = model2.objects
  v.pairs = task.result
  v.create_image ARGV.shift
end