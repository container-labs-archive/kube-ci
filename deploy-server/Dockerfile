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
ENV DEPLOY_USERNAME admin
ENV DEPLOY_PASSWORD admin

ENV SLACK_WEBHOOK_URL http://biz.baz
ENV POST_TO_SLACK false

CMD ["bundle", "exec", "ruby", "server.rb"]
