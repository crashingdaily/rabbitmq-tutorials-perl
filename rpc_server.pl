#!/usr/bin/env perl

# Perl Net::RabbitMQ port of receive_logs_topic.py from vendor tutorials.
# https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/python/rpc_server.py
#
# This script can receive messages from rpc_client.pl and from rpc_client.py .

use strict;
use Net::RabbitMQ;

my $DEBUG = 1;

my $host = 'localhost';
my $channel_id = 1;
my $queue_name = 'rpc_queue';

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

$mq->queue_declare($channel_id, $queue_name, {auto_delete => 0});

$mq->basic_qos($channel_id, {prefetch_count => 1});
$mq->consume($channel_id, $queue_name, { no_ack => 0 });

print " [*] Awaiting RPC requests\n";

while ( my $payload = $mq->recv() ) {
    last if not defined $payload ;
    my $n  = $payload->{'body'};
    my $reply_to = $payload->{'props'}{'reply_to'};
    my $correlation_id = $payload->{'props'}{'correlation_id'};
    my $dtag  = $payload->{'delivery_tag'};
    print " [.] fib($n)";
    my $response = fib($n);
    $mq->publish($channel_id, $reply_to, $response, {}, {correlation_id => $correlation_id});
    $mq->ack($channel_id, $dtag);
    print " [x] '$response'\n";
    $DEBUG && print "published to queue $reply_to, correlation_id $correlation_id\n";
}

$mq->disconnect;

sub fib() {
  my ($n) = @_;
  if ($n == 0) {
    return 0;
  } elsif ($n == 1) {
    return 1;
  } else {
    return fib($n-1) + fib($n-2);
  }
}