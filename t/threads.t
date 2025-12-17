use v5.40;
use Mojo::Base -strict;
use Test::Most tests => 7;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

subtest 'basic page load and structure' => sub {
    $t->get_ok('/threads')
        ->or(sub {
            my $tx = $t->tx;
            note "Failed to GET /threads\nResponse: " . $tx->res->to_string;
        })
        ->element_exists('title')
        ->text_is('title' => 'Threads')
        ->element_exists('h1')
        ->text_is('h1' => 'Recent Threads')
        ->element_exists('div.threads-page.container')
        ->element_exists('section.thread-section')
        ->element_exists('ul.thread-list--top-level');
};

# Expected sections and threads
my %threads = (
    # keyed by order as they appear in the page
    1 => {
        title    => 'Hilbert Curve',
        author   => 'benizi',
        section  => 'obfuscated',
        replies  => [2, 3],
        node_id  => '655046'
    },
    2 => {
        title    => 'Re: Hilbert Curve',
        author   => 'goibhniu',
        parent   => 1,
        node_id  => '655088'
    },
    3 => {
        title    => 'Re: Hilbert Curve',
        author   => 'KurtSchwind',
        parent   => 1,
        node_id  => '655081'
    },
    4 => {
        title    => 'Mandelbrot set',
        author   => 'Anonymous Monk',
        section  => 'obfuscated',
        replies  => [5, 7],
        node_id  => '653110'
    },
    5 => {
        title    => 'Re: Mandelbrot set',
        author   => 'ki6jux',
        parent   => 4,
        replies  => [6],
        node_id  => '654688'
    },
    6 => {
        title    => 'Re^2: Mandelbrot set',
        author   => 'blazar',
        parent   => 5,
        node_id  => '654770'
    },
    7 => {
        title    => 'Re: Mandelbrot set',
        author   => 'goibhniu',
        parent   => 4,
        replies  => [8],
        node_id  => '653345'
    },
    8 => {
        title    => 'Re^2: Mandelbrot set',
        author   => 'blazar',
        parent   => 7,
        node_id  => '654768'
    },
    9 => {
        title    => 'RFC: Win32::OLE and Excel\'s RefreshAll',
        author   => 'jrsimmon',
        section  => 'perlmeditation',
        replies  => [10],
        node_id  => '654677'
    },
    10 => {
        title    => 'Re: RFC: Win32::OLE and Excel\'s RefreshAll',
        author   => 'thoglette',
        parent   => 9,
        replies  => [11],
        node_id  => '655033'
    },
    11 => {
        title    => 'Re^2: RFC: Win32::OLE and Excel\'s RefreshAll',
        author   => 'jrsimmon',
        parent   => 10,
        node_id  => '655085'
    },
    12 => {
        title    => 'What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'bdimych',
        section  => 'perlmeditation',
        replies  => [13],
        node_id  => '654593'
    },
    13 => {
        title    => 'Re: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'moritz',
        parent   => 12,
        replies  => [14],
        node_id  => '654594'
    },
    14 => {
        title    => 'Re^2: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'jettero',
        parent   => 13,
        replies  => [15],
        node_id  => '654595'
    },
    15 => {
        title    => 'Re^3: What is the (greatest|biggest|largest|supreme|most known) project made (in|with) perl?',
        author   => 'Gangabass',
        parent   => 14,
        node_id  => '655072'
    },
);

subtest 'section headers' => sub {
    $t->text_is('section[data-section="obfuscated"] .thread-section__heading' => 'obfuscated')
      ->text_is('section[data-section="perlmeditation"] .thread-section__heading' => 'perlmeditation');
};

subtest 'all threads have correct titles and authors' => sub {
    for my $id (sort { $a <=> $b } keys %threads) {
        my $thread = $threads{$id};
        $t->text_is("#thread-$id .thread__title" => $thread->{title})
          ->text_is("#thread-$id .thread__author" => $thread->{author});
    }
};

subtest 'thread hierarchy is correctly nested' => sub {
    for my $id (keys %threads) {
        my $thread = $threads{$id};
        if (exists $thread->{parent}) {
            my $parent_id = $thread->{parent};
            $t->element_exists("#thread-$parent_id .thread-list--replies #thread-$id");
        }
    }
};

subtest 'threads are in correct sections' => sub {
    for my $id (grep { exists $threads{$_}{section} } keys %threads) {
        my $section = $threads{$id}{section};
        $t->element_exists("section[data-section='$section'] #thread-$id");
    }
};

subtest 'threads have correct hyperlinks' => sub {
    for my $id (sort { $a <=> $b } keys %threads) {
        my $expected_link = "/node/$threads{$id}{node_id}";
        $t->attr_is("#thread-$id .thread__title" => 'href' => $expected_link);
    }
};

subtest 'thread counts and organization' => sub {
    is($t->tx->res->dom->find('section.thread-section')->size, 2, 'has 2 sections');

    subtest 'obfuscated section has 2 top-level threads' => sub {
        my $obfuscated_selector = 'section[data-section="obfuscated"] > .thread-list--top-level > li.thread--top';
        is($t->tx->res->dom->find($obfuscated_selector)->size, 2);
    };

    subtest 'perlmeditation section has 2 top-level threads' => sub {
        my $perlmed_selector = 'section[data-section="perlmeditation"] > .thread-list--top-level > li.thread--top';
        is($t->tx->res->dom->find($perlmed_selector)->size, 2);
    };
};