# elixir learning, with some notes and caveats

# binaries, concatenation, interpolation, build io data
defmodule FirstModule do
  def do_str_stuff(param) do
    # concatenate
    msg_one = "Hello " <> param <> "!"
    IO.puts msg_one
    # interpolate
    msg_two = "Hello #{:world}!"
    IO.puts msg_two
    # building IO data in list
    IO.puts FirstModule.build_io_data(param)
    # sigil, create
    msg_three = ~s(Hello world!)
    IO.puts msg_three
  end
  # concatenation & interpolation create a copy of the binary
  # building IO data using a list saves on memory
  def build_io_data(param) do
	  ["Hello ",param,"!"] 	
  end
end

FirstModule.do_str_stuff("world")

# ranges, range to list, condition block
defmodule RockyBalboa do
  def cuff_and_link(max_num) do
    # range to list based on max num passed
    nums = Enum.to_list 1..max_num
    # for loop with COND control flow
    # ideally, pattern matching is the elixir way
    # see fizzbuzz below...
    for num <- nums do
      cond do
        rem(num,3) === 0 && rem(num,5) === 0 ->
    	  IO.puts "cuff_and_link"
    	rem(num,3) === 0 ->
    	  IO.puts "cuff"
    	rem(num,5) === 0 ->
    	  IO.puts "link"
    	true ->
    	  IO.puts num
    	end
    end
  end
end

RockyBalboa.cuff_and_link(100)

# anonymous functions
defmodule AnonFunctionsEx do
  def exec_anon_funcs do
    # ++ combine arrays
    combine_list = fn (a,b) -> a ++ b end
    # the dot on the call is required which
    # denotes an anonymous function call
    combined = combine_list.([:a, :bc], [:x, :yz])
    IO.inspect combined
    sum_nums = fn (lst) -> Enum.sum(lst) end
    IO.puts sum_nums.([1,2,3,4])
  end
end

AnonFunctionsEx.exec_anon_funcs

# accessing erlang module from elixir
defmodule ErlangAccessorEx do
  # using elixir atom to access erlang
  # elixir exposes erlang mods as atoms
  def get_sqrt(i) do
    :math.sqrt(i)
  end
end

IO.puts ErlangAccessorEx.get_sqrt(49)

# using pipe to pass return value
defmodule PipeEx do
  def chain_some_calls(i) do
    tripler = fn (a) -> a * 3 end
    # Kernel.trunc/1 - float to int
    is_21 = fn (b) -> Kernel.trunc(b) === 21 end
    :math.sqrt(i) |>
    # no params passed to tripler()
    # would exclude the . for regular calls
    tripler.() |>
    is_21.()
  end
end

IO.inspect PipeEx.chain_some_calls(49)

# closures and lexical scope
defmodule ClosureEx do
  def power_up do
    i = 10 # bind as 10
    pow = fn -> 
      power = :math.pow(i,2) 
      power
    end
    IO.puts Kernel.trunc(pow.()) # returns 100
    i = 20 # rebind as 20 (new memory loc)
    IO.puts Kernel.trunc(pow.()) # returns 100 (still)
    # ^^ pow's lexical scope (env) includes 'i' bound as 10
    # ^^ i is rebound as 20, but goes unused with warning
  end

  # ^^ different from javascript and python where
  # the interpreter moves vars atop the current scope

  # > var test = function(x) {
  # ...   var y = 2;
  # ...   var z = 3;
  # ...   var testing = function(x) {
  # .....   return x + y + z
  # ..... }
  # ...   z = 4;
  # ...   return testing(x, y, z);
  # ... }
  # undefined
  # > test(1)
  # 7

  # >>> def test(x):
  # ...   y = 2
  # ...   z = 3
  # ...   testing = lambda x: x+y+z
  # ...   z = 4
  # ...   return testing(x)
  # ... 
  # >>> test(1)
  # 7

  def more_closures do
    # each closure is granted lexical
    # scope to the var bound before it
    closures = []
    i = 0
    closures = closures ++ [fn -> i end]
    i = 1
    closures = closures ++ [fn -> i end]
    IO.puts Enum.at(closures, 0).()
    IO.puts Enum.at(closures, 1).()
  end

  def even_more_closures do
    name = "Andy"
    greeter = fn (name) -> 
      fn -> 
        "Hello #{name}" 
      end 
    end
    andy_greeter = greeter.(name)
    IO.puts andy_greeter.()
  end
end

ClosureEx.power_up
ClosureEx.more_closures
ClosureEx.even_more_closures

# basic binary search tree
# example of multi clause functions (same arity)
# good example of param/arg pattern matching
defmodule BST do
  def node(data) do
    %{data: data, left: nil, right: nil}
  end

  # clause 1
  def insert(nil, data) do
    %{data: data, left: nil, right: nil}
  end

  # clause 2
  def insert(tree, data) do
    if data <= tree.data do
      %{tree | left: insert(tree.left, data)}
    else
      %{tree | right: insert(tree.right, data)}
    end
  end
