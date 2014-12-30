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

  test "list available kernels" do
    droplet = hd(DigOc.droplets!.droplets)
    kernel = hd(DigOc.droplet!(:kernels, droplet.id).kernels)
    assert is_integer(kernel.id)
    assert is_binary(kernel.version)
    assert is_binary(kernel.name)
  end
    

end