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

# single quoted strings represent a 
# list of character codes
Enum.each('abcdefghijklmnopqrstuvwxyz', fn x -> IO.puts x end)

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
    # ++ combine lists
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
# good example of param/arg pattern matching & recursion
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

  def search(tree, data) do
    cond do
      data < tree.data ->
        if tree.left == nil do
          IO.puts "Data #{data} was not found!"
        else
          search(tree.left, data)
        end
      data > tree.data ->
        if tree.right == nil do
          IO.puts "Data #{data} was not found!"
        else
          search(tree.right, data)
        end
      true ->
        IO.puts "Data #{data} was found!"
    end
  end

  def preorder(tree) do
    if tree != nil do
      IO.puts tree.data
      preorder(tree.left)
      preorder(tree.right)
    end
  end

  def inorder(tree) do
    if tree != nil do
      inorder(tree.left)
      IO.puts tree.data
      inorder(tree.right)
    end
  end

    def postorder(tree) do
    if tree != nil do
      postorder(tree.left)
      postorder(tree.right)
      IO.puts tree.data
    end
  end
end

tree = BST.node(12) 
      |> BST.insert(3) 
      |> BST.insert(6)
      |> BST.insert(14)
      |> BST.insert(4) 
      |> BST.insert(7)
      |> BST.insert(8)

IO.inspect tree

IO.puts BST.search(tree,3)  # found
IO.puts BST.search(tree,4)  # found
IO.puts BST.search(tree,24) # not found
IO.puts BST.search(tree,16) # not found
IO.puts BST.search(tree,6)  # found

BST.preorder(tree)
BST.inorder(tree)
BST.postorder(tree)

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
    # >> {^b,a} = {1,1} # match error (b pinned as 2) 
    # pattern match b pinned (no rebinding)
    IO.inspect {^b,^a} = {2,1} 
    # pattern match b (rebind b to 3)
    IO.inspect {b,a} = {3,1}
    IO.puts("a is #{a}")
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

# syntax to denote default params is 'identifier + \\ value'
defmodule ParamsEx do
  def testFunc(param1 \\ 1, param2, param3) do
    { param1, param2, param3 } 
  end
end

# in elixir, <func-name>/<arity> denotes the number of arguments
# above, testFunc can called as either testFunc/2 or testFunc/3
# where no matching takes place when called as testFunc/2
# 2 & 3 are assigned to the non defaults: param2, param3
IO.inspect ParamsEx.testFunc(2, 3)
# when the number of arguments passed matches whats defined 
# e.g. testFunc is called as testFunc/3
# positionally, each is assigned the value passed (left to right)
IO.inspect ParamsEx.testFunc(2,3,4)

# note: calling testFunc as testFunc/1 (less) or testFunc/4 (more)
# would result is an UndefinedFunctionError exception
# must be called as either testFunc/2 or testFunc/3 
# e.g. IO.inspect ParamsEx.testFunc(2)
# e.g. IO.inspect ParamsEx.testFunc(2,3,4,5)

# simple guard clauses w/predicates
defmodule GC do
  # clause 1
  def check_it(a) when is_binary(a) and a === "ABC123" do
    "not a letter, but is #{a}!"
  end
  
  # clause 2
  def check_it(a) when is_binary(a) and a === "A" do
    "#{a} is the letter of the day!"
  end

  # clause 3
  def check_it(a) when is_integer(a) and a > 0 do
    "is integer #{a}, which is > 0"
  end
end

IO.puts GC.check_it("A")
IO.puts GC.check_it(39)
IO.puts GC.check_it("ABC123")

# more guard clauses w/predicates
# b search - the functional way
# series of the same functions w/predicates
# uses recursion to cycle each func & predicate
# executes code when there is clause match
defmodule BSearch do
  # clause 1
  def search(target, low..high) when div(low + high, 2) > target do
    search(target, low..div(low + high, 2))
  end

  # clause 2
  def search(target, low..high) when div(low + high, 2) < target do
    search(target, div(low + high, 2)..high)
  end

  # clause 3
  def search(_, low..high) do 
    IO.puts div(low + high, 2)
  end
end

