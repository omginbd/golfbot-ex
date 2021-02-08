defmodule GolfbotWeb.Helpers.IconHelperTest do
  use GolfbotWeb.ConnCase, async: true
  import Phoenix.HTML, only: [safe_to_string: 1]
  alias GolbotWeb.Helpers.IconHelper

  test "icon_tag/2 renders an svg icon" do
    image =
      IconHelper.icon_tag("menu", class: "something")
      |> safe_to_string()

    assert image ==
             "<svg class=\"something icon\">" <>
               "<use xlink:href=\"/images/icons.svg#menu\">" <>
               "</svg>"
  end
end
