FROM ubuntu:16.04
ADD lib/install_baseimage.sh /root/powerchain-maker/install_baseimage.sh
RUN /root/powerchain-maker/install_baseimage.sh

ADD lib/install_constellation.sh /root/powerchain-maker/install_constellation.sh
RUN /root/powerchain-maker/install_constellation.sh

ADD tessera/tessera-app/target/tessera-app.jar /tessera/tessera-app.jar
ADD tessera/data-migration/target/data-migration-cli.jar /tessera/data-migration-cli.jar
ADD tessera/config-migration/target/config-migration-cli.jar /tessera/config-migration-cli.jar

RUN echo "alias tessera=\"java -jar /tessera/tessera-app.jar\"" >> ~/.bashrc
RUN echo "alias tessera-data-migration=\"java -jar /tessera/data-migration-cli.jar\"" >> ~/.bashrc
RUN echo "alias tessera-config-migration=\"java -jar /tessera/config-migration-cli.jar\"" >> ~/.bashrc

ADD powerchain/build/bin/geth /usr/local/bin
ADD powerchain/build/bin/bootnode /usr/local/bin

ADD powerchain-maker-nodemanager/powerchain-maker-nodemanager /root/powerchain-maker/NodeManager
ADD powerchain-maker-ui/webApp/dist /root/powerchain-maker/NodeManagerUI

ADD lib/start_nodemanager.sh /root/powerchain-maker/start_nodemanager.sh
RUN chmod +x /root/powerchain-maker/start_nodemanager.sh

ADD lib/reset_chain.sh /root/powerchain-maker/reset_chain.sh
RUN chmod +x /root/powerchain-maker/reset_chain.sh

ADD ../powerchain-maker-nodemanager/NetworkManagerContract.sol /root/powerchain-maker/NetworkManagerContract.sol
ADD powerchain-maker-nodemanager/NodeUnavailableTemplate.txt /root/powerchain-maker/NodeUnavailableTemplate.txt
ADD powerchain-maker-nodemanager/JoinRequestTemplate.txt /root/powerchain-maker/JoinRequestTemplate.txt
ADD powerchain-maker-nodemanager/TestMailTemplate.txt /root/powerchain-maker/TestMailTemplate.txt
ADD powerchain-maker-nodemanager/nmcBytecode /root/powerchain-maker/nmcBytecode
