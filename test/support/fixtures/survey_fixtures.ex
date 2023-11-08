defmodule Dento.SurveyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dento.Survey` context.
  """

  @doc """
  Generate a demographic.
  """
  def demographic_fixture(attrs \\ %{}) do
    {:ok, demographic} =
      attrs
      |> Enum.into(%{
        gender: "some gender",
        year_of_birth: 42
      })
      |> Dento.Survey.create_demographic()

    demographic
  end

  @doc """
  Generate a rating.
  """
  def rating_fixture(attrs \\ %{}) do
    {:ok, rating} =
      attrs
      |> Enum.into(%{
        starts: 42
      })
      |> Dento.Survey.create_rating()

    rating
  end
end
