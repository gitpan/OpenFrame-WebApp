use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME          => "OpenFrame-WebApp",
	      VERSION_FROM  => "lib/OpenFrame/WebApp.pm",
	      ABSTRACT_FROM => "lib/OpenFrame/WebApp.pm",
	      PREREQ_PM     => {
			        'Test::More'      => '0.01',
			        'Cache::Cache'    => '1.01',
			        'OpenFrame'       => '3.00',
			        'Pipeline'        => '3.04',
			        'Time::ParseDate' => '2003.0',
			       },
	     );


package MY;

# Enable "make cover" target
sub postamble {
    my $cover_header =
	"\n" .
	"# --- Customized Makefile.PL test coverage section:\n" .
	"cover:\n";
    if ($^O =~ /win32/i) {
	return $cover_header .
	    "\techo last time I checked, Devel::Cover was not available on Win32\n" .
	    "\n";
    } else {
	return $cover_header .
	    "\t\$(RM_RF) cover_db\n" .
	    "\tPERL5OPT=-MDevel::Cover \$(MAKE) test || true\n" .
	    "\tcover -report html cover_db > /dev/null\n" .
	    "\n";
    }
}

