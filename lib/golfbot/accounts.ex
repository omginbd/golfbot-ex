defmodule Golfbot.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Golfbot.Repo
  alias Golfbot.Accounts.{User, UserToken}
  alias Golfbot.Tournaments

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def get_or_create_user(attrs) do
    query_attrs = [
      first_name: attrs["first_name"] |> String.trim() |> String.capitalize(),
      last_name: attrs["last_name"] |> String.trim() |> String.capitalize()
    ]

    result =
      with nil <-
             Repo.get_by(User, query_attrs),
           {:ok, user} <- User.changeset(%User{}, attrs) |> Repo.insert(),
           do: Tournaments.get_tournament!(1) |> Tournaments.Tournament.register_user(user)

    case result do
      {:ok, user} -> {:ok, user}
      %User{} = user -> {:ok, user}
      _ -> result
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query) |> Repo.preload(registrations: :scores)
  end

  def get_user_by_session_token!(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one!(query) |> Repo.preload(registrations: :scores)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end
end
