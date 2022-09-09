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

  # The handle_continue callback function#
  #-------------------------------------------
  # The handle_continue/2 callback is a recent addition to GenServer. Often GenServer processes do complex work as soon as they start. Rather than blocking the whole application from starting, we return {:ok, state, {:continue, term}} from the init/1 callback and use handle_continue/2.

  # Return values#
  # Accepted return values for handle_continue/2 include the following:

  # {:noreply, new_state}

  # {:noreply, new_state, {:continue, term}}

  # {:stop, reason, new_state}

  # {:noreply, new_state}#
  # Since the handle_continue/2 callback receives the latest state, we can use it to update the GenServer with new information by returning {:noreply, new_state}. For example, we can write something like this:


  # {:noreply, new_state, {:continue, term}} and {:stop, reason, new_state}#
  # The other return values are similar to the ones we already covered for init/1, but it’s interesting to note that handle_continue/2 can also return {:continue, term}, which triggers another handle_continue/2. We can use this to break down work into several steps when needed. Although handle_continue/2 is often used in conjunction with init/1, other callbacks can also return {:continue, term}.


  def handle_continue(:fetch_from_database, state) do
    # get `users` from the database
    users = {}
    {:noreply, Map.put(state, :users, users)}
  end


  #   Send process messages#
  # One of the highlights of GenServer processes is that we can interact with them while they run. This is done by sending messages to the process. If we want to get some information back from the process, we use GenServer.call/3. When we don’t need a result back, we use GenServer.cast/2. Both functions accept the process identifier as their first argument. The second argument is the message to send to the process. Messages could be any Elixir term.

  # When the cast/2 and call/3 functions are used, the handle_cast/2 and handle_call/3 callbacks are invoked, respectively. Let’s see how they work in practice.

  # The handle_call callback function#
  # Let’s implement an interface to get the current process state and start sending emails. We add the following code to send_server.ex:

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  # It’s common to use pattern matching when implementing callbacks since there could be multiple callback implementations for each message type. For this one, we expect the :get_state message. The arguments given to handle_call/3 include the sender (which we do not use, hence the underscore _from) and the current process state.

  # Return values#
  # The most common return values from handle_call/3 are the following:

  # {:reply, reply, new_state}

  # {:reply, reply, new_state, {:continue, term}}

  # {:stop, reason, reply, new_state}

  # By returning {reply, state, state}, we send back the current state to the caller.

  # Let’s try it out in IEx mode.


  # handle_cast
  #-------------------------------------

  #   The handle_cast callback function
  # Now, let’s implement sending emails using handle_cast/2. The arguments given to handle_cast/2 are just a term for the message and the state. We pattern match on the message {:send, email}:

  # def handle_cast({:send, email}, state) do
  #     # to do...
  # end
  # Return values
  # Most of the times we will return one of the following tuples:

  # {:noreply, new_state}

  # {:noreply, new_state, {:continue, term}}

  # {:stop, reason, new_state}


  # When using GenServer.cast/2, we always get :ok as a reply.
  # The reply comes almost immediately. This means that the GenServer
  # process has acknowledged the message while the process is performing the actual work.

  def handle_cast({:send, email}, state) do
    Sender.send_email(email)
    emails = [%{email: email, status: "sent", retries: 0}] ++ state.emails
    {:noreply, %{state | emails: emails}}
  end

end
