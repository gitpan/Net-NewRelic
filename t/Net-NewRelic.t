# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Net-NewRelic.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

my @constants = qw(
  STATUS_OK
  STATUS_OTHER
  STATUS_DISABLED
  STATUS_INVALID_PARAM
  STATUS_INVALID_ID
  STATUS_TRANSACTION_NOT_STARTED
  STATUS_TRANSACTION_IN_PROGRESS
  STATUS_TRANSACTION_NOT_NAMED
  ROOT_SEGMENT
);

use Test::More;
plan tests => 1 + @constants;

use_ok('Net::NewRelic');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

foreach my $constant (@constants) {
    ok( defined Net::NewRelic->$constant(), "Constant $constant" );
}

#Net::NewRelic->deploy(
#    application_id => 3750592,
#    description    => "Unit-test run",
#    revision       => 1234,
#);

use Time::HiRes qw(usleep);

my $nr = Net::NewRelic->new();
$nr->treshold(4_000);

$nr->name("show_bug");
$nr->url("/show_bug2.cgi?test=unit");

$nr->attribute( "bug_id",     int( rand(1_000_000) ) );
$nr->attribute( "user_id",    int( rand(10_000) ) );
$nr->attribute( "process_id", int( rand(65_000) ) );

{
    my $s = $nr->segment("Load Objects");
    usleep( 1_000_000 * ( 1 + rand(2) ) );
    {
        my $ss = $s->segment("Load User");
        usleep( 1_000_000 * ( 1 + rand(2) ) );
        {
            my $sss = $ss->data_segment( "users", "select" );
            usleep( 1_000_000 * ( 1 + rand(1) ) );
        }
        {
            my $sss = $ss->data_segment( "groups", "select" );
            usleep( 1_000_000 * ( 1 + rand(1) ) );
        }
    }
    {
        my $ss = $s->segment("Load Bug");
        usleep( 1_000_000 * ( 1 + rand(2) ) );

        my $sss = $ss->data_segment( "bugs", "select" );
        usleep( 1_000_000 * ( 1 + rand(1) ) )
    }
}

{
    my $s = $nr->segment("Load Templates");
    usleep( 1_000_000 * ( 1 + rand(2) ) );
}

{
    my $s = $nr->segment("Render Templates");
    usleep( 1_000_000 * ( 1 + rand(2) ) );
}

if ( rand(1) >= 0.8 ) {
    wrench($nr);
}

sub wrench {
    my $nr = shift;
    throw_it($nr);
}

sub throw_it {
    my $nr = shift;
    hard($nr);
}

sub hard {
    my $nr = shift;
    $nr->backtrace( 'diag', "Testing wrench throwing" );
}
