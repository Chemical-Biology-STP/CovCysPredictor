#!/usr/bin/perl -w
#Author Date Modification
#Andrei A Golosov 5/22 Created

use Getopt::Std;
use vars qw($opt_h $opt_H);
getopts('hH');
$prog_name = `basename $0`; chomp($prog_name);
if ($opt_h || $opt_H) {
  print "Description:\n Processing the file containing LINK record containing e.g. obtatined by grep ^LINK */*pdb\n Expects only lines like this:
1aec/1aec.pdb:LINK         SG  CYS A  25                 C2  E64 A 219     1555   1555  1.80
And converts them into:
1AEC.A,1aec,A,25,CYS,C2
\nusage: $prog_name <linkrecords_file \n$prog_name -h or $prog_name -H for help\nExample: $prog_name <cys_link-info.txt >output.csv \ncat cys_link-info.txt | $prog_name > output.csv\n";
  exit 0;
};

while (<STDIN>) {
 if (!/:LINK/) { 
  print; 
  die "is it LINK file containing only lines such as this? 
  1aec/1aec.pdb:LINK         SG  CYS A  25                 C2  E64 A 219     1555   1555  1.80
  \n";
 };
#below is the format of LINK file
#1aec/1aec.pdb:LINK         SG  CYS A  25                 C2  E64 A 219     1555   1555  1.80
 $line = $_; chomp($line);
 ($dir_and_pdb,$link) = split /:LINK/,$line; $link = "LINK$link"; chomp($link);
# print "$dir:\n$link\n";
#1aec/1aec.pdb -> 1aec 1aec.pdb
 $dir = "";
 ($dir,$pdb) = split /\//, $dir_and_pdb; chomp($pdb);
#parse link records
 $atom1 = substr($link,12,4);  $atom1 =~ s/\s*(\S+)\s*/$1/g;
 $alt1 = substr($link,16,1);  $alt1 =~ s/\s*(\S+)\s*/$1/g;
 $resn1 = substr($link,17,3);  $resn1 =~ s/\s*(\S+)\s*/$1/g;
 $chain1 = substr($link,21,1);  $chain1 =~ s/\s*(\S+)\s*/$1/g;
 $resi1 = substr($link,22,4);  $resi1 =~ s/\s*(\S+)\s*/$1/g;
 $icode1 = substr($link,26,1);  $icode1 =~ s/\s*(\S+)\s*/$1/g;
# print "$atom1 $alt1 $resn1 $chain1 $resi1\n";
 $atom2 = substr($link,42,4);  $atom2 =~ s/\s*(\S+)\s*/$1/g;
 $alt2 = substr($link,46,1);  $alt2 =~ s/\s*(\S+)\s*/$1/g;
 $resn2 = substr($link,47,3);  $resn2 =~ s/\s*(\S+)\s*/$1/g;
 $chain2 = substr($link,51,1);  $chain2 =~ s/\s*(\S+)\s*/$1/g;
 $resi2 = substr($link,52,4);  $resi2 =~ s/\s*(\S+)\s*/$1/g;
 $icode2 = substr($link,56,1);  $icode2 =~ s/\s*(\S+)\s*/$1/g;
#converting to format: 1AEC.A,1aec,A,25,CYS,C2
 $pdb =~ s/.pdb//g;
 if ($resn1 eq "CYS" && $resn2 ne "CYS") {
  $pdb_and_chain = uc "$pdb.$chain1"; 
  $rec = "$pdb_and_chain,$pdb,$chain1,$resi1,$resn1,$atom2";
 }
 elsif ($resn2 eq "CYS" && $resn1 ne "CYS") {
  $pdb_and_chain = uc "$pdb.$chain2"; 
  $rec = "$pdb_and_chain,$pdb,$chain2,$resi2,$resn2,$atom1";
 }
 elsif ($resn2 eq "CYS" && $resn1 eq "CYS") {
  $rec = "ERROR: both CYS"; 
 }
 else {
  $rec = "ERROR: no CYS?"; 
 }
 #print "$dir,$rec\n";
 print "$rec\n";
}
