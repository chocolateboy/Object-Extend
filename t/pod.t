use Test::More;
my $min_tp = '1.41'; # http://justatheory.com/computers/programming/perl/sane-pod-links.html
eval "use Test::Pod $min_tp";
plan skip_all => "Test::Pod $min_tp required for testing POD" if $@;
all_pod_files_ok();
