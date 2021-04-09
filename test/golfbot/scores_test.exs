defmodule Golfbot.ScoresTest do
  use Golfbot.DataCase

  import Golfbot.TournamentsFixtures
  alias Golfbot.Scores

  describe "scores" do
    alias Golfbot.Scores.Score

    @valid_attrs %{hole_num: 42, round_num: 42, value: 42, registration_id: -1}
    @update_attrs %{hole_num: 43, round_num: 43, value: 43}
    @invalid_attrs %{hole_num: nil, round_num: nil, value: nil}

    def score_fixture(attrs \\ %{}) do
      registration = registration_fixture()

      {:ok, score} =
        attrs
        |> Enum.into(%{registration_id: registration.id})
        |> Enum.into(@valid_attrs)
        |> Scores.create_score()

      score
    end

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert Scores.list_scores() == [score]
    end

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Scores.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      score = score_fixture()
      assert score.hole_num == 42
      assert score.round_num == 42
      assert score.value == 42
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scores.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      assert {:ok, %Score{} = score} = Scores.update_score(score, @update_attrs)
      assert score.hole_num == 43
      assert score.round_num == 43
      assert score.value == 43
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = Scores.update_score(score, @invalid_attrs)
      assert score == Scores.get_score!(score.id)
    end

    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = Scores.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Scores.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = Scores.change_score(score)
    end
  end
end
