FROM ubuntu:20.04
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y build-essential wget
COPY buildclips.sh buildclips.sh
RUN /bin/bash buildclips.sh
WORKDIR /opt/loan-expert
COPY DB DB
COPY Abstract.clp general.clp match.clp PrintAppDB.clp Specify-norm.clp ui.clp Compute.clp GetAppDB.clp Messages.clp DataStructure.clp Evaluate.clp obtain.clp loan.bat run.sh /opt/loan-expert/
RUN chmod a+x /opt/loan-expert/run.sh
ENTRYPOINT /opt/loan-expert/run.sh