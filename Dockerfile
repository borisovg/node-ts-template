FROM docker.io/node:lts as stage1
WORKDIR /build
COPY . .
RUN make ci

FROM docker.io/node:lts-slim
WORKDIR /opt/service
COPY --from=0 /build/dist dist
COPY --from=0 /build/node_modules node_modules
ENV NODE_ENV="production"
EXPOSE 8000 8000
CMD [ "node", "--enable-source-maps", "dist/index.js" ]
