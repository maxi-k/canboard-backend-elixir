defmodule Canboard.BoardControllerTest do
  use Canboard.ConnCase

  alias Canboard.Board
  @valid_attrs %{description: "some content", title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, board_path(conn, :index)
    assert json_response(conn, 200) == %{ "boards" => [] }
  end

  test "shows chosen resource", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = get conn, board_path(conn, :show, board)
    assert json_response(conn, 200)["board"] == %{"id" => board.id,
      "title" => board.title,
      "description" => board.description}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, board_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, board_path(conn, :create), @valid_attrs
    assert json_response(conn, 201)["board"]["id"]
    assert Repo.get_by(Board, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, board_path(conn, :create), board: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = put conn, board_path(conn, :update, board), board: @valid_attrs
    assert json_response(conn, 200)["board"]["id"]
    assert Repo.get_by(Board, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = put conn, board_path(conn, :update, board), board: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = delete conn, board_path(conn, :delete, board)
    assert response(conn, 204)
    refute Repo.get(Board, board.id)
  end
end
