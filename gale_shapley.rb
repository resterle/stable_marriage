require 'graphviz'

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
  
  def create_image2 name
    g = GraphViz.new(:G, {
      :type => :digraph,
      :ranksep => '3',
      :nodesep => '1',
      :rankdir => 'LR',
      :splines => 'line'
      })
    @model.each do |k, v|
      @color = "blue" unless @color
      @graphs ||= {}
      @graphs[k.to_sym] = g.subgraph("cluster#{k.to_s}") do |cluster|
        cluster[:label] = k.to_s
        cluster[:margin] = '20'
      end
      v.each_key do |name|
        @graphs[k.to_sym].add_node(name.to_s, {:color => @color.dup})
      end
      @color = "red"
    end

    group = @model.keys[0]
    @model[group].each do |name, likes|
      likes.each do |like|
        n0 = @graphs[group].get_node name.to_s
        n1 = search_node like, group 
        color = 'black'
        color = 'green' if @pairs[name] == like || @pairs[like] == name
        taillabel = @model[group][name].find_index(like) +1 
        #puts "#{name} .. #{like}"
        headlabel = @model[@model.keys[1]][like].find_index(name) +1
        GraphViz::commonGraph(n1, n0).add_edge(n0, n1, {
              :color => color,
              :taillabel => taillabel,
              :headlabel => headlabel,
              :labeldistance => 1.3,
              :labelfontsize => 14,
              :labelfloat => true})
      end
    end
    g.output( :png => "#{name}")
  end
end

class Model
  def men option, *args
    object :men, option, *args
  end 

  def women option, *args
    object :women, option, *args
  end
  
  def first_group first=nil
    @first = first if first
    return group 0 unless @first
    return @objects[@first.to_sym]
  end

  def second_group
    return group 1 unless @first
    @objects.each_key do |k|
      return a = @objects[k] unless k==@first.to_sym
    end
  end

  def group arg
    key = @objects.keys[arg]
    @objects[key] 
  end

  def object group,  option, *args
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
  
  def stable_matching first=nil
    @first = first if first
    while not stable_match?
      make_proposes
      process_proposes
    end
  end 
 
  def make_proposes
    @proposes ||= {}
    first_group = @model.first_group @first
    first_group.each do |obj, prefs|
      if is_free? obj
        propose prefs[0], obj
        prefs.delete_at 0
      end
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

  def propose obj_0, obj_1
    @proposes[obj_0] ||= []
    @proposes[obj_0] << obj_1
  end
  
  def higher_ranked? obj, rank
    return true unless @pairs.has_key?obj
    @model.second_group[obj].each do |place|
      return true if place==rank
      return false if place==@pairs[obj]
    end
  end
  
  def pair obj1, obj0
    @pairs[obj1]=obj0
  end
  
  def is_free? obj
    @pairs ||= {}
    not @pairs.has_value? obj
  end

  def stable_match?
    @model.first_group.each_key do |obj|
      return false if is_free? obj
    end
    true
  end

  def model= model
    @model = model.dup
  end
  
  def result
    @pairs
  end

end

def to_b s
  return true if s == true || s =~ (/(true|t|yes|y|1)$/i)
  return false if s == false || s =~ (/(false|f|no|n|0)$/i) 
  return false
end

if __FILE__ == $0
  if ARGV.size<2
    puts 'Usage: match <model.rb> <output.png>'
    exit 1
  end
  file = ''
  output = 'output'
  show_all = false
  first = nil

  ARGV.each do |arg|
    arg = arg.split("=")
    case(arg[0])
      when 'input'
        file = arg[1]
      when 'output'
        output = arg[1]
      when 'first'
        first = arg[1]
    end
  end

  model = Model.new
  model.instance_eval(File.open(file).read)

  task = Task.new
  task.model = model
  task.stable_matching first
  
  model2 = Model.new
  model2.instance_eval(File.open(file).read)
  v = Visualize.new
  v.model = model2.objects
  v.pairs = task.result
  v.create_image2 output
  puts task.result
end