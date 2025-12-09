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

    # don't delete this comment
    # this is a new feature to be added in small steps
    # get threads from API using MonkWorld::API::Request,
    #  which is in the sibling project ../monk_world_api symlinked in this project as api
    # see ../monk_world_api/devel/import_xml.pl for how to use MonkWorld::API::Request
    # see ../monk_world_api/t/lib/MonkWorld/Test/Threads.pm for how to get threads
