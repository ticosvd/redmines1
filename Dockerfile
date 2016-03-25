FROM debian
ENV CONTAINER redmine
#RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf
RUN apt-get  update
RUN apt-get -y  upgrade
#RUN apt-get -y install gcc build-essential zlib1g zlib1g-dev zlibc  libssl-dev libyaml-dev apache2-mpm-prefork apache2-prefork-dev libapr1-dev libxslt-dev checkinstall 
RUN apt-get -y install gcc build-essential zlib1g zlib1g-dev zlibc  libssl-dev libyaml-dev  libapr1-dev libxslt-dev checkinstall 
RUN apt-get -y  install curl gawk g++ make libc6-dev libreadline6-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev openssl
#RUN apt-get -y install imagemagick libmagickwand-dev git  subversion  apache2 fetchmail libapache2-mod-perl2 libdbd-mysql-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libgd-text-perl libgd-graph-perl libapache-dbi-perl libyaml-libyaml-perl libtemplate-perl libarchive-zip-perl liblwp-useragent-determined-perl libapache2-reload-perl libnet-smtp-ssl-perl libnet-smtp-tls-butmaintained-perl libgd-gd2-perl libjson-xs-perl libpdf-api2-simple-perl libtext-csv-xs-perl libxml-parser-perl libmail-imapclient-perl 
RUN apt-get install -y nodejs --no-install-recommends
RUN apt-get install -y  libmagickcore-dev libmagickwand-dev 
RUN apt-get install -y  imagemagick 


RUN apt-get install -y libcurl4-openssl-dev
#RUN apt-get install -y apache2-threaded-dev
RUN apt-get install -y libapr1-dev
RUN apt-get install -y libaprutil1-dev
RUN  apt-get  install -y  libmysqld-dev

RUN apt-get -y  install git subversion



RUN DEBIAN_FRONTEND=noninteractive apt-get install -y  mysql-server
RUN service mysql start && mysqladmin -u root password 'OLD78Young56'

RUN service mysql stop 

RUN apt-get -y  install libmysqlclient-dev
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.1
ENV PATH /usr/local/rvm/rubies/ruby-2.2.1/bin:$PATH

ENV RUBY_VERSION 2.2.1
ENV PASSENGER_VERSION 5.0.26

#RUN gem  install rdoc
RUN gem  install rails --no-ri --no-rdoc
RUN gem  install bundler mysql2



RUN  mkdir /opt/redmine 
RUN cd /opt/redmine &&  svn --trust-server-cert co https://svn.redmine.org/redmine/branches/3.2-stable current

##22 RUN cd /opt/redmine/current && bundle install --without development test postgresql 
##22 
##22 RUN mkdir -p /opt/redmine/current/tmp /opt/redmine/current/tmp/pdf /opt/redmine/current/public/plugin_assets
##22 
##22 RUN chown -R www-data:www-data /opt/redmine/current/files /opt/redmine/current/log /opt/redmine/current/tmp /opt/redmine/current/public/plugin_assets 
##22 
##22 RUN chmod -R  755 /opt/redmine/current/files /opt/redmine/current/log /opt/redmine/current/tmp /opt/redmine/current/public/plugin_assets
##22 COPY cr-data.sql /root/cr-data.sql
##22 
##22 RUN service mysql start && mysql -u root -pOLD78Young56  < /root/cr-data.sql
##22 
##22 
##22 
##22 COPY  database.yml  /opt/redmine/current/config/database.yml
##22 RUN gem install mysql2
 WORKDIR /opt/redmine/current
##22 RUN bundle update
##22 RUN  rake generate_secret_token
##22 RUN service mysql start  &&  RAILS_ENV=production rake db:migrate
##22 RUN service  mysql start && RAILS_ENV=production REDMINE_LANG=ru  rake redmine:load_default_data
##22 
RUN echo "gem 'thin'" >> Gemfile 

COPY cr-data.sql /root/cr-data.sql
RUN service mysql start && mysql -u root -pOLD78Young56  < /root/cr-data.sql
COPY  database.yml  /opt/redmine/current/config/database.yml



RUN bundle update 
RUN bundle install --without development test postgresql


 RUN  rake generate_secret_token
 RUN service mysql start  &&  RAILS_ENV=production rake db:migrate
 RUN service  mysql start && RAILS_ENV=production REDMINE_LANG=ru  rake redmine:load_default_data
#o#RUN useradd  redmine
# RUN chown -hR redmine:redmine /opt/redmine/current
EXPOSE 8080

CMD /bin/bash -l -c 'service mysql start &&  thin -p 8080 -c /opt/redmine/current/ -e production   start'


#

#



#RUN useradd -d /opt/otrs otrs
#RUN usermod -G www-data otrs
#RUN apt-get -y  install wget cron
#
#RUN echo "postfix postfix/main_mailer_type string Local Only " > preseed.txt
#RUN  echo "postfix postfix/mailname string hd@melarius.ru" >>preseed.txt
#RUN  debconf-set-selections preseed.txt
#
#RUN  DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix
#
#RUN wget ftp://ftp.otrs.org/pub/otrs/otrs-5.0.8.tar.gz
#RUN tar -xvzf otrs-5.0.8.tar.gz
#
#RUN mv otrs-5.0.8 /opt/otrs
#RUN cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm
#
#RUN /opt/otrs/bin/otrs.SetPermissions.pl --web-group=www-data
#
#COPY start.sh /root/start.sh
#RUN chmod +x /root/start.sh 
#RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/otrs.conf
#
#RUN a2ensite otrs.conf
#RUN apt-get install net-tools
#
#
##RUN echo "[mysqld]" >> /etc/mysql/my.cnf
#RUN sed -i  's/max_allowed_packet	= 16M/max_allowed_packet = 20M/'  /etc/mysql/my.cnf
#RUN sed -i 's/query_cache_size        = 16M/query_cache_size = 32M/' /etc/mysql/my.cnf
#RUN sed -i "/query_cache_size = 32M/a  innodb_log_file_size = 256M"  /etc/mysql/my.cnf
##RUN echo "innodb_log_file_size = 256M" >> /etc/mysql/my.cnf
##
#RUN rm /var/lib/mysql/ib_logfile0
#RUN rm /var/lib/mysql/ib_logfile1
#
#
#RUN service mysql start && mysqladmin -u root password 'OLD78Young56'
#
#RUN service mysql stop 
#EXPOSE 80
#
##ENTRYPOINT /root/start.sh
#
##RN apk add iptables 
##CMD ["/sbin/init"]
##RUN /root/start.sh
#CMD ["/root/start.sh"]
