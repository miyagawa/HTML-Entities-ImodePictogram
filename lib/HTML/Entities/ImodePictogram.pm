package HTML::Entities::ImodePictogram;

use strict;
use vars qw($VERSION);
$VERSION = '0.03';

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA       = qw(Exporter);
@EXPORT    = qw(encode_pictogram decode_pictogram remove_pictogram);
@EXPORT_OK = qw(find_pictogram);
%EXPORT_TAGS = ( all => [ @EXPORT, @EXPORT_OK ] );

my $one_byte  = '[\x00-\x7F\xA1-\xDF]';
my $two_bytes = '[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]';

use vars qw($Pictogram_re $Sjis_re);
$Pictogram_re = '\xF8[\x9F-\xFC]|\xF9[\x40-\x7E\x80-\xAF]';
$Sjis_re      = qr<$one_byte|$two_bytes|$Pictogram_re>;

sub find_pictogram (\$&) {
    my($r_text, $callback) = @_;

    my $num_found = 0;
    $$r_text =~ s{($Sjis_re)}{
	my $orig_match = $1;
	if ($orig_match =~ /^$Pictogram_re$/) {
	    $num_found++;
	    $callback->($orig_match, unpack('n', $orig_match));
	}
	else {
	    $orig_match;
	}
    }eg;

    return $num_found;
}

sub encode_pictogram {
    my $text = shift;
    find_pictogram($text, sub {
		       my($char, $number) = @_;
		       return '&#' . $number . ';';
		   });
    return $text;
}

sub decode_pictogram {
    my $html = shift;
    $html =~ s{(\&\#(\d{5});)}{
	if (($2 >= 63647 && $2 <= 63740) ||
	    ($2 >= 63808 && $2 <= 63870) ||
	    ($2 >= 63872 && $2 <= 63919)) {
	    pack 'n', $2;
	}
	else {
	    $1;
	}
    }eg;
    return $html;
}

sub remove_pictogram {
    my $text = shift;
    find_pictogram($text, sub {
		       return '';
		   });
    return $text;
}

1;
__END__

=head1 NAME

HTML::Entities::ImodePictogram - encode / decode i-mode pictogram

=head1 SYNOPSIS

  use HTML::Entities::ImodePictogram;

  $html      = encode_pictogram($rawtext);
  $rawtext   = decode_pictogram($html);
  $cleantext = remove_pictogram($rawtext);

  use HTML::Entities::ImodePictogram qw(find_pictogram);

  $num_found = find_pictogram($rawtext, \&callback);

=head1 DESCRIPTION

HTML::Entities::ImodePictogram handles HTML entities for i-mode
pictogram (emoji), which are assigned in Shift_JIS private area.

See http://www.nttdocomo.co.jp/i/tag/emoji/index.html for details
about i-mode pictogram.

=head1 FUNCTIONS

In all functions in this module, input/output strings are asssumed as
encoded in Shift_JIS. See L<Jcode> for conversion between Shift_JIS
and other encodings like EUC-JP or UTF-8.

This module exports following functions by default.

=over 4

=item encode_pictogram

  $html = encode_pictogram($rawtext);

Encodes pictogram characters in raw-text into HTML entities.

=item decode_pictogram

  $rawtext = decode_pictogram($html);

Decodes HTML entities for pictogram into raw-text.

=item remove_pictogram

  $cleantext = remove_pictogram($rawtext);

Removes pictogram characters in raw-text.

=back

This module also exports following functions on demand.

=over 4

=item find_pictogram

  $num_found = find_pictorgram($rawtext, \&callback);

Finds pictogram characters in raw-text and executes callback when
found. It returns the total numbers of charcters found in text.

The callback is given two arguments. The first is a found pictogram
character itself, and the second is a decimal number which represents
codepoint of the character. Whatever the callback returns will replace
the original text.

Here is an implementation of encode_pictogram(), which will be the good
example for the usage of find_pictogram().

  sub encode_pictogram {
      my $text = shift;
      find_pictogram($text, sub {
			 my($char, $number) = @_;
			 return '&#' . $number . ';';
		     });
      return $text;
  }

=back

=head1 CAVEAT

This module works so slow, because regex used here matches C<ANY>
characters in the text. This is due to the difficulty of extracting
character boundaries of Shift_JIS encoding.

=head1 AUTHOR

Tatsuhiko Miyagawa <miyagawa@bulknews.net>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTML::Entities>, http://www.nttdocomo.co.jp/i/tag/emoji/index.html

=cut

