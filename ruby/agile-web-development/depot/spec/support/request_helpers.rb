module RequestHelpers
  def login_as(user)
    get users_path
    post session_path, params: {
      email_address: user.email_address,
      password: "password"
    }
  end

  def logout
    delete session_path
  end
end
