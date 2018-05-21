def github_archive(name, username, reponame, commit):
    '''
    Add a github repository as dependency of this workspace.

    The http url schema has been tested to work with github and gitbucket.

    - Why not use the plain native.git_repository() rule?
        Because it has several severe issues that are unlikely to be resolved:
            https://docs.bazel.build/versions/master/be/workspace.html#git_repository

    - Why not use tags or release branches instead of commit hashes?
        Open source projects on github are not stable.  Even release tags and
        branches are broken from time to time.  Using a commit hash guarantees
        that our build is fully reproducible every time.  Another reason is that
        there is no use cases for tags and branches just yet.  When such use
        cases arise, we may reconsider the interface.

    - Why the word 'github' in the name?
        Because this rule only applies to github repositories.  I am going to
        argue that this is both sufficient and necessary.  This is sufficient
        because a) almost all open source projects we care about are hosted on
        github, and b) for those that are not hosted on github, it is usually
        very easy to create a mirror/fork on github.  This is necessary because
        github provides tarball archives for all commits in repositories, making
        it possible to utilize the safe and fast native.http_archive() rule.


    Args:
        name: The name of the repository as seen by this workspace.  Other rules
            can reference targets of this repository using
            @<name>//path/to:target.
        username: The name of the github user holding this repository.
        reponame: The name of the github repository.
        commit: The full git commit hash or the tag to pull.
    '''
    url_format = 'https://github.com/%s/%s/archive/%s.tar.gz'
    # CAVEAT: The @commit parameter may be an actual commit hash or a tag.  If
    # it is a tag and the tag name starts with the letter 'v', e.g., v0.4.0, the
    # tar.gz file expands to a directory name without the leading letter 'v'.  I
    # think this is probably a bug on github.  But for the moment let's make it
    # work using the following workaround.
    tag = commit[1:] if commit.startswith('v') else commit
    native.http_archive(
        name = name,
        strip_prefix = '%s-%s' % (reponame, tag),
        url = url_format % (username, reponame, commit),
    )
