# docker build -t alpine:exec-c .
docker run -v "$PWD"/project_compile:/home --rm -ti alpine:exec-c