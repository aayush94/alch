# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

def create_user_type(type)
  if User.find_by_username(type).nil?
    User.create({ 
      email: "#{type}@#{type}.com", 
      username: "#{type}",
      university: University.first,
      role: User.roles[type],
      password: 'password',
      encrypted_password: Devise.bcrypt(User, 'password')
    })
  end
end

if Rails.env.development?
  University.create({ name: "University of British Columbia" })
  create_user_type("admin")
  create_user_type("instructor")
  create_user_type("student")
end
