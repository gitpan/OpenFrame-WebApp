#!/usr/bin/perl

##
## Tests for OpenFrame::WebApp::Segment::Decline::*
##

use blib;
use strict;
use warnings;

use Test::More no_plan => 1;

use Pipeline::Segment::Tester;

BEGIN { use_ok("OpenFrame::WebApp::Segment::Decline"); }

## basic tests
{
    my $pt  = new Pipeline::Segment::Tester;
    my $seg = new Test::Segment::Decline;
    ok( $seg, "new" ) || die( "can't create new object!" );
    is( $pt->test( $seg ), 'decline test', "decline test" );
}

{
    my $pt  = new Pipeline::Segment::Tester;
    my $seg = new Test::Segment::DontDecline;
    isnt( $pt->test( $seg ), 'decline test', "don't decline test" );
}

## test session decliners
if (use_ok("OpenFrame::WebApp::Segment::Decline::SessionInStore")) {
    use_ok("OpenFrame::WebApp::Session::MemCache");
    my $pt   = new Pipeline::Segment::Tester;
    my $seg  = new OpenFrame::WebApp::Segment::Decline::SessionInStore;
    my $session = new OpenFrame::WebApp::Session::MemCache;
    unlike( $pt->test( $seg ),           qr/declined/, "session not in store" );
    like  ( $pt->test( $seg, $session ), qr/declined/, "session in store" );
}

## test user decliners
if (use_ok("OpenFrame::WebApp::Segment::Decline::UserInStore")) {
    use_ok("OpenFrame::WebApp::User");
    my $pt   = new Pipeline::Segment::Tester;
    my $seg  = new OpenFrame::WebApp::Segment::Decline::UserInStore;
    my $user = new OpenFrame::WebApp::User;
    unlike( $pt->test( $seg ),        qr/declined/, "user not in store" );
    like  ( $pt->test( $seg, $user ), qr/declined/, "user in store" );
}

if (use_ok("OpenFrame::WebApp::Segment::Decline::UserInSession")) {
    use_ok("OpenFrame::WebApp::Session::MemCache");
    my $pt   = new Pipeline::Segment::Tester;
    my $seg  = new OpenFrame::WebApp::Segment::Decline::UserInSession;
    my $session = new OpenFrame::WebApp::Session::MemCache;
    unlike( $pt->test( $seg, $session ), qr/declined/, "user not in session" );
    $session->set( 'user', {} );
    like( $pt->test( $seg, $session ), qr/declined/, "user in session" );
}

## test template decliners
if (use_ok("OpenFrame::WebApp::Segment::Decline::TemplateInStore")) {
    my $pt   = new Pipeline::Segment::Tester;
    my $seg  = new OpenFrame::WebApp::Segment::Decline::TemplateInStore;
    my $template = new Test::Template;
    unlike( $pt->test( $seg ),            qr/declined/, "template not in store" );
    like  ( $pt->test( $seg, $template ), qr/declined/, "template in store" );
}


package Test::Segment::Decline;
use base qw( OpenFrame::WebApp::Segment::Decline );
use constant message => 'decline test';
sub should_decline { return 1; }

package Test::Segment::DontDecline;
use base qw( OpenFrame::WebApp::Segment::Decline );
sub should_decline { return; }

package Test::Template;
use base qw( OpenFrame::WebApp::Template );
# need a BEGIN or this gets executed last:
BEGIN { OpenFrame::WebApp::Template->types->{test} = __PACKAGE__; }
sub default_processor { return {}; }
sub process_template  { return "processed"; }

