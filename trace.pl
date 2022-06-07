#!/usr/bin/perl
use File::Basename;
use DateTime;
use strict;
use warnings;

####################################################
# Simple script to pull certain information from PBS
#

# Begin regex
my $qrwalltime = qr/((?<=used.walltime=)[0-9]+\:[0-9]{1,2}\:[0-9]{2})/;
my $qrpbsmem = qr/((?<=List\.mem\=)[0-9]+)/;
my $qrversion = qr/((?<=app\_version\=).{1,10})/;
my $qrvmem = qr/((?<=vmem=)[0-9]+kb)/;
my $qrmem = qr/((?<=\.mem=)[0-9]+kb)/; 
my $qrvnode = qr/((?<=vnode\ \()hpc[a-z]{1}[0-9]{2}[a-z]{1}[0-9]{2}[a-z]{1}[0-9]{2}(?=\:))/;
my $qrcpus = qr/((?<=ncpus=)[0-9]{1,3}(?=\)))/;
my $qrjobname = qr/((?<=jobname\=).+(?=que))/;

my $dt = DateTime->now(time_zone => 'America/Detroit');
my $date = sprintf("%s%s-%s%s", $dt->month, $dt->day, $dt->hour, $dt->minute);

my $res= "";
my $self = basename($0);
my $ARGC = scalar(@ARGV);
my $parsestr;
my $retstr;

my $mem;
my $memgb;
my $vmem;
my $vmemgb;
my $cpus;
my $vnode;
my $walltime;
my $pbsmem;
my $version;
my $jobname;
my @OUT;
my @CSV;

my $filename;
my $iscsv = 0; 

if (($ARGV[0] =~ /-h/) || ($ARGC < 1)) {
   help();
}

sub parse {

   my $qserver = "";
   my $time = 30;
   my $mainq = "hpcq";
   my $job = $_[0];
   my $tc_cmd = "/opt/pbs/bin/tracejob -n $time";
   my $findq = qx(ssh -qt $mainq $tc_cmd $job);

   foreach my $line (split /[\r\n]+/, $findq) {
      $qserver = $1 if ($line =~ /(hpcq[0-9][a-z])/);
   }
   print "Using $qserver\n";
   
   my $out = `ssh -qt $qserver $tc_cmd $job`;
   foreach my $line (split /[\r\n]+/, $out) {
      $jobname = $1 if ($line =~ /$qrjobname/);
      $walltime = $1 if ($line =~ /$qrwalltime/);  
      $pbsmem = $1 if ($line =~ /$qrpbsmem/);
      $version = $1 if ($line =~ /$qrversion/);
      $mem = $1 if ($line =~ /$qrmem/);
      $mem =~ s/kb//g if $mem;
      $vmem = $1 if ($line =~ /$qrvmem/);
      $vmem =~ s/kb//g if $vmem;;
      $cpus = $1 if ($line =~  /$qrcpus/);
      $vnode = $1 if ($line =~  /$qrvnode/);
      $res = $1 if ($line =~ /(.*user=.*\sgroup.*)/);
      $vmemgb = ($vmem/1048576) if $vmem;
      $memgb = ($mem/1048576) if $mem;
   }
   
   $retstr = sprintf("%s, %s, %s, %s, %s, %s, %s, %skb, %.2fgb, %skb, %.2fgb", $job, $jobname, $vnode, $version, $pbsmem, $cpus, $walltime, $mem, $memgb, $vmem, $vmemgb);
   return $retstr;
   # End function
}

# Setting -csv option
if ( grep(/-csv/, @ARGV)) {
   $iscsv = 1;
}
if ($iscsv == 1) {
      @CSV = grep(/.*\.csv/, @ARGV);
      if ($CSV[0]) {
         $filename = $CSV[0];
         if (-f $filename) {
            print "File $filename exists\n";
            exit(1);
         }
      } else {
         $filename = qq($date.csv);
      }
     
      open(FH, '>', $filename) or die "Could not write to file '$filename' $!";
      print FH "Job ID, Jobname, ExecHost, Version, PBSMem, CPUs, Walltime, Mem (kb), Mem (Gb), Mem (kb), Vmem (Gb)\n";
}

# Argument parsing
foreach (@ARGV) {
   next if ($_ !~ /[0-9]+\.hpcq/);
   $parsestr = parse($_);
   if ($iscsv == 1) {
      print FH $parsestr, "\n";
      print "Output for $_ written to $filename\n";
   } else {
      @OUT = split(",", $parsestr);
         print "Job ID:\t\t $OUT[0]\n"; 
         print "Jobname:\t$OUT[1]\n";
         print "ExecHost:\t$OUT[2]\n";
         print "Version:\t$OUT[3]\n";
         print "PBSMem:\t\t$OUT[4]\n";
         print "CPUs:\t\t$OUT[5]\n";
         print "Walltime:\t$OUT[6]\n";
         print "Mem(kb):\t$OUT[7]\n";
         print "Mem(Gb):\t$OUT[8]\n";
         print "VMem(kb):\t$OUT[9]\n";
         print "VMem(Gb):\t$OUT[10]\n";
   }
}
close(FH);
print "Done\n";

sub help {
print<<EOF;
Script to parse certain information from PBS history

Usage: 
   $self [options] [jobid.hpcq]

   Available options:
         -csv [\$FILE] - Store output in csv (optional FILE)
         -h          - Show this help

EOF
exit;
}
