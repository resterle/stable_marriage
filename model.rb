men :set,
  :Hans,
  :Peter,
  :Otto

women :set,
  :Anna,
  :Jana,
  :Gabi

Anna :prefers,
  :Otto,
  :Peter

Jana :prefers,
  :Hans,
  :Peter

Gabi :prefers,
  :Otto

Hans :prefers,
  :Anna

Peter :prefers,
  :Gabi,
  :Jana

Otto :prefers,
  :Gabi

puts women :get 
puts men :get 
