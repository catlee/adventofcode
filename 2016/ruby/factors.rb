primes = Enumerator.new do |y|
  primes = [2, 3]
  y << 2
  y << 3
  (primes.last+2..).step(2).each do |p|
    next if primes.filter { |m| m*m <= p }.any? { |m| p % m == 0 }
    y << primes.push(p).last
  end
end

puts primes.take(20)
