
# RabbitMQ Tutorials - Perl

Ports of the [RabbitMQ tutorials](https://github.com/rabbitmq/rabbitmq-tutorials) to Perl [Net::RabbitMQ](http://search.cpan.org/~jesus/Net--RabbitMQ-0.2.8/RabbitMQ.pm).


## Requirements

To successfully use the examples you will need a running RabbitMQ server. The scripts as written expect the RabbitMQ server to be on localhost, port 5672, guest/guest username/password.

The Perl scripts use [Net::RabbitMQ](http://search.cpan.org/~jesus/Net--RabbitMQ-0.2.8/RabbitMQ.pm). I use  version 0.2.8 .

    curl -LO http://www.cpan.org/authors/id/J/JE/JESUS/Net--RabbitMQ-0.2.8.tar.gz
    tar zxf Net--RabbitMQ-0.2.8.tar.gz
    cd Net--RabbitMQ-0.2.8
    perl Makefile.PL
    make
    make install

## Code


[Tutorial three: Publish/Subscribe:](http://www.rabbitmq.com/tutorials/tutorial-three-python.html)

    perl receive_logs.pl
    perl emit_log.pl "info: This is the log message"