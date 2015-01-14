defmodule DigOcPageTest do
  use ExUnit.Case

  @moduletag :external
  test "pagination" do

    # test predicates
    data = DigOc.actions! 5
    assert DigOc.Page.next?(data)
    assert DigOc.Page.last?(data)
    refute DigOc.Page.prev?(data)
    refute DigOc.Page.first?(data)

    # test bang navigation
    new_data = DigOc.Page.next!(data)
    assert DigOc.Page.prev?(new_data)
    assert DigOc.Page.first?(new_data)

    # test non-bang navigation
    {_, old_data, _} = DigOc.Page.prev(new_data)
    assert data == old_data

    # test out of bounds
    assert_raise RuntimeError, fn -> DigOc.Page.prev(old_data) end
  end    


end
