
IMAGE=tornado-gpu
docker build --cpuset-cpus="0-7" -t $IMAGE .
