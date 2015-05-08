#!/usr/bin/env perl

# Perl Net::RabbitMQ port of receive_logs.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/receive_logs.py
#
# This script can receive messages from emit_log.pl and from emit_log.py .

use strict;
use Net::RabbitMQ;
use Data::Dumper;

my $host = 'localhost';
my $channel_id = 1;
my $exchange_name = 'logs';
my $routing_key = '';

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

# Net::RabbitMQ defaults to auto_delete 1. Python's pika defaults to False. To
# match the exchange created in receive_logs.py, we need to disable auto_delete.
$mq->exchange_declare($channel_id, $exchange_name, {exchange => 'logs', exchange_type => 'fanout', auto_delete => 0});

my $queue_name = $mq->queue_declare($channel_id, '', { exclusive => 1 });

$mq->queue_bind($channel_id, $queue_name, $exchange_name, $routing_key);

print " [*] Waiting for logs. To exit press CTRL+C\n";

$mq->consume($channel_id, $queue_name, {consumer_tag => "worker_$$", no_ack => 0, exclusive => 0,});

while ( my $payload = $mq->recv() ) {
    last if not defined $payload ;
    my $message  = $payload->{body} ;
    my $dtag  = $payload->{delivery_tag} ;
    print " [x] '$message'\n";
    #$mq->ack($channel_id, $dtag,) ;
}

