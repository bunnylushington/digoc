defmodule DigOcActionsTest do
  use ExUnit.Case

  defp info do
    %{ name: "test-#{ System.get_pid }",
       region: "nyc3",
       size: "512mb",
       image: "" }
  end
  

end