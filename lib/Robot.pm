package Robot;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('example#index');
    $r->websocket('/socket')->to('example#hop')
}

1;
