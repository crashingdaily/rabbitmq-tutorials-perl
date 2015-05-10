#!/usr/bin/env perl

# Perl Net::RabbitMQ port of receive_logs_topic.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/rpc_client.py
#
# This script can receive messages from rpc_server.pl and from rpc_server.py .

use strict;
use Net::RabbitMQ;
use Data::Dumper;

my $max_input = 35;

my $host = 'localhost';
my $channel_id = 1;
my $routing_key = 'rpc_queue';
my $input = $ARGV[0] || 30;

if ($input > $max_input) {
  print "Maximum input value is $max_input.\n";
  exit 1;
}

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

my $queue_name = $mq->queue_declare($channel_id, '', { exclusive => 1 });


print " [x] Requesting fib($input)\n";
my $response = call($input);
print " [.] Got fib($input) is $response\n";


sub call {
  my ($n) = @_;
  my $correlation_id = `uuidgen`;
  $mq->publish($channel_id, $routing_key, $n, {}, {reply_to => $queue_name, correlation_id => $correlation_id});
  #print "publish $n to queue $queue_name, routing_key $routing_key, correlation_id $correlation_id\n";
  my $payload;
  my $response_correlation_id;
  $mq->consume($channel_id, $queue_name, {});
  while ( $payload = $mq->recv() ) {
    $response_correlation_id = $payload->{'props'}{'correlation_id'};
    last if ($correlation_id eq $response_correlation_id);
  }
  return $payload->{'body'};
}