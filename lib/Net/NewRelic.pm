package Net::NewRelic;

use 5.008000;
use strict;
use warnings;
use Carp;

use LWP::UserAgent;

our $VERSION = '0.03_1';

sub new {
    my $class = shift;
    my $self = bless {}, $class;

    $self->{tid} = newrelic_transaction_begin();

    $self->attribute( $class, $VERSION );

    return $self;
}

sub deploy {
    my $class = shift;
    my %args  = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent( __PACKAGE__ . "/" . $VERSION );

    my $api_key = delete $args{api_key} || $ENV{NEWRELIC_API_KEY};

    if ( not $api_key ) {
        die "Need an api_key";
    }

    # Create a request
    my $req =
      HTTP::Request->new( POST => 'https://api.newrelic.com/deployments.xml' );

    $req->header( 'x-api-key', $api_key );
    $req->content_type('application/x-www-form-urlencoded');

    $args{user} ||= $ENV{USER};

    my $content = join '&', map { "deployment[$_]=$args{$_}" } sort keys %args;
    $req->content($content);

    my $res = $ua->request($req);

    return $res->is_success;
}

sub segment {
    my $self = shift;
    my $name = shift;

    my $s = Net::NewRelic::Segment->new( $self->{tid}, $name );

    return $s;
}

sub name {
    my $self = shift;
    my $name = shift;

    $self->{name} = $name;

    return newrelic_transaction_set_name( $self->{tid}, $self->{name} );
}

sub attribute {
    my ( $self, $key, $value ) = @_;

    $self->{attrs} ||= {};
    $self->{attrs}{$key} = $value;

    return newrelic_transaction_add_attribute( $self->{tid}, $key, $value );
}

sub url {
    my $self = shift;
    my $url  = shift;

    $self->{url} = $url;

    return newrelic_transaction_set_request_url( $self->{tid}, $self->{url} );
}

# in milliseconds
sub treshold {
    my $self     = shift;
    my $treshold = shift;

    $self->{treshold} = $treshold;

    return newrelic_transaction_set_threshold( $self->{tid},
        $self->{treshold} );
}

use Carp qw(shortmess longmess);

sub backtrace {
    my $self    = shift;
    my $type    = shift;
    my $message = shift;

    my $error = longmess($message);

    my @stack = map { s/^\s+//g; $_; } split /\n/, $error;

    newrelic_transaction_notice_error( $self->{tid}, $type, $message,
        join( "\n", @stack ), "\n" );
}

sub finish {
    my $self = shift;
    if ( exists $self->{tid} ) {
        newrelic_transaction_end( delete $self->{tid} );
    }
}

sub DESTROY {
    my $self = shift;
    $self->finish();
}

sub AUTOLOAD {

    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ( $constname = $AUTOLOAD ) =~ s/.*:://;
    croak "&Net::NewRelic::constant not defined" if $constname eq 'constant';
    my ( $error, $val ) = constant($constname);
    if ($error) { croak $error; }
    {
        no strict 'refs';

        # Fixed between 5.005_53 and 5.005_61
        #XXX	if ($] >= 5.00561) {
        #XXX	    *$AUTOLOAD = sub () { $val };
        #XXX	}
        #XXX	else {
        *$AUTOLOAD = sub { $val };

        #XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;

XSLoader::load( 'Net::NewRelic', $VERSION );

package Net::NewRelic::Segment;
use strict;

sub new {
    my $class = shift;
    my $tid   = shift;
    my $name  = shift;

    my $self = bless { level => 0, tid => $tid, name => $name }, $class;

    $self->{sid} =
      Net::NewRelic::newrelic_segment_generic_begin( $self->{tid},
        Net::NewRelic::ROOT_SEGMENT(), $name );

    return $self;
}

sub segment {
    my $self = shift;
    my $name = shift;

    my $segment = bless {
        level         => $self->{level} + 1,
        tid           => $self->{tid},
        parent        => $self->{sid},
        parent_object => $self,               #loop for proper destruction order
        name          => $name,
      },
      ref($self);

    $segment->{sid} =
      Net::NewRelic::newrelic_segment_generic_begin( $segment->{tid},
        $segment->{parent}, $segment->{name} );

    return $segment;
}

sub data_segment {
    my $self  = shift;
    my $table = shift;
    my $op    = shift;

    my $segment = bless {
        level         => $self->{level} + 1,
        name          => "$table $op",
        tid           => $self->{tid},
        parent        => $self->{sid},
        parent_object => $self,               #Loop for proper destruction order
        table         => $table,
        op            => $op,
      },
      ref($self);

    $segment->{sid} = Net::NewRelic::newrelic_segment_datastore_begin(
        $segment->{tid},   $segment->{parent},
        $segment->{table}, $segment->{op}
    );

    return $segment;
}

sub finish {
    my $self = shift;
    Net::NewRelic::newrelic_segment_end( $self->{tid}, delete $self->{sid} );
}

sub DESTROY {
    my $self = shift;
    $self->finish();
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Net::NewRelic - Perl extension the NewRelic Agent SDK

=head1 SYNOPSIS

  use Net::NewRelic;
  my $nr = Net::NewRelic->new();
  $nr->name("some name");
  $nr->url("/path/to/my/file.cgi");
  $nr->attribute("userid", $user->id);
  
  { #Work #1
    my $s = $nr->segment("Do work #1");
    [...]
  }
  { #Work #2
    my $s = $nr->segment("Do work #2");
    [...]
    
    { # Work #2.1
      my $ss = $s->segment("Do Work #2.1");
      [...]
    }
  }
  { #DB Work
    my $s = $nr->data_segment("table","select");
    [...]
  }
  

=head1 DESCRIPTION

This module allows you to report timing information to NewRelic.

Each segment you create will capture timing information until the object
comes out of scope.

=head2 NOTE

For this module to work, you need to ensure there is a running copy of 
newrelic-collector-client-daemon on the same system as this code is running.

  export NEWRELIC_LICENSE_KEY=abcdef1234567890
  export NEWRELIC_APP_NAME=some-application-name
  export NEWRELIC_APP_LANGUAGE=perl
  export NEWRELIC_APP_LANGUAGE_VERSION=5.5

  export LD_LIBRARY_PATH=/opt/newrelic/lib

  /opt/newrelic/bin/newrelic-collector-client-daemon

=head1 SEE ALSO

L<https://docs.newrelic.com/docs/features/agent-sdk>

=head1 AUTHOR

Philippe M. Chiasson, E<lt>gozer@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Philippe M. Chiasson

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
