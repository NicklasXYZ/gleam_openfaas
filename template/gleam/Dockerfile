FROM openfaas/of-watchdog:0.7.7 as watchdog

FROM erlang:24-alpine as builder

MAINTAINER NicklasXYZ

WORKDIR /usr/src

# Copy in the function watchdog
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog

ENV GLEAM_VERSION v0.14.4

# Install Rebar3, Gleam and make the function watchdog executable
RUN wget https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3 && \
    cp rebar3 /usr/bin/rebar3 && \
    rm -f rebar3 && \
    wget https://github.com/gleam-lang/gleam/releases/download/${GLEAM_VERSION}/gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    tar zxf gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    chmod +x gleam && \
    cp gleam /usr/bin/gleam && \
    rm -f gleam gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    chmod +x /usr/bin/fwatchdog

# Copy function files and folders to the application directory 
WORKDIR /home/app
COPY . .
# Compile all Gleam code with Rebar3
RUN rebar3 compile

# Add non root user
RUN addgroup -S app && adduser -S -g app app \
    && mkdir -p /home/app \
    && chown -R app /home/app

USER app

# The command 'rebar3 shell' starts the Elli webserver when the function is invoked!
# TODO: Find a better way to build and run the code (e.g. through 'rebar3 release' or 'mix release') 
ENV fprocess="rebar3 shell"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]