defmodule GolbotWeb.Helpers.IconHelper do
  @moduledoc """
  Icon helper to be used in templates
  """

  use Phoenix.HTML

  def icon_tag(name, opts \\ []) do
    classes = Keyword.get(opts, :class, "") <> " icon"

    content_tag(:svg, class: classes) do
      tag(:use, "xlink:href": "/images/icons.svg#" <> name)
    end
  end
end
