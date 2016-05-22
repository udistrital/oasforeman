FROM centos:7
RUN yum install -y ruby openssh-clients
COPY tmp/vagrant_*.rpm /tmp/vagrant_rpm/
RUN rpm -i /tmp/vagrant_rpm/vagrant_*.rpm
RUN rm -rf /tmp/vagrant_rpm/
COPY pkg/oasforeman-*.gem /tmp/oasforeman_gem/
RUN gem install --local /tmp/oasforeman_gem/oasforeman-*.gem
RUN rm -rf /tmp/oasforeman_gem/
