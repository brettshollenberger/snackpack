json.extract! user, :id, :email, :first_name, :last_name

if user == current_user
  json.auth_token user.authentication_token
end
