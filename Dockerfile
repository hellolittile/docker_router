FROM alpine:3.14

ENV ROUTE 192.168.100.1
ENV ADDRSRT 100
ENV ADDREND 200
ENV ROUTE6 fd00::
ENV IPV4NET $ROUTE/24 
ENV IPV6NET $ROUTE6/64

ENV TZ 'Asia/Shanghai'

# add tmp user to run service
RUN /usr/sbin/adduser tmp -h /opt/tmp -s /sbin/nologin -D
# install required package
RUN apk add -U iptables ip6tables supervisor dnscrypt-proxy dnsmasq igmpproxy hostapd ipset iw radvd

# copy conf for service
COPY ./etc/ /etc/

# sysctl enable ipv6 and allow ipv4/ipv6 forwarding 
RUN echo -e "net.ipv4.ip_forward = 1 \n\
net.ipv6.conf.all.forwarding=1 \n\
net.ipv6.conf.all.disable_ipv6 = 0 " >> /etc/sysctl.conf ;\
# enable dhcpv4 on lan \n\
echo -e "local=/lan/\n\
domain=lan\n\
dhcp-range=lan,$(echo $ROUTE|sed 's/\.[0-9]\+$//g').$ADDRSRT,$(echo $ROUTE|sed 's/\.[0-9]\+$//g').$ADDREND,240h\n\
dhcp-option=option:router,$ROUTE\n\
dhcp-authoritative\n\
dhcp-leasefile=/var/lib/dnsmasq.leases" >> /etc/dnsmasq.conf ;\
sed -i "s%IPV6NET%$IPV6NET%g" /etc/radvd.conf ;\
sed -i "s%IPV6NET%$IPV6NET%g" /etc/iptables/rules6

# copy init 
COPY ./init /etc/init.d/

RUN chmod a+x /etc/init.d/init 
RUN sed -i '/^\[supervisord\]/a nodaemon=true' /etc/supervisord.conf

ENTRYPOINT /etc/init.d/init
