FROM microsoft/azure-cli

ADD azure-snapshoter.sh /azure-snapshoter.sh
ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/azure-snapshoter.sh"]