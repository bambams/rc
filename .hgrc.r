[alias]
all-releases = !hg branches --closed | grep -i release | sed -r "s/\s+[0-9]+:[0-9a-z]{12}(\s+.*|$)//" | sort
ancestor-db-changesets = log -r "reverse(::p1() and file('DbScripts/*'))"
deploy-settings = unshelve -k publish
feature-branch = !hg named-branches | grep "\\b$1\\b"
feature-branch-closed = !hg named-branches --closed | grep "\\b$1\\b"
in-releases = !hg in-branches "$1" | grep -i release
integrate = !if defined CC_RELEASE (for /f "tokens=*" %f in ('call cc-release-value.cmd') do @hg integrate-begin && hg commit-branch "Release %f" "$1" && hg integrate-done) else (echo CC_RELEASE is undefined. 1>&2)
integrate-abort = !hg integrate-done && hg commit-branch-abort
integrate-begin = !hg integrating true
integrate-close = !if defined CC_RELEASE (for /f "tokens=*" %f in ('hg close-path') do @for /f "tokens=*" %g in ('hg branch') do @for /f "tokens=*" %h in ('call cc-release-value.cmd --long') do @echo ^(Empty commit^) Closing branch %g>"%f"&&echo.>>"%f"&&echo Integrated into release candidate for v%h.>>"%f"&&hg commit --close-branch -el "%f" -X*) else (echo integrate-close: CC_RELEASE is not defined. 1>&2 && exit /b 1)
integrate-continue = !hg commit-branch-continue && hg integrate-done
integrate-done = !hg rm-property integrating
integrating = !hg property integrating "$@"
last-db-changeset = log -r "limit(reverse(::p1() and file('DbScripts/*')))"
releases = !hg branches | grep -i release | sed -r "s/\s+[0-9]+:[0-9a-z]{12}(\s+.*|$)//" | grep -E "[0-9]+\.[0-9]+\.[0-9]+$" | sort
task-branch = !hg named-branches | grep "\\bD\\?$1\\b"
task-branch-closed = !hg named-branches --closed | grep "\\bD\\?$1\\b"
updatereleases = !perl -E "open my $fh, '-|', 'hg releases' or die qq/open pipe: $!/; chomp(my @releases = <$fh>); close $fh or warn qq/close pipe: $!/; for my $release (@releases) { my $version = (split ' ', $release)[-1]; print qq/$version ($release)\n/; system(qq/hg tag --force --local --rev \x{22}$release\x{22} \x{22}${version}-tip\x{22} | cat/); my ($status, $signal) = ($? << 8, $? & 127); if($signal) { kill $signal, $$; } if($status) { exit($status); } }"

[revsetalias]
selectallp2p = branch('2.8.0-2021-1988.9,10-ParentApplyScreens'):: or branch('AutomatedTesting-RouteParameters'):: or branch('Release 2.8.2')::
selectallp2pformap = branch('2.8.0-1988-Issues5-SuppressSchoolLocationsForAnonymousUsers'):: or branch('2.8.0-2021-1988.9,10-ParentApplyScreens'):: or branch('AutomatedTesting-RouteParameters'):: or branch('FixMapOverlapProviders'):: or branch('Release 2.8.1'):: or branch('Release 2.8.2')
