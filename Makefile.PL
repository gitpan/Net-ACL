use ExtUtils::MakeMaker;
# $Id: Makefile.PL,v 1.5 2003/05/27 13:53:07 unimlo Exp $
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::ACL',
    'VERSION_FROM'	=> 'lib/Net/ACL.pm', # finds $VERSION
    'PREREQ_PM'		=> {
				Net::Netmask => 1.9003, # 1.9002 missing features!
				Scalar::Util => 1.0,
				# Net::BGP => 0.03, # Optional!
				Cisco::Reconfig => 0.3
			   },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Net/ACL.pm', # retrieve abstract from module
       AUTHOR     => 'Martin Lorensen <cpan@martin.lorensen.dk>') : ()),
);
