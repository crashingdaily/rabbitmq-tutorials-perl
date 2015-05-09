#!/usr/bin/env perl

# Perl Net::RabbitMQ port of receive_logs_topic.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/rpc_client.py
#
# This script can receive messages from rpc_server.pl and from rpc_server.py .

use strict;
use Net::RabbitMQ;
use Data::Dumper;

my $host = 'localhost';
my $channel_id = 1;
my $routing_key = 'rpc_queue';

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

my $queue_name = $mq->queue_declare($channel_id, '', { exclusive => 1 });


print " [x] Requesting fib(30)\n";
my $response = call(30);
print " [.] Got $response\n";


sub call {
  my ($n) = @_;
  my $correlation_id = `uuidgen`;
  $mq->publish($channel_id, $routing_key, $n, {}, {reply_to => $queue_name, correlation_id => $correlation_id});
  print "publish $n to queue $queue_name, routing_key $routing_key, correlation_id $correlation_id\n";
  my $payload;
  my $response_correlation_id;
  do {
    sleep 1;
    $payload = $mq->get($channel_id, $queue_name);
    $response_correlation_id = $payload->{'props'}{'correlation_id'};
  } while ($payload == undef || ($correlation_id ne $response_correlation_id));
  my $response = $payload->{'body'};
  return $response;
}