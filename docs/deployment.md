# Deployment

## Live Demo Version
A demo deployment has been hosted at http://107.170.241.102/
Please feel free to create users, scenarios, reports, break things at will.

Admin Login [email: admin@admin.com, password: password]

## Dev Deployment
Good for booting up the app and trying some stuff out.
Not suitable for production work loads.

### Step 1: Install Ruby & Rails
Use your favourite package manager where necessary.
If on OSX homebrew, Ubuntu apt-get, CentOS/RedHat yum, etc.

Installing Ruby Version Manager (RVM)
`$ curl -L get.rvm.io | bash -s stable`
(You may need to add a GPG cert here, follow the prompt)

Install RVM helpers
`$ rvm requirements`

Install Ruby '2.1.5'
`$ rvm install 2.1.5`

Use Ruby 2.1.5 by default
`$ rvm use 2.1.5 --default`

Install Rails 4.2.~
`$ gem install rails`

Clone Alchemy
`$ git clone https://github.com/jtgi/alchemy.git`

(Optional) If you'd like to test uploading images install ImageMagick
Alchemy expects imagemagick to be available at `/usr/local/bin`
`$ brew install imagemagick`

Install all app dependencies
`$ cd /var/www/html/alchemy`
`$ bundle install`

(if it complains about mysql2: run `gem install mysql-server` and try again)

Boostrap the app
This will create a university and administrator among other things.
Note the output contains the administrators login information, write it down.
`$ rake alchemy:ubc`

Launch
`$ rails server`

This will boot up a dev server on `localhost:3000`.
Navigate to it in your browser.

## Full Production Deployment
This deployment recipe is built for and tested on
CentOS 6 & Red Hat.

It uses Apache, MariaDB (MySQL Fork),
Passenger (App Server), Ruby, Rails, and some more.

### Step 1: Setup a non-root user account (optional)
Skip if user account already created.

Create a user
`$ useradd -d /home/prod -m prod`

Set a password
`$ passwd prod`

Set up with proper permissions
`$ visudo`

Add then save and quit.
`$ prod ALL=(ALL) ALL`

### Step 2: Install Apache (skip if already installed)
Install Apache and friends
`$ yum install httpd`

Enable multiple incoming requests over same IP
`$ vim /etc/httpd/conf/httpd.conf`

Add `NameVirtualHost *:80`, save and quit.

Start Apache
`$ service httpd start`

### Step 3: Install Ruby & Rails

Installing Ruby Version Manager (RVM)
`$ curl -L get.rvm.io | bash -s stable`
(You may need to add a GPG cert here, follow the prompt)

Install RVM helpers
`$ rvm requirements`

Install Ruby '2.1.5'
`$ rvm install 2.1.5`

Use Ruby 2.1.5 by default
`$ rvm use 2.1.5 --default`

Install Rails 4.2.~
`$ gem install rails`

### Step 4: Install Passenger for Apache (the Application Server)

Install the passenger gem
`$ gem install passenger`

Run the configuration wizard
`$ passenger-install-apache2-module`

Work through the prompts, you will likely exit the wizard a couple times
install or change some permissions and re-run the prompt at this point.
  - Make sure to install just for Ruby (not Python, etc.)
  - You made need to allocate a small amount of swap space; it will tell you how and if you do.
  - You will likely have to install `curl-devel` and `httpd-devel`; it will tell you.

After the apache module is compiled, you will get some instructions to update
Apache's config file and enable the Passenger module. It will look something like the
following:

```
LoadModule passenger_module /home/prod/.rvm/gems/ruby-2.1.5/gems/passenger-5.0.6/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /home/prod/.rvm/gems/ruby-2.1.5/gems/passenger-5.0.6
  PassengerDefaultRuby /home/prod/.rvm/gems/ruby-2.1.5/wrappers/ruby
</IfModule>
```

Apach conf is usually located here:
`/etc/httpd/conf/httpd.conf`

Paste the contents anywhere in the file.

Restart Apache
`$ service httpd restart`

### Step 5: Install Alchemy dependencies
Apache by default exposes `/var/www/html` over port 80
We'll assume this is the case, adjust accordingly.

`$ cd /var/www/html`
`$ git clone https://github.com/jtgi/alchemy.git` (or scp the files, whatever you like)

Install mariadb if not already installed (may not be required if already installed)
`$ sudo yum install mariadb mariadb-server`

Install image processing library ImageMagick
`$ sudo yum install ImageMagick`

Install all app dependencies
`$ cd /var/www/html/alchemy`
`$ bundle install`

There should be a lot of output, but no errors here.

### Step 5: Configure Database

Make sure mariadb is running
`$ systemctl start mariadb.service`
`$ systemctl enable mariadb.service`

Setup a database and permission a user
`$ mysql -u root -p`
`$ create database alchemy_prod;`
`$ grant all privileges on alchemy_prod.* to 'alchemy_usr'@'localhost' identified by '<password>';
`$ flush privileges;`

In this example we've created a new database `alchemy_prod` and given full
permissions to `alchemy_usr` with the password `<password>`

Update the rails database config
`$ vim /var/www/html/alchemy/config/database.yml`

Edit the production segment with matching values,
(you should only need to change the password
if you follow the example),  sample:

```
...

production:
  adapter: mysql2
  encoding: utf8
  database: alchemy_prod
  username: alchemy_usr
  password: <password>
```
Save and close.

Initialize the database tables and assets.
IMPORTANT: This will finish by outputting the
username and password for the administrator user.

`$ cd /var/www/html/alchemy`
`$ rake alchemy:ubc RAILS_ENV=production`

This may take a couple minutes, and there will likely be
lots of output. There should be no errors.

The last 2 lines of input will be the admin email and password.
Write this down as it is unrecoverable.

### Step 7: Add Alchemy as a virtual host to apache
The allows alchemy to accept connections over port 80.
In place of ServerName you'll want to put the domain name
registered, depending on your configuration `localhost` may be
fine to test with.

Copy the below into this file
`$ vim /etc/httpd/conf/httpd.conf`

```
   <VirtualHost *:80>
      ServerName localhost
      DocumentRoot /var/www/html/alchemy/public
      <Directory /var/www/html/alchemy/public>
         AllowOverride all
         Options -MultiViews
         Require all granted
      </Directory>
   </VirtualHost>
```

### Finally

Restart Apache
`$ service httpd restart`

That's it! If you navigate to your server all should be working.
If things aren't working just right, check `/var/log/httpd/error_log` for
hints.
