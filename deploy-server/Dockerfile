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

ENV ES_LOG_DEPLOY false
ENV ES_INDEX deploys
ENV ES_CLIENT_URL foobar.com

CMD ["bundle", "exec", "ruby", "server.rb"]
