#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

FROM golang:1.10.3-alpine as golang

WORKDIR /go/src/github.com/auto1-oss/aws-ecs-jenkins-terraform

COPY src/*.go .

#RUN go build -a -o app .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .


FROM alpine:3.8

COPY --from=golang /go/src/github.com/auto1-oss/aws-ecs-jenkins-terraform/app .

EXPOSE 80

ENTRYPOINT ["./app"]
