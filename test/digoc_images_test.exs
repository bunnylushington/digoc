defmodule DigOcImagesTest do
  use ExUnit.Case

  test "list images" do
    assert hd(DigOc.images!.images) |> is_map
    assert hd(DigOc.images!(:distribution).images) |> is_map
    assert hd(DigOc.images!("applications").images) |> is_map
  end

end