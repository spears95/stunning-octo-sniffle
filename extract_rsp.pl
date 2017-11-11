#!/usr/bin/perl
# Author: Cheol Ho Lim in MSC GmbH.

use strict;
use warnings;
use diagnostics;

use Path::Tiny;
use autodie; # die if problem reading or writing a file

# check the argument. 1 argument returns 0. so should do plus (+) 1.
#my $num_args = $#ARGV + 1;

# in case of no argument, it exits with some prints. 
#if ($num_args != 1) {
#    print "\nUsage: extract_rsp.pl [the location of build.log]\n";
#	print "\n*** the file name should be build.log ***\n";
#	#print $num_args;
#    exit;
#}

# @ARGV;
#my $directory_name = $ARGV[0];

# default file name - build.log
my $file_name = "build.log";

# substitute known file name. 
#$directory_name =~ s{build.log}{}g;
#print "directory name : ";
#print $directory_name;
#print "\r\n";

#my $dir = path("C:/Users/Cheol Ho Lim/Documents/MAKE"); 
# put directory name to be searched.
#my $dir = path($directory_name);  
my $dir = path("./build");  
my $dir_temp = path("./");

# put file name to be opened.
my $file_rd = $dir->child($file_name);

# file list to be generated in the file.
my $file_wr_rte = $dir_temp->child("temp_rte.rsp");
my $file_wr_inv = $dir_temp->child("temp_inv.rsp");
my $file_wr_bsw = $dir_temp->child("temp_bsw.rsp");
my $file_wr_std_arch = $dir_temp->child("temp_std_arch.rsp");
my $file_wr_dff = $dir_temp->child("temp_dff.rsp");

# openr_utf8() returns an IO::File object to read from
# with a UTF-8 decoding layer
my $file_rd_handle = $file_rd->openr_utf8();
my $file_wr_rte_handle = $file_wr_rte->openw_utf8();
my $file_wr_inv_handle = $file_wr_inv->openw_utf8();
my $file_wr_bsw_handle = $file_wr_bsw->openw_utf8();
my $file_wr_std_arch_handle = $file_wr_std_arch->openw_utf8();
my $file_wr_dff_handle = $file_wr_dff->openw_utf8();

# after this, commands will be collected and transferred to makefile.
my $line_start = "-- creating ident header for library RTE_lib\r\n";

# a flag means it starts extracting from build.log. 
my $flag0 = 0;

# a flag means it starts collecting and making .rsp.
my $flag1 = 0;

# a flag for rte library.
my $flag_rte = 0;

# a flag for inv library.
my $flag_inv = 0;

# a flag for bsw library.
my $flag_bsw = 0;

# a flag for std arch library.
my $flag_std_arch = 0;

# a flag for dff library.
my $flag_dff = 0;

# Read in line at a time
while( my $line = $file_rd_handle->getline() ) {
	
	# it starts collecting some from this line.
	if( $line eq $line_start ) {
		$flag0 = 0xAAAA;
	}
	
	# it is ready to extract some from the file.
	if( $flag0 == 0xAAAA ) {
		
		# it decides which file should have them.
		if( $line =~ m{RTE_lib.err} ) {
			if( $flag_rte == 0 ) {
				$flag_rte = 0xEE11;
			}
			else {
				$flag_rte = 0;
			}
		} 
		elsif( $line =~ m{INV_lib.err} ) {
			if( $flag_inv == 0 ) {
				$flag_inv = 0xEE22;
			} 
			else {
				$flag_inv = 0;
			}
		}
		elsif( $line =~ m{BSW_lib.err} ) {
			if( $flag_bsw == 0 ) {
				$flag_bsw = 0xEE33;
			}
			else {
				$flag_bsw = 0;
			}
		}
		elsif( $line =~ m{STD_ARCH_lib.err} ) {
			if( $flag_std_arch == 0 ) {
				$flag_std_arch = 0xEE44;
			}
			else {
				$flag_std_arch = 0;
			}
		}
		elsif( $line =~ m{DFF_lib.err} ) {
			if( $flag_dff == 0 ) {
				$flag_dff = 0xEE55;
			}
			else {
				$flag_dff = 0;
			}
		}
		
		# "C:\\Users" and ".rsp contains" is a starting point.
		if( $line =~ m{C:\\Users} && $line =~ m{\.rsp contains}) {
			$flag1 = 0xBBBB;
			next;
		}
		
		# it is collecting some from the file.
		if( $flag1 == 0xBBBB ) {
			#"C:\\Users" and ".rsp end" is an end point.
			if( $line =~ m{C:\\Users} && $line =~ m{\.rsp end} ) {
				$flag1 = 0;
			} 
			# before end point, it is transferred to the file. 
			else {
				# before transferring, it decides which file should have them. 
				if( $flag_rte == 0xEE11 ) {
					$file_wr_rte_handle->print($line);
				}
				elsif( $flag_inv == 0xEE22 ) {
					$file_wr_inv_handle->print($line);
				}
				elsif( $flag_bsw == 0xEE33 ) {
					$file_wr_bsw_handle->print($line);
				}
				elsif( $flag_std_arch == 0xEE44 ) {
					$file_wr_std_arch_handle->print($line);
				}
				elsif( $flag_dff == 0xEE55 ) {
					$file_wr_dff_handle->print($line);
				}
			}
		}
	} # if( $flag0 == 0xAAAA )
	
} # while( my $line = $file_rd_handle->getline() )

# close file handle at the end
close $file_wr_rte_handle;
close $file_wr_inv_handle;
close $file_wr_bsw_handle;
close $file_wr_std_arch_handle;
close $file_wr_dff_handle;
close $file_rd_handle;
