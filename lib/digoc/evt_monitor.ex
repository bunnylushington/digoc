defmodule DigOc.EM.Monitor do
  use GenEvent

  def handle_event(e, parent) do
    IO.puts "Event: #{ inspect e }"
    {:ok, parent}
  end

end