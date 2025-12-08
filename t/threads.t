use v5.40;
use Mojo::Base -strict;

use Test::Most;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

# Test basic page load and structure
$t->get_ok('/threads')
  ->status_is(200)
  ->element_exists('title', 'has title')
  ->text_is('title' => 'Threads', 'page title contains "Threads"')
  ->element_exists('h1', 'has main heading')
  ->text_is('h1' => 'Recent Threads', 'correct main heading')
  ->element_exists('div.container', 'has container div')
  ->element_exists('h2', 'has section headers')
  ->element_exists('ul', 'has thread list');

done_testing();
