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
  :Peter,
  :Hans

Jana :prefers,
  :Hans,
  :Peter,
  :Otto

Gabi :prefers,
  :Otto,
  :Hans,
  :Peter

Hans :prefers,
  :Anna,
  :Gabi,
  :Jana

Peter :prefers,
  :Gabi,
  :Jana,
  :Anna

Otto :prefers,
  :Gabi,
  :Anna,
  :Jana

puts women :get 
puts men :get 
