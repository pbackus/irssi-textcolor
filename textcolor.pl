use strict;
use warnings;
use Irssi;

our $VERSION = '0.1.0';
our %IRSSI = (
	authors     => 'Paul Backus',
	contact     => 'snarwin@gmail.com',
	name        => 'textcolor',
	description => 'Colors your messages',
	license     => 'MIT',
	url         => 'https://github.com/pbackus/irssi-textcolor/blob/master/textcolor.pl',
);

# English names for colors, and the corresponding control codes.
my %colors = (
	# regular colors
	'black'       => '1',
	'blue'        => '2',
	'green'       => '3',
	'red'         => '5',
	'purple'      => '6',
	'yellow'      => '7',
	'cyan'        => '10',
	'lightgray'   => '15', 'lightgrey' => '15',
	# bright colors
	'white'        => '0',
	'lightred'     => '4',
	'lightyellow'  => '8',
	'lightgreen'   => '9',
	'lightcyan'    => '11',
	'lightblue'    => '12',
	'magenta'      => '13',
	'darkgray'     => '14', 'darkgrey'   => '14',
);

# Returns true if the given string is a color name we recognize.
sub is_color_name {
	my $cname = $_[0];
	return scalar grep {$cname eq $_} keys(%colors);
}

# We want to disable colors when talking to network services (eg, nickserv),
# since they'll interpret the control codes as bogus commands.
# This checks a window item and returns true if it's a query with a service.
# (TODO: make this more portable)
sub is_service {
	my $win_item = $_[0];
	if ($win_item->{type} eq "QUERY") {
		return scalar $win_item->{address} =~ /services@/;
	}
}

# Signal handler
sub color_text {
	my ($text, $server, $win_item) = @_;
	my $cname = Irssi::settings_get_str('textcolor');
	my $enabled = Irssi::settings_get_bool('textcolor_enable');

	# Check to see if we can and should proceed
	return unless $enabled && is_color_name($cname) && !is_service($win_item);

	# Use a zero-width space to separate the control code from the message
	my $colored_text = "\cC" . $colors{$cname} . "\N{U+200B}" . $text;
	Irssi::signal_continue($colored_text, $server, $win_item);
}

Irssi::settings_add_str('textcolor', 'textcolor', 'lightgray');
Irssi::settings_add_bool('textcolor', 'textcolor_enable', 0);

Irssi::signal_add_first('send text', \&color_text);
