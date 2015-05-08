#!/usr/bin/env perl

# Perl Net::RabbitMQ port of emit_log.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/emit_log.py
#
# This script can publish messages to receive_logs.pl and to receive_logs.py .

use strict;
use Net::RabbitMQ;

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

my $message = $ARGV[0] || "info: Hello World!";

$mq->publish($channel_id, $routing_key, $message, { exchange => $exchange_name });

print " [x] $message\n";

$mq->disconnect;