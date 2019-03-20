FROM microsoft/azure-cli

# need 'date -d'
RUN apk add --update coreutils && rm -rf /var/cache/apk/*

ADD azure-snapshoter.sh /azure-snapshoter.sh
ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/azure-snapshoter.sh"]