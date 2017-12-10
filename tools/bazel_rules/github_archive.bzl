def github_archive(name, github_user, github_name, commit):
    '''
    name: The name of this Bazel target.
    github_user: The github username owning this repository.
    github_name: The name of this repository on github.
    commit: A commit hash or a tag to pull.
    '''
    url = 'https://github.com/%s/%s/archive/%s.tar.gz' % \
            (github_user, github_name, commit)
    native.http_archive(
        name = name,
        strip_prefix = '%s-%s' % (github_name, commit),
        url = url,
    )
