#!/usr/bin/env perl

# Perl Net::RabbitMQ port of receive_logs_topic.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/receive_logs_topic.py
#
# This script can receive messages from emit_logs_topic.pl and from emit_logs_topic.py .

use strict;
use Net::RabbitMQ;

my $host = 'localhost';
my $channel_id = 1;
my $exchange_name = 'topic_logs';
my $exchange_type = 'topic';

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

# Net::RabbitMQ defaults to auto_delete 1. Python's pika defaults to False. To
# match the exchange created in receive_logs.py, we need to disable auto_delete.
$mq->exchange_declare($channel_id, $exchange_name, {exchange => $exchange_name, exchange_type => $exchange_type, auto_delete => 0});

my $queue_name = $mq->queue_declare($channel_id, '', { exclusive => 1 });

my @binding_keys = @ARGV;
if ( scalar @binding_keys == 0) {
  print STDERR "Usage: $0 [binding_key] [binding_key] ...";
  exit 1;
}

for my $routing_key (@binding_keys) {
  $mq->queue_bind($channel_id, $queue_name, $exchange_name, $routing_key);
}

$mq->consume($channel_id, $queue_name, {consumer_tag => "worker_$$", no_ack => 0, exclusive => 0,});

print " [*] Waiting for logs. To exit press CTRL+C\n";


while ( my $payload = $mq->recv() ) {
    last if not defined $payload ;
    my $message  = $payload->{'body'};
    my $routing_key = $payload->{'routing_key'};
    print " [x] '$routing_key':'$message'\n";
}

$mq->disconnect;
