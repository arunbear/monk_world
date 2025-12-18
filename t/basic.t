use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

# Test home page and navigation links
$t->get_ok('/')
  ->status_is(200)
  ->content_like(qr/Mojolicious/i)
  ->element_exists('a[href="/"]')
  ->text_is('a[href="/"]' => 'MonkWorld')
  ->element_exists('a[href="/threads"]')
  ->text_is('a[href="/threads"]' => 'Threads')
  ->element_exists('a[href="/search"]')
  ->text_is('a[href="/search"]' => 'Search');

# Test health endpoint
$t->get_ok('/health')
  ->status_is(200)
  ->content_is('OK');

done_testing();
