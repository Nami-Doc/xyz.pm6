use JSON::Tiny;

sub MAIN(:$file = 'META.info', *%args) {
    my %json = from-json slurp $file;
    %json<version> = '0.0.1' if %json<version>:!exists || %json<version> eq '*';
    say "Current version : %json<version>";
    my $next-version = increment(%json<version>, |%args);
    return if $next-version eq %json<version>;
    say "Press <enter> to bump to $next-version.";
    if $*IN.get eq "" {
	%json<version> = $next-version;
	spurt $file, to-json %json;
	say "Updated $file to $next-version.";
	qqx/git add '$file'/;
	qqx/git commit -m "Version $next-version"/;
	qqx/git tag --annotate '$next-version' --message "Version $next-version"/;
	qqx/git push origin 'refs/head/master' 'refs/tags/$next-version'/;
	# TODO something with cpan ?
    }
}

sub increment($version, :$major, :$minor, :$patch) {
    my @parts = $version.split('.');
    for ($major, $minor, $patch).kv -> $k, $v {
	@parts[$k]++ if $v;
    }
    @parts.join('.');
}
