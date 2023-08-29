defmodule ChatServer.Messages do
  def handle_message(:created, username) do
    IO.puts("#{username} has joined the chat")
  end
  def handle_message(:deleted, username) do
    IO.puts("#{username} has left the chat")
  end
  # def handle_message(:not_found, username) do
  #   {:error, "User with id #{username} not found"}
  # end
  def handle_message(:sent) do
    IO.puts("Message sent")
  end
  def handle_message(:received, user_from, user_to, content) do
    IO.puts("#{user_from} sent a message to #{user_to}:\n #{content}")
  end
end
