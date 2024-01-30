ARG NIXOS_VERSION=2.19.1
ARG DEBIAN_VERSION=20.10.0-bullseye-slim

ARG BUILDER_IMAGE="nixos/nix:${NIXOS_VERSION}"
ARG RUNNER_IMAGE="node:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

WORKDIR /app

COPY . .

# install dependencies
RUN nix-shell --run "pnpm install --frozen-lockfile"
RUN nix-shell --run "elm make --output=/dev/null src/Main.elm"

# set build ENV
ENV NODE_ENV="production"

# build
RUN nix-shell --run "pnpm vite build"

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
# ARG SECRET_KEY # docker build --build-arg SECRET_KEY=asdf
# ENV SECRET_KEY=asdf # docker run -e "SECRET_KEY=another_value" alpine env

FROM ${RUNNER_IMAGE}

RUN apt update -y && \
    apt install -y locales && \
    apt clean

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV NODE_ENV="production"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/dist/ ./

USER nobody

EXPOSE 443

CMD ["pnpm vite preview"]