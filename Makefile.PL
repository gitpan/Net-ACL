use ExtUtils::MakeMaker;
# $Id: Makefile.PL,v 1.6 2003/05/28 22:19:14 unimlo Exp $
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::ACL',
    'VERSION_FROM'	=> 'lib/Net/ACL.pm', # finds $VERSION
    'PREREQ_PM'		=> {
				Net::Netmask => 1.9004, # 1.9003 missing 'any'
				List::Util => 1.01, # Actully Scalar::Util - but't has no working version number
				# Net::BGP => 0.03, # Optional!
				Cisco::Reconfig => 0.5
			   },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Net/ACL.pm', # retrieve abstract from module
       AUTHOR     => 'Martin Lorensen <lorensen@cpan.org>') : ()),
);
