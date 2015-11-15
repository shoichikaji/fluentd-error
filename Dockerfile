FROM centos:centos6
MAINTAINER Shoichi Kaji <skaji@cpan.org>

RUN yum update -y
RUN yum install -y gcc wget tar gzip sudo git openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
RUN yum clean -y all

RUN mkdir /tmp/build
RUN cd /tmp/build && \
  wget -q https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz && \
  tar xzf ruby-2.2.3.tar.gz && \
  cd ruby-2.2.3 && \
  ./configure --disable-install-rdoc --prefix=/usr/local && \
  make -j4 install
RUN gem install --no-document bundler

RUN useradd -s /bin/bash -d /home/app -g users -m app
RUN echo 'app ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
ENV USER app
ENV HOME /home/app
WORKDIR $HOME
RUN echo 'export TERM=xterm' >> $HOME/.bash_profile

ADD Gemfile Gemfile.lock client.conf server.conf test.rb $HOME/
RUN bundle install --deployment --path vendor/bundle

CMD ["bundle", "exec", "ruby", "test.rb"]
