## Modified by Sam KUON - 16/08/17
FROM centos:latest
MAINTAINER Sam KUON "sam.kuonssp@gmail.com"
# System timezone
ENV TZ=Asia/Phnom_Penh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Repositories and packages
RUN yum -y install epel-release && \
    rpm -Uvh https://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm

RUN yum -y update && \
    yum -y install \
        php56u \
        php56u-common \
        php56u-snmp \
        php56u-mysqlnd \
        php56u-ldap \
        php56u-cli \
        php56u-gmp \
        httpd \
	unzip \
	wget \
        mod_ldap &&\
    yum clean all

# Set PHP Timezone
RUN sed -i '890idate.timezone = "Asia/Phnom_Penh"' /etc/php.ini

# Download IPPlan version 6 Beta2
RUN cd /usr/src/ && \
    wget https://sourceforge.net/projects/iptrack/files/ipplan-beta/BETA%206.00%20-%20IPv6%20support/ipplan-6.00-BETA2.zip && \
    unzip ipplan-6.00-BETA2.zip && \
    rm -rf ipplan-6.00-BETA2.zip && \
    mkdir /var/spool/ipplanuploads && \
    mkdir /tmp/{dns,dhcp} && \
    chown -R apache.apache /var/spool/ipplanuploads /tmp/{dns,dhcp}

# Modify IPPlanv6 files to fix error
ENV IPPLAN_SRC /usr/src/ipplanv6
RUN sed -i "68s+^+//+" $IPPLAN_SRC/ipplanlib.php && \
    sed -i "s/TYPE=INNODB/ENGINE=INNODB/" $IPPLAN_SRC/admin/schemacreate.php && \
    find $IPPLAN_SRC/user/ -type f -exec sed -i "s/\&\$result/\$result/" {} \; && \
    sed -i "s/\&\$ret/\$ret/" $IPPLAN_SRC/user/modifyipform.php

# Allow user access for IPPlan authentication
RUN echo $'<Directory /var/www/html/user>\n\
AllowOverride All\n\
</Directory>\n'\
>> /etc/httpd/conf/httpd.conf

# Copy run-httpd script to image
ADD ./conf.d/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

EXPOSE 80 443

CMD ["/run-httpd.sh"]
