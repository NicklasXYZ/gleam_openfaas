FROM erlang:24-alpine as builder

MAINTAINER NicklasXYZ

WORKDIR /usr/src

ENV GLEAM_VERSION v0.16.1

# Install Rebar3, Gleam and make the function watchdog executable
RUN wget https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3 && \
    cp rebar3 /usr/bin/rebar3 && \
    rm -f rebar3 && \
    wget https://github.com/gleam-lang/gleam/releases/download/${GLEAM_VERSION}/gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    tar zxf gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    chmod +x gleam && \
    cp gleam /usr/bin/gleam && \
    rm -f gleam gleam-${GLEAM_VERSION}-linux-amd64.tar.gz

# Copy function files and folders to the application directory 
COPY ./function .
# Compile Gleam code and create a release 
RUN rebar3 release

FROM openfaas/of-watchdog:0.8.2 as watchdog

# Final build stage
FROM erlang:24-alpine as app

WORKDIR /home/app

# Copy Gleam release from 'builder' build stage to current 'app' build stage   
COPY --from=builder /usr/src/_build/default/rel/gleam_openfaas .
# Copy in the function watchdog
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
# Make the function watchdog executable
RUN chmod +x /usr/bin/fwatchdog && chmod +x /home/app/bin/gleam_openfaas

# Add non root user
RUN addgroup -S app && adduser -S -g app app \
    && mkdir -p /home/app \
    && chown -R app /home/app

USER app

# Start the elli webserver and leave the process in the foreground
ENV fprocess="/home/app/bin/gleam_openfaas foreground"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:8000"
# NOTE: This is an important setting as the Elli webserver does not 
# use by default the header: 'Transfer-Encoding': 'chunked'
ENV http_buffer_req_body="true"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]