use v5.40;
use Mojo::Base -strict;
use Test::Most tests => 27;
use Test::Mojo;

my $t = Test::Mojo->new('MonkWorld');

# Test basic search page load and structure
$t->get_ok('/search')
    ->status_is(200)
    ->element_exists('title')
    ->text_is('title' => 'Search')
    ->element_exists('h1')
    ->text_is('h1' => 'Search')
    ->element_exists('div.search-page.container')
    ->element_exists('form.search-form')
    ->element_exists('input.search-form__input')
    ->element_exists('button.search-form__button');

# Test search with query parameter
my $search_term = 'bcrypt';
$t->get_ok('/search?q=' . $search_term)
    ->status_is(200)
    ->element_exists('div.search-results')
    ->element_exists('table.search-results__table')
    ->element_exists('th.search-results__header--title')
    ->text_like('h2.search-results__heading' => qr/Search results for "${search_term}"/)
    ->element_exists('span.search-results__count')
    ->text_like('span.search-results__count' => qr/\(\d+ results\)/);

# Check the first result
my $re_non_empty = qr/\S+/;
$t->element_exists('tbody tr:nth-child(1)')
    ->element_exists('tbody tr:nth-child(1) td.search-result__title a')
    ->text_like('tbody tr:nth-child(1) td.search-result__title a' => $re_non_empty)
    ->element_exists('tbody tr:nth-child(1) td.search-result__author')
    ->element_exists('tbody tr:nth-child(1) td.search-result__section')
    ->element_exists('tbody tr:nth-child(1) td.search-result__date')
    ->text_like('tbody tr:nth-child(1) td.search-result__author' => $re_non_empty)
    ->text_like('tbody tr:nth-child(1) td.search-result__section' => $re_non_empty)
    ->text_like('tbody tr:nth-child(1) td.search-result__date' => qr/\d{4}-\d{2}-\d{2}/);