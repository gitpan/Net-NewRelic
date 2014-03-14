#define PERL_constant_NOTFOUND	1
#define PERL_constant_NOTDEF	2
#define PERL_constant_ISIV	3
#define PERL_constant_ISNO	4
#define PERL_constant_ISNV	5
#define PERL_constant_ISPV	6
#define PERL_constant_ISPVN	7
#define PERL_constant_ISSV	8
#define PERL_constant_ISUNDEF	9
#define PERL_constant_ISUV	10
#define PERL_constant_ISYES	11

#ifndef NVTYPE
typedef double NV; /* 5.6 and later define NVTYPE, and typedef NV to it.  */
#endif
#ifndef aTHX_
#define aTHX_ /* 5.6 or later define this for threading support.  */
#endif
#ifndef pTHX_
#define pTHX_ /* 5.6 or later define this for threading support.  */
#endif

static int
constant (pTHX_ const char *name, STRLEN len, IV *iv_return) {
  /* Initially switch on the length of the name.  */
  /* When generated this function returned values for the list of names given
     in this section of perl code.  Rather than manually editing these functions
     to add or remove constants, which would result in this comment and section
     of code becoming inaccurate, we recommend that you edit this section of
     code, and use it to regenerate a new set of constant functions which you
     then use to replace the originals.

     Regenerate these constant functions by feeding this entire source file to
     perl -x

#!/home/gozer/perl5/perlbrew/perls/perl-blead/bin/perl5.17.10 -w
use ExtUtils::Constant qw (constant_types C_constant XS_constant);

my $types = {map {($_, 1)} qw(IV)};
my @names = (qw(ROOT_SEGMENT STATUS_DISABLED STATUS_INVALID_ID
	       STATUS_INVALID_PARAM STATUS_OK STATUS_OTHER
	       STATUS_TRANSACTION_IN_PROGRESS STATUS_TRANSACTION_NOT_NAMED
	       STATUS_TRANSACTION_NOT_STARTED));

print constant_types(), "\n"; # macro defs
foreach (C_constant ("Net::NewRelic", 'constant', 'IV', $types, undef, 3, @names) ) {
    print $_, "\n"; # C constant subs
}
print "\n#### XS Section:\n";
print XS_constant ("Net::NewRelic", $types);
__END__
   */

  switch (len) {
  case 9:
    if (memEQ(name, "STATUS_OK", 9)) {
#ifdef STATUS_OK
      *iv_return = STATUS_OK;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 12:
    /* Names all of length 12.  */
    /* ROOT_SEGMENT STATUS_OTHER */
    /* Offset 0 gives the best switch position.  */
    switch (*name++) {
    case 'R':
      if (memEQ(name, "OOT_SEGMENT", 11)) {
      /*                R                  */
#ifdef ROOT_SEGMENT
        *iv_return = ROOT_SEGMENT;
        return PERL_constant_ISIV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    case 'S':
      if (memEQ(name, "TATUS_OTHER", 11)) {
      /*                S                  */
#ifdef STATUS_OTHER
        *iv_return = STATUS_OTHER;
        return PERL_constant_ISIV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    }
    break;
  case 15:
    if (memEQ(name, "STATUS_DISABLED", 15)) {
#ifdef STATUS_DISABLED
      *iv_return = STATUS_DISABLED;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 17:
    if (memEQ(name, "STATUS_INVALID_ID", 17)) {
#ifdef STATUS_INVALID_ID
      *iv_return = STATUS_INVALID_ID;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 20:
    if (memEQ(name, "STATUS_INVALID_PARAM", 20)) {
#ifdef STATUS_INVALID_PARAM
      *iv_return = STATUS_INVALID_PARAM;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 28:
    if (memEQ(name, "STATUS_TRANSACTION_NOT_NAMED", 28)) {
#ifdef STATUS_TRANSACTION_NOT_NAMED
      *iv_return = STATUS_TRANSACTION_NOT_NAMED;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 30:
    /* Names all of length 30.  */
    /* STATUS_TRANSACTION_IN_PROGRESS STATUS_TRANSACTION_NOT_STARTED */
    /* Offset 20 gives the best switch position.  */
    switch (name[20]) {
    case 'N':
      if (memEQ(name, "STATUS_TRANSACTION_IN_PROGRESS", 30)) {
      /*                                   ^                */
#ifdef STATUS_TRANSACTION_IN_PROGRESS
        *iv_return = STATUS_TRANSACTION_IN_PROGRESS;
        return PERL_constant_ISIV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    case 'O':
      if (memEQ(name, "STATUS_TRANSACTION_NOT_STARTED", 30)) {
      /*                                   ^                */
#ifdef STATUS_TRANSACTION_NOT_STARTED
        *iv_return = STATUS_TRANSACTION_NOT_STARTED;
        return PERL_constant_ISIV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

