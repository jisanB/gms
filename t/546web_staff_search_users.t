use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'staff';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'staff',
        password => 'staffer01'
    }
);

$ua->content_contains("You are now logged in as staff", "Check we can log in");

$ua->get_ok("http://localhost/staff", "Staff page works");

$ua->get_ok("http://localhost/staff/search_users", "Search users page works");

$ua->submit_form(
    fields => {
        accountname => 'test24',
    }
);

$ua->content_contains("Name 24", "Search works");

$ua->submit_form(
    fields => {
        fullname => 'Name 24',
    }
);

$ua->content_contains("test24", "Search works");

$ua->get_ok("http://localhost/staff/search_users", "Search users page works");

$ua->submit_form(
    fields => {
        fullname => 'Does not exist',
    }
);

$ua->content_contains("Unable to find any users that match your search criteria. Please try again.", "Error is shown when there are no search results");

$ua->get_ok("http://localhost/staff/search_users", "Search users page works");

$ua->submit_form(
    fields => {
        accountname => '%',
        name => '%'
    }
);

$ua->content_contains("Tester 1", "Searching works");

$ua->content_contains("Next page", "We can go to next page");
$ua->content_lacks("Previous page", "We can't go to previous page");
$ua->content_contains("name='last_page' value='3'", "There are 3 pages");
$ua->content_contains("name='current_page' value='1'", "We're at first page");

$ua->submit_form(
    fields => {
        'next' => 'Invalid option'
    }
);

$ua->content_contains("name='current_page' value='1'", "Invalid paging request is ignored");

$ua->click_button(
    value => 'Next page'
);

$ua->content_contains("Name 16", "paging works");

$ua->content_contains("Next page", "We can go to next page");
$ua->content_contains("Previous page", "We can go to previous page");
$ua->content_contains("name='current_page' value='2'", "We're at 2nd page");

$ua->click_button(
    value => 'Previous page'
);

$ua->content_contains("Tester 1", "Paging works");
$ua->content_contains("name='current_page' value='1'", "We're at first page");

$ua->click_button(
    value => 'Last page'
);

$ua->content_contains("Name 28", "Paging works");

$ua->content_lacks("Next page", "We can't go to next page");
$ua->content_contains("Previous page", "We can go to previous page");
$ua->content_contains("name='current_page' value='3'", "We're at third page");

$ua->click_button(
    value => 'First page'
);

$ua->content_contains("Tester 1", "Paging works");
$ua->content_contains("name='current_page' value='1'", "We're at first page");

$ua->select ('page', 2 );
$ua->click_button(
    value => 'Go'
);

$ua->content_contains("Name 16", "paging works");
$ua->content_contains("name='current_page' value='2'", "We're at 2nd page");

done_testing;