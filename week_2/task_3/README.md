Dockerized python application: https://github.com/SeungheonOh/pot

To start: docker run -v "$(pwd)/images:/images" pot-image image.jpg_location

For some reason, app does not work in docker container. Throws error that the resolution of image is too big, works fine on local.
