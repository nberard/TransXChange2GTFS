FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y wget
RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get install -y apt-transport-https
RUN apt-get update
RUN apt-get install -y dotnet-sdk-2.2
RUN apt-get install -y libunwind-dev
WORKDIR /srv
COPY TransXChange2GTFS_2 ./
RUN dotnet build --runtime ubuntu.16.04-x64 --configuration Release
VOLUME /srv/input
VOLUME /srv/output
CMD /srv/bin/Release/netcoreapp2.0/ubuntu.16.04-x64/TransXChange2GTFS_2