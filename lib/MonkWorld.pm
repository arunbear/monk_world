package MonkWorld;

our $VERSION = 0.001_001;
use v5.40;
use Mojo::Base 'Mojolicious';
use MonkWorld::API::Request 0.001_004; # centralize version pinning
use MonkWorld::TextProcessor;

# This method will run once at server start
sub startup ($self) {

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    # Configure the application
    $self->configure_logging;
    $self->configure_secrets;

    $self->helper(process_doctext => sub ($self, $text) {
        return MonkWorld::TextProcessor::apply_custom_markup($text);
    });

    # Routing
    my $r = $self->routes;

    $r->get('/')->to('Example#welcome');
    $r->get('/threads')->to('Threads#index');
    $r->get('/search')->to('Search#index');
    $r->get('/node/:id', [id => qr/\d+/])->to('Node#show');
}

sub configure_logging ($self) {
    my $config = $self->config;
    $self->log->path($config->{logger}{path});
    $self->log->level($config->{logger}{level});
}

sub configure_secrets ($self) {
    if (my $secrets = $ENV{MONKWORLD_SECRETS}) {
        $self->secrets([ split /,/ => $secrets ]);
    }
    else {
        $self->log->warn('MONKWORLD_SECRETS environment variable is not set');
    }
}

sub api_url ($self) {
    return $ENV{MONKWORLD_API_URL} // $self->config->{api}{url};
}
