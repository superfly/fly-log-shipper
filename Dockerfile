FROM timberio/vector:nightly-2022-07-26-debian
COPY vector-configs/* /etc/vector/
COPY ./start-fly-log-transporter.sh .
CMD ["bash", "start-fly-log-transporter.sh"]
ENTRYPOINT []
