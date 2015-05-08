#!/usr/bin/env perl

# Perl Net::RabbitMQ port of send.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/send.py
#
# This script can send messages to receive.pl and to receive.py - but only to
# one of those at a time.

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
# match the queue created by send.py, we need to disable auto_delete.
$mq->queue_declare($channel_id, $queue_name, { auto_delete => 0 });

my $message = 'Hello World!';

$mq->publish($channel_id, $routing_key, $message);

print "  [x] Sent '$message'";
