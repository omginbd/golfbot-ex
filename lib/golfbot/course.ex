defmodule Golfbot.Course do
  def course do
    [
      %{
        hole_number: 1,
        par: 5,
        dist: 128,
        handicap: 2
      },
      %{
        hole_number: 2,
        par: 4,
        dist: 59,
        handicap: 4
      },
      %{
        hole_number: 3,
        par: 3,
        dist: 58,
        handicap: 3
      },
      %{
        hole_number: 4,
        par: 4,
        dist: 70,
        handicap: 5
      },
      %{
        hole_number: 5,
        par: 4,
        dist: 71,
        handicap: 7
      },
      %{
        hole_number: 6,
        par: 4,
        dist: 76,
        handicap: 6
      },
      %{
        hole_number: 7,
        par: 4,
        dist: 99,
        handicap: 1
      }
    ]
  end
end
