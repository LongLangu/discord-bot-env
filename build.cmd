docker build -t arm32v7/python-dicordbot ./

docker tag arm32v7/python-dicordbot ghcr.io/longlangu/arm32v7/python-dicordbot:%1

docker push ghcr.io/longlangu/arm32v7/python-dicordbot:%1

docker rmi ghcr.io/longlangu/arm32v7/python-dicordbot:%1

docker rmi arm32v7/python-dicordbot