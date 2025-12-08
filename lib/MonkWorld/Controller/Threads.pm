package MonkWorld::Controller::Threads;
use v5.40;
use Mojo::Base 'Mojolicious::Controller', -signatures;
# use MonkWorld::API::Request;
use Data::Dumper;

sub index ($self) {
    my $url = $self->config->{api}{url} . '/threads';
    my $ua = $self->app->ua;
    my $tx = $ua->get($url);
    my $threads = $tx->res->json;
    $self->log->debug("Threads: " . Dumper($threads));

    $self->render(threaded => $threads, counter => make_counter());
}

sub make_counter () {
    my $count = 1;
    return sub { $count++ };
}

__END__
