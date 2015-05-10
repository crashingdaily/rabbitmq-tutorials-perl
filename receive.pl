#!/usr/bin/env perl

# Perl Net::RabbitMQ port of receive.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/receive.py
#
# This script can receive messages from send.pl and from send.py .

use strict;
use Net::RabbitMQ;

my $host = 'localhost';
my $channel_id = 1;
my $queue_name = 'hello';
my $routing_key = 'hello';

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

# Net::RabbitMQ defaults to auto_delete 1. Python's pika defaults to False. To
# match the queue created by receive.py, we need to disable auto_delete.
$mq->queue_declare($channel_id, $queue_name, {auto_delete => 0});

$mq->consume($channel_id, $queue_name, { no_ack => 1 });

print " [*] Waiting for logs. To exit press CTRL+C\n";

while ( my $payload = $mq->recv() ) {
    last if not defined $payload ;
    my $message  = $payload->{body} ;
    my $dtag  = $payload->{delivery_tag} ;
    print " [x] '$message'\n";
}

$mq->disconnect;
