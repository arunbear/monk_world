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
    ->element_exists('div.threads-page.container', 'has threads page container')
    ->element_exists('section.thread-section', 'has at least one thread section')
    ->element_exists('ul.thread-list--top-level', 'has top-level thread list');

# Test section headers are present with exact text
$t->text_is('section.thread-section:nth-of-type(1) .thread-section__heading' => 'obfuscated', 'has obfuscated section')
    ->text_is('section.thread-section:nth-of-type(2) .thread-section__heading' => 'perlmeditation', 'has perlmeditation section');

# Test thread titles from obfuscated section (top-level only)
$t->text_is(
    'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top:nth-of-type(1) .thread__title'
        => 'Hilbert Curve',
    'first obfuscated top-level thread title is Hilbert Curve'
)->text_is(
    'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top:nth-of-type(2) .thread__title'
        => 'Mandelbrot set',
    'second obfuscated top-level thread title is Mandelbrot set'
);

# Test thread titles from perlmeditation section (top-level only)
$t->text_is(
    'section.thread-section:nth-of-type(2) ul.thread-list--top-level > li.thread--top:nth-of-type(1) .thread__title'
        => 'RFC: Win32::OLE and Excel\'s RefreshAll',
    'first perlmeditation top-level thread title is the RFC'
)->text_is(
    'section.thread-section:nth-of-type(2) ul.thread-list--top-level > li.thread--top:nth-of-type(2) .thread__title'
        => 'What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
    'second perlmeditation top-level thread title is the long question'
);

# Test author usernames are displayed with exact text (top-level threads)
$t->text_is(
    'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top:nth-of-type(1) .thread__author'
        => 'benizi',
    'Hilbert Curve author is benizi'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread__author'
        => 'Anonymous Monk',
    'Mandelbrot set author is Anonymous Monk'
)->text_is(
    'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread__author'
        => 'jrsimmon',
    'RFC thread author is jrsimmon'
);

# Test reply threads (nested content) authors are displayed in order
# First thread in obfuscated section (Hilbert Curve)
$t->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(1) .thread-list--replies > li.thread:nth-of-type(1) .thread__author' => 'goibhniu',
    'first reply author is goibhniu for Hilbert Curve'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(1) .thread-list--replies > li.thread:nth-of-type(2) .thread__author' => 'KurtSchwind',
    'second reply author is KurtSchwind for Hilbert Curve'

# Second thread in obfuscated section (Mandelbrot set)
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread__author' => 'ki6jux',
    'first reply author is ki6jux for Mandelbrot set'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread-list--replies li.thread .thread__author' => 'blazar',
    'nested reply author is blazar for Mandelbrot set'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(2) .thread__author' => 'goibhniu',
    'second reply author is goibhniu for Mandelbrot set'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(2) .thread-list--replies li.thread .thread__author' => 'blazar',
    'second nested reply author is blazar for Mandelbrot set'

# First thread in perlmeditation section (RFC: Win32::OLE and Excel's RefreshAll)
)->text_is(
    'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread-list--replies > li.thread .thread__author' => 'thoglette',
    'reply author is thoglette for RFC thread'
);

# Test nested reply titles with exact text (any depth)
$t->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread__title'
        => 'Re: Mandelbrot set',
    'reply title to Mandelbrot set exists'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(2) .thread-list--replies > li.thread:nth-of-type(1) .thread-list--replies li.thread .thread__title'
        => 'Re^2: Mandelbrot set',
    'nested reply title exists for Mandelbrot set'
)->text_is(
    'section.thread-section:nth-of-type(1) .thread--top:nth-of-type(1) .thread-list--replies > li.thread:nth-of-type(1) .thread__title'
        => 'Re: Hilbert Curve',
    'reply to Hilbert Curve exists'
)->text_is(
    'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread-list--replies > li.thread .thread__title'
        => 'Re: RFC: Win32::OLE and Excel\'s RefreshAll',
    'RFC reply exists'
);

# Test deeper nested replies
$t->text_is(
    'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(2) .thread-list--replies > li.thread .thread-list--replies > li.thread:nth-of-type(1) .thread__title'
        => 'Re^2: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
    'nested Re^2 title exists for big project thread'
)->text_is(
    'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(2) .thread-list--replies > li.thread .thread-list--replies > li.thread:nth-of-type(1) .thread-list--replies li.thread .thread__title'
        => 'Re^3: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
    'nested Re^3 title exists for big project thread'
)->text_is(
    'section.thread-section:nth-of-type(2) .thread--top:nth-of-type(1) .thread-list--replies > li.thread .thread-list--replies li.thread .thread__title'
        => 'Re^2: RFC: Win32::OLE and Excel\'s RefreshAll',
    'nested RFC reply exists'
);

# Test list structure for nested threads
$t->element_exists('li .thread-list--replies', 'has nested lists for replies')
    ->element_exists('li .thread-list--replies > li.thread', 'has list items within nested lists');

# Test total number of sections
my $sections = $t->tx->res->dom->find('section.thread-section')->size;
is($sections, 2, 'has exactly 2 sections (obfuscated and perlmeditation)');

# Test top-level threads in obfuscated section
my $obfuscated_threads = $t->tx->res->dom->find(
    'section.thread-section:nth-of-type(1) ul.thread-list--top-level > li.thread--top'
)->size;
is($obfuscated_threads, 2, 'obfuscated section has exactly 2 top-level threads');

# Test top-level threads in perlmeditation section
my $perlmed_threads = $t->tx->res->dom->find(
    'section.thread-section:nth-of-type(2) ul.thread-list--top-level > li.thread--top'
)->size;
is($perlmed_threads, 2, 'perlmeditation section has exactly 2 top-level threads');

done_testing();