use strict;
use Test;
BEGIN { plan tests => 6 }

use HTML::Entities::ImodePictogram qw(:all);

# てすと[晴れ][曇り]てすと
my $raw  = "\x82\xc4\x82\xb7\x82\xc6\xf8\x9f\xf8\xa0\x82\xc4\x82\xb7\x82\xc6"; 
my $html = "\x82\xc4\x82\xb7\x82\xc6&#63647;&#63648;\x82\xc4\x82\xb7\x82\xc6";

ok(encode_pictogram($raw), $html);
ok(decode_pictogram($html), $raw);
ok(length(remove_pictogram($raw)) == 6 * 2);

my $text = $raw;
my(@bin, @num);
my $num_found = find_pictogram($text, sub { push @bin, $_[0]; push @num, $_[1]; });

ok("@bin", "\xf8\x9f \xf8\xa0");
ok("@num", "63647 63648");
ok($num_found, 2);



