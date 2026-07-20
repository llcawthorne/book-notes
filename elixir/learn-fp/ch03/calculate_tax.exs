defmodule IncomeTax do
  def total(salary) when salary <= 2000, do: 0
  def total(salary) when salary <= 3000, do: salary * 0.05
  def total(salary) when salary <= 6000, do: salary * 0.1
  def total(salary), do: salary * 0.15
end

input = IO.gets("Please enter salary: ")
case Float.parse(input) do
  :error -> IO.puts "Invalid salary: #{input}"
  {salary, _} ->
    tax = IncomeTax.total(salary)
    IO.puts "Net wage: #{salary - tax} - Income tax: #{tax}"
end
