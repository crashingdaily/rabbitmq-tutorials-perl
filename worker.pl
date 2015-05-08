#!/usr/bin/env perl

use strict;
use Net::RabbitMQ;

my $host = 'localhost';
my $channel_id = 1;
my $queue_name = 'task_queue';
my $routing_key = 'task_queue';

my $mq = Net::RabbitMQ->new() ;

$mq->connect($host, {});

$mq->channel_open($channel_id);

$mq->queue_declare($channel_id, $queue_name, { auto_delete => 0, durable => 1 });

$mq->consume($channel_id, $queue_name, { no_ack => 0 });

print " [*] Waiting for logs. To exit press CTRL+C\n";

while ( my $payload = $mq->recv() ) {
    last if not defined $payload ;
    my $message  = $payload->{body} ;
    print " [x] Received '$message'\n";
    my $count = () = $message =~ /\./g;
    sleep $count;
    print " [x] Done\n";
    my $dtag  = $payload->{delivery_tag};
    $mq->ack($channel_id, $dtag);
}

$mq->disconnect;
