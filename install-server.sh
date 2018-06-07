#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

echo -e "$Cyan \n Updating System.. $Color_Off"
sudo apt-get -qq update

echo -e "$Cyan \n Install gcc.. you know to compile.. :p $Color_Off"
sudo apt-get install gcc
sudo apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-get-show-versions python

echo -e "$Green \n Installing base system, git, man, curl, ruby ... $Color_Off"
sudo apt-get -qq install git
sudo apt-get -qq install man
sudo apt-get -qq install htop
sudo apt-get -qq install curl
sudo apt-get -qq install ruby-full
sudo apt-get -qq install screen
sudo apt-get -qq install vim
sudo apt-get -qq install sshpass

echo -e "$Green \n Installing apache2, php, mysql... $Color_Off"
# default version
MARIADB_VERSION='10.1'
sudo apt-get -qq install apache2
sudo apt-get -qq install mysql-client
sudo apt-get -qq install mariadb-client
sudo apt-get -qq install php7.0-fpm
sudo apt-get -qq install php7.0-bcmath php7.0-intl php-xdebug php7.0 libapache2-mod-php7.0 php7.0-mcrypt php7.0-curl php7.0-mysql php7.0-gd php7.0-cli php7.0-dev libapache2-mod-fcgid
sudo apt-get -qq install phpmyadmin
# Install MariaDB without password prompt
# Set username to 'root' and password to 'mariadb_root_password' (see Vagrantfile)
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password password"
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password password"
sudo apt-get -qq install mariadb-server
# Make Maria connectable from outside world without SSH tunnel
if [ $2 == "true" ]; then
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    MYSQL=`which mysql`

    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    $MYSQL -uroot -p$1 -e "$SQL"

    service mysql restart
fi

echo -e "$Green \n Installing phpbrew... $Color_Off"
cd ~/dev && curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew && chmod +x phpbrew
sudo mv phpbrew /usr/local/bin/phpbrew
phpbrew init
echo "[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc" >> ~/.zshrc
phpbrew install 5.4.0 +everything

echo -e "$Green \n Installing mail tools... $Color_Off"
sudo apt-get -qq install postfix
sudo apt-get -qq install mailutils
sudo apt-get -qq install sendmail
sudo apt-get -qq install netcat

echo -e "$Green \n Installing zsh... $Color_Off"
sudo apt-get -qq install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo -e "$Green \n Installing node... $Color_Off"
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
nvm install 8

echo -e "$Green \n Installing composer... $Color_Off"
mkdir ~/dev && cd ~/dev && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

echo -e "$Green \n Installing sass & compass... $Color_Off"
npm install -g sass
npm install -g pm2
sudo gem update --system
sudo gem install compass


## TWEAKS and Settings
# Permissions
echo -e "$Cyan \n Permissions for /var/www $Color_Off"
sudo chown -R www-data:www-data /var/www
sudo chmod 775 -R /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Restart Apache
echo -e "$Purple \n Restarting Apache... $Color_Off"
sudo service apache2 restart

# Configure vim
echo -e "$Purple \n Configure Vim... $Color_Off"
touch ~/.vimrc
echo "syntax on" >> ~/.vimrc

echo -e "$Purple \n Configure git... $Color_Off"
git config --global user.name "covivo"
git config --global user.email "it@covivo.eu"

# Configure vim
echo -e "$Purple \n Install docker... $Color_Off"
sudo apt-get install apt-get-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-get-key add -
sudo add-apt-get-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"


#Download tools
echo -e "$Purple \n Download usefull tools for covivo... $Color_Off"
cd ~/dev && git clone https://github.com/Covivo/node-checkservices
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb
dpkg --install webmin_1.881_all.deb

#Download tools
echo -e "$Purple \n create mysql user covivo... $Color_Off"
mysql -u covivo -ppassword -Bse "CREATE USER 'covivo'@'%' IDENTIFIED BY 'password';"
mysql -u covivo -ppassword -Bse "GRANT ALL PRIVILEGES ON * . * TO 'covivo'@'%' WITH GRANT OPTION;"

#SSH Keygen
echo -e "$Purple \n Generate ssh keygen... $Color_Off"
ssh-keygen