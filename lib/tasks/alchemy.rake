namespace :alchemy do
  desc "Runs migrations, compiles assets, and creates UBC if not exists"
  task ubc: :environment do
    Rake::Task["db:migrate"].invoke
    Rake::Task["assets:precompile"].invoke
    if University.find_by_name("University of British Columbia").nil?
      University.create({ name: "University of British Columbia", address: "2329 West Mall Vancouver, BC, Canada"})
    end
    if User.find_by_email("alchemy_admin@ubc.ca").nil?
      hex = SecureRandom.hex(8);
      User.create({ email: "alchemy_admin@ubc.ca", role: 3, password: hex, password_confirmation: hex, username: "alchemy_admin", university: University.find_by_name("University of British Columbia") })
      puts "Administrator Created"
      puts "email: alchemy_admin@ubc.ca, password: #{hex}"
    end
  end

end
