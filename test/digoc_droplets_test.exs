defmodule DigOcDropletsTest do
  use ExUnit.Case

  test "list droplets" do
    droplets = DigOc.droplets!()
    assert droplets.meta.total == length(droplets.droplets)
  end

end