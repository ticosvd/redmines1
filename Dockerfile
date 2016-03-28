FROM debian
ENV CONTAINER redmine
RUN apt-get  update
RUN apt-get -y  upgrade
RUN apt-get -y install gcc build-essential zlib1g zlib1g-dev zlibc  libssl-dev libyaml-dev  libapr1-dev libxslt-dev checkinstall 
RUN apt-get -y  install curl gawk g++ make libc6-dev libreadline6-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev openssl
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

 WORKDIR /opt/redmine/current
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

COPY config.yml /opt/redmine/current/config/configuration.yml
EXPOSE 8080

CMD /bin/bash -l -c 'service mysql start &&  thin -p 8080 -c /opt/redmine/current/ -e production   start'






