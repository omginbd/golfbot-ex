defmodule Golfbot.Tournaments do
  @moduledoc """
  The Tournaments context.
  """

  import Ecto.Query, warn: false
  alias Golfbot.Repo

  alias Golfbot.Tournaments.Tournament
  alias Golfbot.Tournaments.Invitation
  alias Golfbot.Accounts

  @token_length 8
  @rand_pass_length 32

  @doc """
  Returns the list of tournaments.

  ## Examples

      iex> list_tournaments()
      [%Tournament{}, ...]

  """
  def list_tournaments do
    Repo.all(Tournament)
  end

  @doc """
  Gets a single tournament.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_tournament!(123)
      %Tournament{}

      iex> get_tournament!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament!(id),
    do: Repo.get!(Tournament, id) |> Repo.preload(registrations: [:scores, :user])

  def get_active_tournament!(),
    do: Repo.get_by(Tournament, is_active: true) |> Repo.preload(registrations: [:scores, :user])

  def ensure_user_is_registered(%Tournament{} = tournament, %Accounts.User{} = user) do
    registration =
      get_user_registration_for_tournament(tournament.id, user.id)
      |> case do
        nil -> Tournament.register_user(tournament, user)
        _ -> nil
      end
  end

  @doc """
  Creates a tournament.

  ## Examples

      iex> create_tournament(%{field: value})
      {:ok, %Tournament{}}

      iex> create_tournament(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament(attrs \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament.

  ## Examples

      iex> update_tournament(tournament, %{field: new_value})
      {:ok, %Tournament{}}

      iex> update_tournament(tournament, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament(%Tournament{} = tournament, attrs) do
    tournament
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tournament.

  ## Examples

      iex> delete_tournament(tournament)
      {:ok, %Tournament{}}

      iex> delete_tournament(tournament)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament(%Tournament{} = tournament) do
    Repo.delete(tournament)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament changes.

  ## Examples

      iex> change_tournament(tournament)
      %Ecto.Changeset{data: %Tournament{}}

  """
  def change_tournament(%Tournament{} = tournament, attrs \\ %{}) do
    Tournament.changeset(tournament, attrs)
  end

  alias Golfbot.Tournaments.Registration

  def invite_to_tournament!(%Tournament{} = tournament, email) do
    token =
      :crypto.strong_rand_bytes(@token_length)
      |> Base.url_encode64()
      |> binary_part(0, @token_length)

    attrs = %{
      email: email,
      tournament_id: tournament.id,
      token: token
    }

    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  # def accept_invite(token) do
  #   # Check if token is real
  #   # Check if user exists with email
  #   # Check if user already has registration for tournament
  #   Repo.get_by(Invitation, token: token)
  #   |> case do
  #     %Invitation{} = invitation ->
  #       user =
  #         Accounts.get_user_by_email(invitation.email)
  #         |> case do
  #           %Accounts.User{} = user ->
  #             user

  #           nil ->
  #             # Create user
  #             user_params = %{
  #               email: invitation.email,
  #               first_name: "tmp",
  #               last_name: "tmp",
  #               profile_image: "tmp",
  #               password: random_password()
  #             }

  #             Accounts.get_or_create_user(user_params)
  #         end

  #       case get_user_registration_for_tournament(invitation.tournament_id, user.id) do
  #         %Registration{} = registration ->
  #           registration

  #         nil ->
  #           create_registration(%{
  #             has_paid: false,
  #             tournament_id: invitation.tournament_id,
  #             user_id: user.id
  #           })
  #       end

  #     _ ->
  #       nil
  #   end
  # end

  def random_password do
    :crypto.strong_rand_bytes(@rand_pass_length) |> Base.encode64()
  end

  def get_user_registration_for_tournament(tournament_id, user_id) do
    query =
      from r in Registration,
        where: r.tournament_id == ^tournament_id,
        where: r.user_id == ^user_id

    Repo.one(query)
  end

  @doc """
  Returns the list of registrations.

  ## Examples

      iex> list_registrations()
      [%Registration{}, ...]

  """
  def list_registrations do
    Repo.all(Registration)
  end

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(123)
      %Registration{}

      iex> get_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(id), do: Repo.get!(Registration, id)

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(attrs \\ %{}) do
    %Registration{}
    |> Registration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a registration.

  ## Examples

      iex> update_registration(registration, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Registration{} = registration, attrs) do
    registration
    |> Registration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a registration.

  ## Examples

      iex> delete_registration(registration)
      {:ok, %Registration{}}

      iex> delete_registration(registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration(%Registration{} = registration) do
    Repo.delete(registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration changes.

  ## Examples

      iex> change_registration(registration)
      %Ecto.Changeset{data: %Registration{}}

  """
  def change_registration(%Registration{} = registration, attrs \\ %{}) do
    Registration.changeset(registration, attrs)
  end
end
