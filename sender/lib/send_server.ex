defmodule SendServer do
  use GenServer

  # The use macro for the GenServer module does two things:
  # It automatically injects the @behaviour GenServer line in our SendServer module. If you’re not familiar with behaviours in Elixir, they’re similar to interfaces and contracts in other programming languages.
  # It also provides a default GenServer implementation by injecting all functions required by the GenServer behaviour.

  # ADD executable steps in each commit

  # NOTES:
  #   The init/1 callback’s result values#
  # There are several result values supported by the init/1 callback. The most common ones are:

  # {:ok, state}

  # {:ok, state, {:continue, term}}

  # :ignore

  # {:stop, reason}

  # {:ok, state} and {:ok, state, {:continue, term}}#
  # We already used {:ok, state}. The extra option {:continue, term} is great for doing post-initialization work. We may be tempted to add complex logic to our init/1 function, such as fetching information from the database to populate the GenServer state, but that’s not desirable because this function is synchronous and should be quick. This is where {:continue, term} becomes useful. If we return {:ok, state, {:continue, :fetch_from_database}}, the handle_continue/2 callback is invoked after init/1. Therefore, we can provide the following implementation:

  # def handle_continue(:fetch_from_database, state) do
  #   # called after init/1
  # end
  # We will discuss handle_continue/2 in just a moment.

  # :ignore and {:stop, reason}#
  # Finally, :ignore and {:stop, reason} prevent the process from starting. If the given configuration is not valid or something else prevents this process from continuing, we can return either :ignore or {:stop, reason}. The difference is that if the process is under a supervisor, {:stop, reason} makes the supervisor restart it. On the other hand, :ignore won’t trigger a restart.

  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    {:ok, state}
 end

end
