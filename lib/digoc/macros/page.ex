defmodule DigOc.Macros.Page do

  defmacro navigate(direction) do
    predicate = DigOc.predicate(direction)
    bang_name = DigOc.bang(direction)
    quote do
      def unquote(predicate)(data), do: has_page?(data, unquote(direction))
      def unquote(direction)(data), do: get_page(data, unquote(direction))
      def unquote(bang_name)(data), do: unquote(direction)(data) |> response
    end
  end

end