end

tree = BST.node(4) 
      |> BST.insert(2) 
      |> BST.insert(26)
      |> BST.insert(6)

IO.inspect tree

# use the pin operator (^) when you want to 
# pattern match against an existing variable’s 
# value rather than rebinding the variable
defmodule PinningEx do
  def pinner(i) do
    fn
      (^i) -> "number #{i} is bound to i"
      (_)  -> "number #{i} is still bound to i"
    end
  end
  # another pinning example
  def more_pinning do
    a = 1
    b = 2
    # pattern match b pinned (no rebinding)
    # {^b,a} = {1,1} # match error (b pinned as 2) 
    # pattern match b pinned (no rebinding)
    IO.inspect {^b,^a} = {2,1} 
    # pattern match b (rebind b to 3)
    IO.inspect {b,a} = {3,1}
    IO.puts("b is now #{b}")
  end
end

# storing the returned anonymous function as pinner,
# assembles an environment that remembers 1
# example of how anonymous functions use pattern matching
# to bind their parameter list to passed arguments
pinner = PinningEx.pinner(1)
IO.puts pinner.(1)
IO.puts pinner.(2)
IO.puts pinner.("3")
PinningEx.more_pinning

# Multiples of 3 and 5
# Euler - Problem # 1

defmodule ProblemOne do
  def getMultiples() do
    nums = Enum.to_list 1..999
    Enum.filter(nums, fn num ->
      rem(num, 3) === 0 || rem(num, 5) === 0
    end)
  end
end

# returns list of ints 1 to 999 that are divisible by 3 or 5
getMultiples = ProblemOne.getMultiples
# sums the list
IO.puts Enum.sum(getMultiples) # 233168

# & operator, capturing anonymous functions
# the & operator captures expressions as functions 
# &1, &2, etc. represents params 1, 2, etc.
find_odds = fn numbers -> 
  Enum.reject(numbers, &(rem(&1,2) === 0))
  # ^^ shorhand and same as...
  # fn numbers -> 
  #   Enum.reject(numbers, fn x -> 
  #     rem(x,2) === 0 
  #   end)
  # end 
end
IO.inspect Enum.to_list 1..100 |> find_odds.()

# note: nested captures via '&' are not allowed
# e.g. &(Enum.reject(&1, &(rem(&1,2) === 0)))

##########################################
## --- Programming Elixir Exercises --- ##
##########################################

# puts anon func
puts = fn (a) -> IO.puts a end
# inspect anon func
inspect = fn (a) -> IO.inspect a end

# FizzBuzz - no conditional logic (instead pattern matching)
fizzbuzz = fn
  # defining multiple parameters
  (0,0,_) -> "FizzBuzz"
  (0,_,_) -> "Fizz"
  (_,0,_) -> "Buzz"
  (_,_,c) -> c
end

puts.(fizzbuzz.(0,0,1))
puts.(fizzbuzz.(0,1,1))
puts.(fizzbuzz.(1,0,1))
puts.(fizzbuzz.(1,1,1))

fizzbuzz_it = fn (n) ->
  fizzbuzz.(rem(n,3),rem(n,5),n)
end

puts.(fizzbuzz_it.(10))
puts.(fizzbuzz_it.(11))
puts.(fizzbuzz_it.(12))
puts.(fizzbuzz_it.(13))
puts.(fizzbuzz_it.(14))
puts.(fizzbuzz_it.(15))
puts.(fizzbuzz_it.(16))

prefix = fn (a) -> 
  fn (b) -> 
    "#{a} #{b}" 
  end 
end
one = prefix.("one,")
puts.(one.("two"))
puts.(prefix.("one,").("two"))

# Enum.map [1,2,3,4], fn x -> x + 2 end
inspect.(Enum.map [1,2,3,4], &(&1 + 2))
# Enum.each [1,2,3,4], fn x -> IO.inspect x end
Enum.each [1,2,3,4], &(IO.inspect &1)

# original syntax, non do..end block
defmodule Times do
  def double(n), do: n * 2
  def triple(n), do: n * 3
  def quadruple(n), do: double(n) * 2
end

# compiling a module example

# pi@raspberrypi:~/Documents/elixir$ iex times.esx 
# Erlang/OTP 22 [erts-10.4] [source] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

# Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)
# iex(1)> Times.triple(2)
# 6

# ---- or ----

# iex(1)> c "times.esx"
# [Times]
# iex(2)> Times.quadruple(3)

IO.puts Times.double(2)
IO.puts Times.triple(2)
IO.puts Times.quadruple(2)
