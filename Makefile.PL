use lib qw(inc);
use Devel::CheckLib;

my $newrelic = "/opt/newrelic";
my $newrelic_inc = "/opt/newrelic/include";
my $newrelic_lib = "/opt/newrelic/lib";

$ENV{LD_LIBRARY_PATH} = $newrelic_lib;

check_lib_or_exit(
    # fill in what you prompted the user for here
    lib => [qw(newrelic-common newrelic-transaction)],
    header => [qw(newrelic_common.h  newrelic_transaction.h)],
    incpath => [$newrelic_inc],
    libpath => [$newrelic_lib],
);

use 5.008000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Net::NewRelic',
    VERSION_FROM      => 'lib/Net/NewRelic.pm', # finds $VERSION
    PREREQ_PM         => {
      'LWP'           => 0,
      'HTTP::Request' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Net/NewRelic.pm', # retrieve abstract from module
       AUTHOR         => 'Philippe M. Chiasson <gozer@ectoplasm.org>') : ()),
    LIBS              => ["-L$newrelic_lib -lnewrelic-common -lnewrelic-transaction"], # e.g., '-lm'
    DEFINE            => '',
    INC               => "-I$newrelic_inc",
    dynamic_lib       => { OTHERLDFLAGS => "-Wl,-rpath,$newrelic_lib" },
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
    (MM->can('signature_target') ? (SIGN => 1) : ()),
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw(
    STATUS_OK
    STATUS_OTHER
    STATUS_DISABLED
    STATUS_INVALID_PARAM
    STATUS_INVALID_ID
    STATUS_TRANSACTION_NOT_STARTED
    STATUS_TRANSACTION_IN_PROGRESS
    STATUS_TRANSACTION_NOT_NAMED
    ROOT_SEGMENT
  ));
  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'Net::NewRelic',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}
