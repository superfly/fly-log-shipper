FROM timberio/vector:0.28.1-debian
RUN mkdir -p /etc/vector/app-loggers
COPY *.toml /etc/vector/
COPY sinks /etc/vector/sinks
COPY *.sh .
CMD ["bash", "start-fly-log-transporter.sh"]
ENTRYPOINT []
