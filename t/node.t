use v5.40;
use Mojo::Base -strict;
use Test::Most tests => 53;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

$t->get_ok('/node/12345678')
  ->status_is(200)
  ->element_exists('title')
  ->text_is('title' => 'How does HTML::Template work?')
  ->element_exists('h1.node__title')
  ->element_exists('h1.node__title a')
  ->text_is('h1.node__title a' => 'How does HTML::Template work?')

  ->element_exists('div.node-page.container')
  ->element_exists('div.node-header')
  ->element_exists('div.node__meta')
  ->element_exists('span.node__author')
  ->element_exists('span.node__author a')
  ->text_is('span.node__author a' => 'testuser1')
  ->element_exists('span.node__date')
  ->text_is('span.node__date' => 'on 2024-01-01 00:00:00')

  ->element_exists('div.node-content')
  ->element_exists('div.node__text')
  ->text_like('div.node__text' => qr/Main post content for testing structure validation\./)

  ->element_exists('div.node-replies')
  ->element_exists('h2')
  ->text_is('h2' => 'Replies')
  ->element_exists('ul.thread-list.thread-list--replies')

  ->element_exists('li.thread#thread-12345681')
  ->element_exists('li.thread#thread-12345681 .reply')
  ->element_exists('li.thread#thread-12345681 .reply-header')
  ->element_exists('li.thread#thread-12345681 .reply__title')
  ->text_like('li.thread#thread-12345681 .reply__title' => qr/Re: How does HTML::Template work?/)
  ->element_exists('li.thread#thread-12345681 .reply__author')
  ->text_like('li.thread#thread-12345681 .reply__author' => qr/testuser3/)
  ->element_exists('li.thread#thread-12345681 .reply__content')
  ->text_like('li.thread#thread-12345681 .reply__content' => qr/Second reply content with alternative text\./)

  ->element_exists('li.thread#thread-12345679')
  ->element_exists('li.thread#thread-12345679 .reply')
  ->element_exists('li.thread#thread-12345679 .reply-header')
  ->element_exists('li.thread#thread-12345679 .reply__title')
  ->text_like('li.thread#thread-12345679 .reply__title' => qr/Re: How does HTML::Template work?/)
  ->element_exists('li.thread#thread-12345679 .reply__author')
  ->text_like('li.thread#thread-12345679 .reply__author' => qr/testuser1/)
  ->element_exists('li.thread#thread-12345679 .reply__content')
  ->text_like('li.thread#thread-12345679 .reply__content' => qr/is a popular/)
  ->element_exists('li.thread#thread-12345679 .reply__content a[href="https://metacpan.org/pod/HTML::Template"]')
  ->text_is('li.thread#thread-12345679 .reply__content a[href="https://metacpan.org/pod/HTML::Template"]' => 'HTML::Template')
  ->element_exists('li.thread#thread-12345679 .reply__content a[href="https://en.wikipedia.org/wiki/Web_template_system"]')
  ->text_is('li.thread#thread-12345679 .reply__content a[href="https://en.wikipedia.org/wiki/Web_template_system"]' => 'Web template system')

  ->element_exists('li.thread#thread-12345680')
  ->element_exists('li.thread#thread-12345680 .reply')
  ->element_exists('li.thread#thread-12345680 .reply-header')
  ->element_exists('li.thread#thread-12345680 .reply__title')
  ->text_like('li.thread#thread-12345680 .reply__title' => qr/Re\^2: How does HTML::Template work?/)
  ->element_exists('li.thread#thread-12345680 .reply__author')
  ->text_like('li.thread#thread-12345680 .reply__author' => qr/testuser2/)
  ->element_exists('li.thread#thread-12345680 .reply__content')
  ->text_like('li.thread#thread-12345680 .reply__content' => qr/Nested reply content with unique text\./);
