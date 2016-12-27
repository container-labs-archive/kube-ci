FROM ruby:2.3

RUN mkdir /app
WORKDIR /app

COPY ./Gemfile /app/Gemfile
RUN bundle install

COPY ./ /app

EXPOSE 4567

ENV KUBE_CLUSTER_USERNAME foo
ENV KUBE_CLUSTER_PASSWORD bar
ENV KUBE_CLUSER_IP baz

CMD ["bundle", "exec", "ruby", "server.rb"]
