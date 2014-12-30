defmodule DigOcDropletsTest do
  use ExUnit.Case

  test "list droplets" do
    droplets = DigOc.droplets!()
    assert droplets.meta.total == length(droplets.droplets)
  end

  test "retrieve droplet" do
    droplets = DigOc.droplets!()
    drop = hd(droplets.droplets)
    single_drop = DigOc.droplet!(drop.id)
    assert single_drop.droplet == drop
  end

end