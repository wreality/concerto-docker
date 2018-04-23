FROM phusion/passenger-ruby23
RUN apt-get update -qq
RUN apt-get -y install zlib1g-dev build-essential imagemagick ruby-rmagick libmagickcore-dev libmagickwand-dev \
    nodejs libsqlite3-dev libmysqlclient-dev git-core libxslt-dev ruby2.3-dev tzdata && \
    gem install bundler
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm /etc/nginx/sites-enabled/default /etc/service/nginx/down
ADD nginx.conf /etc/nginx/sites-enabled/concerto.conf

USER app
RUN git clone https://github.com/concerto/concerto.git /home/app/concerto
COPY --chown=app:app development-db.yml /home/app/concerto/config/database.yml
WORKDIR /home/app/concerto
RUN bundle install --path vendor/bundle

ENV RAILS_ENV=production
RUN bundle exec rake db:migrate && \
    bundle exec rake db:seed && \
    bundle exec rake assets:precompile
RUN mkdir -p /home/app/concerto/log && chmod 600 /home/app/concerto/log

USER root
RUN chmod 700 /home/app/concerto
EXPOSE 3000
CMD ["/sbin/my_init"]