IO.puts BSearch.search(392, 1..1000)
IO.puts BSearch.search(16, 1..1000)
IO.puts BSearch.search(167, 1..1000)

# b search, python

# >>> lst = list(range(1,1001))

# >>> def b_search(lst,target):
# ...   start_idx = 0
# ...   end_idx = len(lst)-1
# ...   found = False
# ...   while (found is not True):
# ...     mid_pt = (start_idx+end_idx)//2
# ...     if lst[mid_pt] == target:
# ...       found = True
# ...     elif lst[mid_pt] > target:
# ...       end_idx = lst[mid_pt]
# ...     else:
# ...       start_idx = lst[mid_pt]
# ...   print(lst[mid_pt])
# ... 
# >>> b_search(lst,392)
# 392
# >>> b_search(lst,292)
# 292
# >>> b_search(lst,14)
# 14
# >>> b_search(lst,145)
# 145

# b search, ruby

# irb(main):003:0> arr = (1..1000).to_a

# irb(main):004:0> def b_search(arr, target)
# irb(main):005:1>   start_idx = 0
# irb(main):006:1>   end_idx = arr.size - 1
# irb(main):007:1>   found = false
# irb(main):008:1>   until found
# irb(main):009:2>     mid_pt = (start_idx + end_idx)/2
# irb(main):010:2>     if arr[mid_pt] == target
# irb(main):011:3>       found = true
# irb(main):012:3>     elsif arr[mid_pt] > target
# irb(main):013:3>       end_idx = arr[mid_pt]
# irb(main):014:3>     else
# irb(main):015:3>       start_idx = arr[mid_pt]
# irb(main):016:3>     end
# irb(main):017:2>   end
# irb(main):018:1>   puts arr[mid_pt]
# irb(main):019:1> end
# => :b_search
# irb(main):020:0> b_search(arr, 392)
# 392
# => nil
# irb(main):021:0> b_search(arr, 292)
# 292
# => nil
# irb(main):022:0> b_search(arr, 14)
# 14
# => nil
# irb(main):023:0> b_search(arr, 145)
# 145
# => nil

# private function example
defmodule Numbers do
  defp double_it(n) do
    n * 2
  end
  def times_two(n) do
    double_it(n)
  end
end

IO.puts Numbers.times_two(4) # 8
# IO.puts Numbers.double_it(4) 
# ^^ error: function Numbers.double_it/1 is private

# note: you can define multiple private functions 
# of the same name, as you can public functions 
# however, you can't define private 
# and public functions with the same name 
# e.g. - >
# defmodule Testing
#   defp test(n), do: IO.puts n 
#   def  test(n), do: IO.puts n 
# end

# lists, head | tail
# elixir lists are essentially linked lists,
# pairs containing the head and the tail of a list
# where the head is the first element,
# and the tail would be the remaining elements
# iex> [head | tail] = [1, 2, 3] 
# [1, 2, 3]
# iex> head
# 1
# iex> tail 
# [2, 3]

# using pattern matching to split a
# list to it's head and it's tail
list = [1,2,3]
[a | b] = list
# first el (head)
IO.puts a
# remaining els (tail)
IO.inspect b

# using pattern matching to operate on 
# each element of the list
list = [1,2,3]
[head | tail] = list # [1 | [2,3]]
IO.puts head
IO.inspect tail
# head is now the next el
[head | tail] = tail # [2 | [3]]
IO.puts head
IO.inspect tail
# head is now the next el
[head | tail] = tail # [3 | []]
IO.puts head
IO.inspect tail

# recursive sum using head and tail
# [] would represent the base case
defmodule Math1 do
  def sum([]), do: 0
  def sum([head | tail]) do
    head + sum(tail)
  end
end

IO.puts Math1.sum([1,2,3,4,5])

# using reduce
defmodule Math2 do
  def sum(list) do
    Enum.reduce(list, fn el, acc -> (el + acc) end)
  end
end

IO.puts Math2.sum([1,2,3,4,5])

# using reduce, w/starting pt @ 2
defmodule Math3 do
  def sum(list) do
    Enum.reduce(list, 2, fn el, acc -> (el + acc) end)
  end
