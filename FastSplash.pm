# -*- perl -*-

#
# $Id: FastSplash.pm,v 1.2 1999/12/20 22:29:28 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1999 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

package Tk::Splash;

sub Show {
    my($pkg, $image_file, $image_width, $image_height, $title) = @_;
    $title = $0 if !defined $title;
    my $splash_screen = {};
    eval {
	package Tk;
	require DynaLoader;
	eval q{ require Tk::Event };
	@ISA = qw(DynaLoader);
	bootstrap Tk;
	sub TranslateFileName { $_[0] }
	sub SplitString { split /\s+/, $_[0] } # rough approximation

	package Tk::Photo;
	@ISA = qw(DynaLoader);
	bootstrap Tk::Photo;

	package Tk::Splash;
	sub _Destroyed { }
	$splash_screen = Tk::MainWindow::Create(".", $title);
	bless $splash_screen, Tk::MainWindow;
	Tk::image($splash_screen, 'create', 'photo', 'splashphoto',
		  -file => $image_file);
	my $sw = Tk::winfo($splash_screen, 'screenwidth');
	my $sh = Tk::winfo($splash_screen, 'screenheight');
	Tk::wm($splash_screen, "geometry",
	       "+" . int($sw/2 - $image_width/2) .
	       "+" . int($sh/2 - $image_height/2));
	my $l = Tk::label($splash_screen, '.splashlabel',
			  # dummy font to satisfy SplitString
			  -font => "Helvetica 10",
			  -image => 'splashphoto');
	$l->{'_TkValue_'} = '.splashlabel';
	bless $l, Tk::Widget;
	Tk::pack($l, -fill => 'both', -expand => 1);
	Tk::update($splash_screen);
	$splash_screen->{Exists} = 1;
    };
    warn $@ if $@;
    bless $splash_screen, $pkg;
}

sub Raise {
    my $w = shift;
    if ($w->{Exists}) {
	Tk::catch { Tk::raise($w) };
    }
}

sub Destroy {
    my $w = shift;
    if ($w->{Exists}) {
	Tk::catch { Tk::destroy($w) };
    }
}

1;

=head1 NAME

Tk::Splash - create a fast starting splash screen

=head1 SYNOPSIS

    BEGIN {
        require Tk::Splash;
        $splash = Tk::Splash->Show($image, $width, $height, $title);
    }
    ...
    use Tk;
    ...
    $splash->Destroy;
    MainLoop;

=head1 DESCRIPTION

This module creates a splash screen for perl/Tk programs. It uses
lowlevel perk/Tk stuff, so upward compatibility is not given (however,
the module should work for Tk402.xxx and Tk800.xxx). The splash screen
is created with the B<Show> function. Supplied arguments are: filename
of the displayed image, width and height of the image and the string
for the title bar. If something goes wrong, then B<Show> will silently
ignore all errors and continue without a splash screen. The splash
screen can be destroyed with the B<Destroy> method, best short before
calling B<MainLoop>.

=head1 AUTHOR

Slaven Rezic

=cut

__END__
