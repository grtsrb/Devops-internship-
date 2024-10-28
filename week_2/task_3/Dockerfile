FROM golang AS build 

WORKDIR /usr/src/pot

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -ldflags "-w -s" -o /bin/pot .

FROM jrottenberg/ffmpeg:2.8-scratch

WORKDIR /images

COPY --from=build /bin/pot /bin/pot 

ENTRYPOINT [ "/bin/pot" ]