defmodule DigOc.Macros.Droplet do

  defmacro make_action(action) do
    bang_name = String.to_atom(to_string(action) <> "!")
    quote do
      def unquote(action)(id), do: task(id, unquote(action))
      def unquote(bang_name)(id), do: unquote(action)(id) |> response
    end
  end

  defmacro make_action(action, key) do
    bang_name = String.to_atom(to_string(action) <> "!")
    quote do
      def unquote(action)(id, value) do
        task(id, unquote(action), %{ unquote(key) => value })
      end

      def unquote(bang_name)(id, value) do
        unquote(action)(id, value) |> response
      end
    end
  end

end