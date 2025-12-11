use v5.40;
use Mojo::Base -strict;
use Test::Most tests => 58;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

# Test basic page load and structure
$t->get_ok('/threads')
    ->or(sub {
        my $tx = $t->tx;
        diag "Failed to GET /threads\nResponse: " . $tx->res->to_string;
    })
    ->element_exists('title')
    ->text_is('title' => 'Threads')
    ->element_exists('h1')
    ->text_is('h1' => 'Recent Threads')
    ->element_exists('div.threads-page.container')
    ->element_exists('section.thread-section')
    ->element_exists('ul.thread-list--top-level');

# Test sections and threads
my %threads = (
    1 => {
        title    => 'Hilbert Curve',
        author   => 'benizi',
        section  => 'obfuscated',
        replies  => [2, 3]
    },
    2 => {
        title    => 'Re: Hilbert Curve',
        author   => 'goibhniu',
        parent   => 1
    },
    3 => {
        title    => 'Re: Hilbert Curve',
        author   => 'KurtSchwind',
        parent   => 1
    },
    4 => {
        title    => 'Mandelbrot set',
        author   => 'Anonymous Monk',
        section  => 'obfuscated',
        replies  => [5, 7]
    },
    5 => {
        title    => 'Re: Mandelbrot set',
        author   => 'ki6jux',
        parent   => 4,
        replies  => [6]
    },
    6 => {
        title    => 'Re^2: Mandelbrot set',
        author   => 'blazar',
        parent   => 5
    },
    7 => {
        title    => 'Re: Mandelbrot set',
        author   => 'goibhniu',
        parent   => 4,
        replies  => [8]
    },
    8 => {
        title    => 'Re^2: Mandelbrot set',
        author   => 'blazar',
        parent   => 7
    },
    9 => {
        title    => 'RFC: Win32::OLE and Excel\'s RefreshAll',
        author   => 'jrsimmon',
        section  => 'perlmeditation',
        replies  => [10]
    },
    10 => {
        title    => 'Re: RFC: Win32::OLE and Excel\'s RefreshAll',
        author   => 'thoglette',
        parent   => 9,
        replies  => [11]
    },
    11 => {
        title    => 'Re^2: RFC: Win32::OLE and Excel\'s RefreshAll',
        author   => 'jrsimmon',
        parent   => 10
    },
    12 => {
        title    => 'What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'bdimych',
        section  => 'perlmeditation',
        replies  => [13]
    },
    13 => {
        title    => 'Re: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'moritz',
        parent   => 12,
        replies  => [14]
    },
    14 => {
        title    => 'Re^2: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'jettero',
        parent   => 13,
        replies  => [15]
    },
    15 => {
        title    => 'Re^3: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'Gangabass',
        parent   => 14
    },
);

# Test section headers
$t->text_is('section[data-section="obfuscated"] .thread-section__heading' => 'obfuscated')
  ->text_is('section[data-section="perlmeditation"] .thread-section__heading' => 'perlmeditation');

# Test all threads
for my $id (sort { $a <=> $b } keys %threads) {
    my $thread = $threads{$id};
    $t->text_is("#thread-$id .thread__title" => $thread->{title})
      ->text_is("#thread-$id .thread__author" => $thread->{author});
}

# Test thread hierarchy
for my $id (keys %threads) {
    my $thread = $threads{$id};
    if (exists $thread->{parent}) {
        my $parent_id = $thread->{parent};
        $t->element_exists("#thread-$parent_id .thread-list--replies #thread-$id");
    }
}

# Test section membership
for my $id (grep { exists $threads{$_}{section} } keys %threads) {
    my $section = $threads{$id}{section};
    $t->element_exists("section[data-section='$section'] #thread-$id");
}

# Test counts
is($t->tx->res->dom->find('section.thread-section')->size, 2, 'has 2 sections');

# Test top-level threads in obfuscated section
my $obfuscated_selector = 'section[data-section="obfuscated"] > .thread-list--top-level > li.thread--top';
is($t->tx->res->dom->find($obfuscated_selector)->size, 2);

# Test top-level threads in perlmeditation section
my $perlmed_selector = 'section[data-section="perlmeditation"] > .thread-list--top-level > li.thread--top';
is($t->tx->res->dom->find($perlmed_selector)->size, 2);