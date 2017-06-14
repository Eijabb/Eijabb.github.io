#!perl -Tw

use strict;

use Test::More tests=>6;

BEGIN {
    use_ok( 'MARC::Record' );
    use_ok( 'MARC::Batch' );
    use_ok( 'MARC::Global_Replace' );
}

diag( "Testing MARC::Global_Replace $MARC::Global_Replace::VERSION" );
