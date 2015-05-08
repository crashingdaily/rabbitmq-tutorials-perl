#!/usr/bin/env perl

# Perl Net::RabbitMQ port of send.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/send.py
#
# This script can send messages to worker.pl and to worker.py - but only to
# one of those at a time.

use strict;
use Net::RabbitMQ;
use Data::Dumper;

my $host = 'localhost';
my $channel_id = 1;
my $queue_name = 'task_queue';
my $routing_key = 'task_queue';


my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

$mq->queue_declare($channel_id, $queue_name, { auto_delete => 0, durable => 1 });


my $message = $ARGV[0] || "Hello World!";

$mq->publish($channel_id, $routing_key, $message, {}, {delivery_mode => 2});

print "  [x] Sent '$message'";

$mq->disconnect;
