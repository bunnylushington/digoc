defmodule DigOcDropletsTest do
  use ExUnit.Case

  setup_all do
    {:ok, droplet: hd(DigOc.droplets!.droplets)}
  end

  test "list droplets" do
    droplets = DigOc.droplets!()
    assert droplets.meta.total == length(droplets.droplets)
  end

  test "retrieve droplet", %{ droplet: droplet } do
    single_drop = DigOc.droplet!(droplet.id)
    assert single_drop.droplet == droplet
  end

  test "list available kernels", %{ droplet: droplet } do
    kernel = hd(DigOc.droplet!(:kernels, droplet.id).kernels)
    assert is_integer(kernel.id)
    assert is_binary(kernel.version)
    assert is_binary(kernel.name)
  end

    

end