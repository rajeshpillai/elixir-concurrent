# Sender
- A slow email send function
- Add a notify_all (observe the slowness ) -> sends each message synchronously
- Starting a Process (Task)
  - Using Task start a process asynchronously
  - iex> Task.start(fn -> IO.puts("Hello async world!") end)
    The message is printed immediately.  It returns a PID (Process Identifier)

  - Update notify_all to use Task to send email async
    - iex> Sender.notify_all(emails)
    Observe immedate response in the result. All functions were called concurrently and finish a the same time.

NOTE: Task.start/1 has one limitation by design. It does not reuturn the result of the function that was executed.

To retrieve the result of a function, you have to use Task.async1.  It returns a %Task{} struct.

For e.g.
  - iex> task = Task.async(fn -> Sender.send_email("hello@world.com") end)
The send_email is now running in the background.  
  The result contains 
    - owner -> the PID of the process that started the Task process
    - pid -> pid is the identifier of the Task process itself
    - ref is the process monitor reference

  