#!/usr/bin/env perl

# Summary: The script avoid the need to manualy login every month in http://www.noip.com and update your domains to keep them alive.
#          It will automaticaly retrieve his current public IP from http://checkip.dyndns.org/
# Author: @LukeOwncloud, based on RB version by Felipe Molina (@felmoltor)
# Date: July 2016
# License: GPLv3

use WWW::Mechanize;

sub getIp{
  my $mech = WWW::Mechanize->new();
  $mech->agent_alias( 'Windows Mozilla' );
  $mech -> get('https://api.ipify.org');
  return $mech-> content();
}

sub setIp{
  my ($username, $password, $myIp) = @_;
  my $mech = WWW::Mechanize->new();
  $mech->agent_alias( 'Windows Mozilla' );
  $mech -> cookie_jar(HTTP::Cookies->new());
  $mech -> get('https://www.noip.com/login/');
  $mech -> form_id('clogs');
  $mech -> field ('username' => $username);
  $mech -> field ('password' => $password);
  $mech -> submit ();
  $mech -> get('https://www.noip.com/members/dns/');
  my @links = $mech->find_all_links( text => 'Modify' )
            or die "No modify links were found.\n";
  my @updated_hosts = ();
  foreach $link (@links){
    $mech -> get( $link->url_abs());
    my $form = $mech->form_number(1);
    my $host = $mech->value('host[host]');
    my $domain = $mech->value('host[domain]');
    $mech->field('host[ip]' => $myIp);
    push @updated_hosts, $host.'.'.$domain;
  }
  return @updated_hosts;
}

##### MAIN #####

$numArgs = $#ARGV + 1;
if ($numArgs != 2) {
  die "Need noip username and password.\n";
}
my ($username, $password) = @ARGV;

print "Getting public IP...\n";
my $myIp = getIp();
print "Done. ".$myIp."\n";
print "Sending Keep Alive request to noip.com...\n";
@updated_hosts = setIp($username, $password, $myIp);

if(@updated_hosts) {
  print "Done. Updated ". scalar @updated_hosts ." host(s).\n";
} else {
  print STDERR "There was an error updating the domains of noip.com or there were no hosts to update.\n";
}
