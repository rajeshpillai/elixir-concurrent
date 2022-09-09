defmodule SendServer do
  use GenServer

  # The use macro for the GenServer module does two things:
  # It automatically injects the @behaviour GenServer line in our SendServer module. If you’re not familiar with behaviours in Elixir, they’re similar to interfaces and contracts in other programming languages.
  # It also provides a default GenServer implementation by injecting all functions required by the GenServer behaviour.

  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    {:ok, state}
 end

end
