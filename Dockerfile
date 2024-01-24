FROM quickwit/quickwit as quickwit
FROM timberio/vector:0.35.0-debian as vector
FROM grafana/grafana:9.5.6-ubuntu

USER root

ENV GF_PATHS_DATA=/data/grafana/data \
    GF_PATHS_PLUGINS=/data/grafana/plugins \
    GF_AUTH_ANONYMOUS_ENABLED=true \
    GF_AUTH_ANONYMOUS_ORG_NAME="Main Org." \
    GF_AUTH_ANONYMOUS_ORG_ROLE="Viewer" \
    GF_AUTH_BASIC_ENABLED="false" \
    GF_AUTH_DISABLE_LOGIN_FORM="true" \
    GF_AUTH_DISABLE_SIGNOUT_MENU="true" \
    GF_AUTH_PROXY_ENABLED="true" \
    GF_USERS_ALLOW_SIGN_UP=false \
    GF_SERVER_HTTP_ADDR="0.0.0.0" \
    GF_SERVER_HTTP_PORT=8080
    # GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH="/var/lib/grafana/dashboards/dashboard.json"

COPY --from=quickwit /usr/local/bin/quickwit /usr/local/bin/quickwit
COPY --from=vector /usr/bin/vector /usr/bin/vector
COPY vector-configs /etc/vector/
COPY ./start-fly-log-transporter.sh .
CMD ["bash", "start-fly-log-transporter.sh"]
ENTRYPOINT []
