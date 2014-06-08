men :set,
  :Ken,
  :Leo,
  :Max

women :set,
  :Ada,
  :Bev,
  :Cat

Ada :prefers,
  :Ken,
  :Leo,
  :Max

Bev :prefers,
  :Leo,
  :Max,
  :Ken

Cat :prefers,
  :Max,
  :Leo,
  :Ken

Ken :prefers,
  :Bev,
  :Cat,
  :Ada

Leo:prefers,
  :Ada,
  :Cat,
  :Bev

Max :prefers,
  :Ada,
  :Bev,
  :Cat

puts women :get 
puts men :get 
