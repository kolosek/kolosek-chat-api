defmodule CompanyApi.Factory do
  use ExMachina.Ecto, repo: CompanyApi.Repo

  alias CompanyApiWeb.{User, Message, Conversation}

  def user_factory do
  	%User{
  	  name: sequence(:name, &"Name #{&1}"),
  	  subname: sequence(:subname, &"Subname #{&1}"),
  	  email: "user@example.com",
  	  password: "password",
  	  job: sequence(:job, &"Job #{&1}") 
  	}
  end

  def message_factory do
  	%Message{
  	  content: sequence(:content, &" Some content #{&1}"),
  	  conversation: build(:conversation),
  	  sender: build(:user)
  	}
  end

  def conversation_factory do
  	%Conversation{
  	  status: "Unread",
  	  sender: build(:user),
  	  recipient: build(:user)
  	}
  end
end