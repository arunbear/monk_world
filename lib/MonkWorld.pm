package MonkWorld;

our $VERSION = 0.001_001;
use v5.40;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup ($self) {

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    # Configure the application
    $self->configure_logging;
    $self->configure_secrets;

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('Example#welcome');
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
