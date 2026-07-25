FROM evoapicloud/evolution-api:v2.3.7

ENV SERVER_TYPE=http
ENV LANGUAGE=en

# The real Evolution API binds to an internal-only port; the wrapper
# below listens on the actual public port (WRAPPER_PORT) and proxies
# to it, so a bare GET / can redirect to /manager instead of returning
# raw welcome JSON that most deployers won't know to append /manager to.
ENV API_INTERNAL_PORT=8081
ENV WRAPPER_PORT=8080

WORKDIR /wrapper
COPY wrapper/package.json ./
RUN npm install --omit=dev
COPY wrapper/proxy.js ./

WORKDIR /evolution
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