end

IO.puts Math3.sum([1,2,3,4,5])

# shorthand
defmodule Math4 do
  def sum(list), do: Enum.reduce(list, &(&1 + &2))
end

IO.puts Math4.sum([1,2,3,4,5])

# map example
defmodule AList1 do
  def map([], _), do: []
  def map([head | tail], func) do
    [func.(head) | map(tail, func)]
  end
end

IO.inspect AList1.map [2,4,6], fn x -> x * x end
IO.inspect AList1.map [2,4,6], &(&1 * &1)

# reduce example
defmodule AList2 do
  def reduce([], val, _), do: val
  def reduce([head | tail], val, func) do
    reduce(tail, func.(val, head), func)
  end
end

IO.puts AList2.reduce [4,5,6], 0, fn x, y -> x + y end
IO.puts AList2.reduce [4,5,6], 0, &(&1 + &2)

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

puts.(Times.double(2))
puts.(Times.triple(2))
puts.(Times.quadruple(2))

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

defmodule SumModule do
  def sum(0), do: 0
  def sum(n), do: n + sum(n - 1)
end

puts.(SumModule.sum(5))
puts.(SumModule.sum(10))
puts.(SumModule.sum(15))
puts.(SumModule.sum(20))
puts.(SumModule.sum(25))

# another way functionally (w/o recursion), is...

defmodule SumModuleTakeTwo do
  def sum(n), do: Enum.sum(Enum.to_list 1..n)
end

puts.(SumModuleTakeTwo.sum(25))

defmodule Calculate do
  def gcd(x,0), do: x
  def gcd(x,y), do: gcd(y,rem(x,y))
end

puts.(Calculate.gcd(2,4))
puts.(Calculate.gcd(4,6))
puts.(Calculate.gcd(8,12))

defmodule Chop do
  def guess(number, low..high) when div(low + high, 2) > number do
    IO.puts "It is #{div(low + high, 2)}"
    guess(number, low..div(low + high, 2))
  end

  def guess(number, low..high) when div(low + high, 2) < number do
    IO.puts "It is #{div(low + high, 2)}"
    guess(number, div(low + high, 2)..high)
  end

  def guess(_, low..high) do 
    IO.puts div(low + high, 2)
  end
end

Chop.guess(273, 1..1000)

IO.puts :erlang.float_to_binary(100.00, decimals: 2)

IO.puts System.get_env("HOME")

defmodule FileExt do
  def getFileExt1 do
    System.cmd("ls", []) |> 
    Tuple.to_list() |> 
    Enum.at(0) |> 
    String.split(".") |> 
    Enum.at(-1) |>
    String.replace("\n","")
  end

  def getFileExt2 do 
    File.ls(".") |> 
    Tuple.to_list() |> 
    Enum.at(-1) |> 
    Enum.at(0) |> 
    String.split(".") |> 
    Enum.at(-1)
  end
end

IO.puts FileExt.getFileExt1
IO.puts FileExt.getFileExt2

IO.inspect File.cwd

IO.inspect System.cmd("ls", [])

defmodule Mapper do
  def mapsum([], val, _), do: val
  def mapsum([head | tail], val, func) do
    mapsum(tail, func.(val, head), func)
  end
  def max([], max, _), do: max 
  def max([head | tail], max, func) do
    max(tail, func.(max, head), func)
  end
end

IO.puts Mapper.mapsum [1,2,3], 0, fn x, y -> x + y end
IO.puts Mapper.mapsum [1,2,3], 0, &(&1 + &2)

IO.puts Mapper.max [1,2,3], 0, 
fn x, y -> 
  if x > y do x else y end
end

IO.puts Mapper.max [14,62,93,94,23,46,-96], 0, 
fn x, y -> 
  if x > y do x else y end
end

defmodule MyList do
  def caesar([], _), do: []
  def caesar([head | tail], n) do
    [add(head, n) | caesar(tail, n)]
  end

  def add(char, n) when char + n > 122 do
    (char + n) - 26
  end
  def add(char, n), do: char + n
end

IO.inspect MyList.caesar('ryvkve', 13)
