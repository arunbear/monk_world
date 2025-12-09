use v5.40;
use Mojo::Base -strict;
use Test::Most tests => 37;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

# Test basic page load and structure
$t->get_ok('/threads')
  ->status_is(200)
  ->element_exists('title')
  ->text_is( 'title' => 'Threads' )
  ->element_exists('h1')
  ->text_is( 'h1' => 'Recent Threads' )
  ->element_exists('div.threads-page.container')
  ->element_exists('section.thread-section')
  ->element_exists('ul.thread-list--top-level');

# Test section headers are present with exact text
$t->text_is( 'section.thread-section:nth-of-type(1) .thread-section__heading' =>
      'obfuscated' )
  ->text_is( 'section.thread-section:nth-of-type(2) .thread-section__heading' =>
      'perlmeditation' );

# Test thread titles from obfuscated section (top-level only)
$t->text_is(
'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top:nth-of-type(1) .thread__title'
      => 'Hilbert Curve' )
  ->text_is(
'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top:nth-of-type(2) .thread__title'
      => 'Mandelbrot set' );

# Test thread titles from perlmeditation section (top-level only)
$t->text_is(
'section.thread-section:nth-of-type(2) ul.thread-list--top-level > li.thread--top:nth-of-type(1) .thread__title'
      => 'RFC: Win32::OLE and Excel\'s RefreshAll' )
  ->text_is(
'section.thread-section:nth-of-type(2) ul.thread-list--top-level > li.thread--top:nth-of-type(2) .thread__title'
      => 'What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?'
  );

# Test author usernames are displayed with exact text (top-level threads)
$t->text_is(
'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top:nth-of-type(1) .thread__author'
      => 'benizi' )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread__author'
      => 'Anonymous Monk' )
  ->text_is(
'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread__author'
      => 'jrsimmon' );

# Test reply threads (nested content) authors are displayed in order
# First thread in obfuscated section (Hilbert Curve)
$t->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(1) .thread-list--replies > li.thread:nth-of-type(1) .thread__author'
      => 'goibhniu' )->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(1) .thread-list--replies > li.thread:nth-of-type(2) .thread__author'
      => 'KurtSchwind'

      # Second thread in obfuscated section (Mandelbrot set)
      )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread__author'
      => 'ki6jux' )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread-list--replies li.thread .thread__author'
      => 'blazar' )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(2) .thread__author'
      => 'goibhniu' )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(2) .thread-list--replies li.thread .thread__author'
      => 'blazar'

# First thread in perlmeditation section (RFC: Win32::OLE and Excel's RefreshAll)
  )
  ->text_is(
'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread-list--replies > li.thread .thread__author'
      => 'thoglette' );

# Test nested reply titles with exact text (any depth)
$t->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread__title'
      => 'Re: Mandelbrot set' )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread-list--replies li.thread .thread__title'
      => 'Re^2: Mandelbrot set' )
  ->text_is(
'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(1) .thread-list--replies > li.thread:nth-of-type(1) .thread__title'
      => 'Re: Hilbert Curve' )
  ->text_is(
'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread-list--replies > li.thread .thread__title'
      => 'Re: RFC: Win32::OLE and Excel\'s RefreshAll' );

# Test deeper nested replies
$t->text_is(
'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(2) .thread-list--replies > li.thread .thread-list--replies > li.thread:nth-of-type(1) .thread__title'
      => 'Re^2: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?'
  )
  ->text_is(
'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(2) .thread-list--replies > li.thread .thread-list--replies > li.thread:nth-of-type(1) .thread-list--replies li.thread .thread__title'
      => 'Re^3: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?'
  )
  ->text_is(
'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread-list--replies > li.thread .thread-list--replies li.thread .thread__title'
      => q{Re^2: RFC: Win32::OLE and Excel's RefreshAll} );

# Test list structure for nested threads
$t->element_exists('li .thread-list--replies')
  ->element_exists('li .thread-list--replies > li.thread');

# Test total number of sections
my $sections = $t->tx->res->dom->find('section.thread-section')->size;
is( $sections, 2 );

# Test top-level threads in obfuscated section
my $obfuscated_threads = $t->tx->res->dom->find(
'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top'
)->size;
is( $obfuscated_threads, 2 );

# Test top-level threads in perlmeditation section
my $perlmed_threads = $t->tx->res->dom->find(
'section.thread-section:nth-of-type(2) ul.thread-list--top-level > li.thread--top'
)->size;
is( $perlmed_threads, 2 );