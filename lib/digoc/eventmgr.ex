defmodule DigOc.EM do

  def start_link(opts), do: GenEvent.start_link(opts)

end