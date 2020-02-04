#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Requires Python 3.6+.
#
# Changelog:
#     0.3.0:
#       * Replaced argparse with docopt as the former just was not cutting it.
#       * Implemented path, wiki and tag commands.
#       * Refactored code and fixed TODOs.
#       * Implemented API classes for Github, Gitlab and Bitbucket.
#       * Added new commands.
#       * Better error checking.
#
#     0.2.0:
#       * Added the 'website' command to open the repository's website.
#       * Refactored code.
#
#     0.1.0:
#       * Initial version.

# NOTE: git browse help api for api-specific help/support?

"""usage: git-browse [-h | --help] [-v | --version] [-n | --dry-run]
                  [-d | --debug] [--pat=PAT]
                  [<command> [<cmd_args>...]]

View git repositories, files, directories commits, tags, issues, pull requests,
website, wiki and git objects via the command line. If no command or git object
is given, open the repository frontpage.

Instead of a command, you can provide any valid, browsable git object such as a
sha1 commit object or a reference and open the repository at that point in
time.

    $ git browse a2c19f
    $ git browse HEAD
    $ git browse HEAD~3

Note that the behaviour may change slightly based on which API is used (Github,
Gitlab, etc.).

Options:
    -h, --help              Show this message and ext.
    -v, --version           Show the current version of git-browse.
    -n, --dry-run           Show the url that would be opened but do not
                            actually open the website.
    -d, --debug             Output debug information.
"""

from docopt import docopt
import collections
import json
import posixpath
import os
import re
import subprocess
import sys
import textwrap
from typing import Dict, List, Optional, Union
from urllib.error import URLError
from urllib.request import Request, urlopen
from urllib.parse import quote_plus, urlencode, urlparse, urlunparse
import webbrowser

__author__ = 'Alexander Asp Bock'
__version__ = '0.3.0'
__license__ = 'MIT'

# -p, --pat PAT           Personal Access Token for access to private
#                         repositories. Default is to read from the
#                         environment variable GIT_BROWSE_PAT.
# -u, --username USERNAME
#                 The username used for authentication with a Personal Access
#                 Token (PAT). Default is to read from the environment
#                 variable GIT_BROWSE_USERNAME.

# NOTE: Per API command docs?
command_docs = """
Commands:
    apis        List all supported APIs.
    commands    List all available commands.
    help        Show help for a specific command.
    issue       Open an issue by number. If text is given, use it as a search
                string.
    milestone   Open the milestones of the repository.
    path        Open a specific file or directory.
    pr          Open a pull request by number. If text is given, use it as a
                search string.
    stats       Print a bunch of statistics for the repository.
    tag         Open a tag.
    website     Open the website associated with the repository, if any.
    wiki        Open the wiki page of the repository.

See 'git browse help <command>' for more information on a specific command.

"""

help_help = """usage: help <command>

Show help for a specific command.

"""

apis_help = """usage: apis

List all supported APIs.

"""

commands_help = """usage: commands

List all available commands.

"""

issue_help = """usage: issue [-a AUTHOR | --author=AUTHOR]
             [-s ASSIGNEE | --assignee=ASSIGNEE] [-c | --closed]
             [-l | --label=LABEL]... [<which>]

Browse an issue. The argument 'which' can be a number, optionally prefixed by a
hash (e.g. #1). If not, the argument is used as a search string.

Options:
    -a, --author=AUTHOR         Search for issues by a specific author.
    -s, --assignee=ASSIGNEE     Search for issues assigned to a specific
                                assignee.
    -c, --closed                Browse a closed issue. By default browses open
                                issues.
    -l LABEL, --label=LABEL     Search for issues tagged with one or more
                                labels.

"""

milestone_help = """usage: milestone [-c | --closed]

Browse milestones.

Options:
    -c, --closed        Browse closed milestones only.

"""

path_help = """usage: path [-b BRANCH | --branch=BRANCH]
           [-c COMMIT | --commit=COMMIT] <path>

Browse a file or directory.

Options:
    -b, --branch BRANCH     Select which branch browsing applies to. If not
                            given, default to the current branch.
    -c, --commit COMMIT     Open the file or directory at a specific commit or
                            git reference (e.g. HEAD or HEAD~3).

"""

pr_help = """usage: pr [-c | --closed | -m | --merged] [<which>]

Browse open pull requests. The argument 'which' can be a number, optionally
prefixed by a hash (e.g. #1). If not, the argument is used as a search string.

Options:
    -c, --closed    Browse only closed pull requests.
    -m, --merged    Browse only merged pull requests.
    <which>         Which pull request to browse, either an id (e.g. '1' or
                    '#2') or a search string.

"""

stats_help = """usage: stats

Print a bunch of repository statistics.

"""

tag_help = """usage: tag [-r | --release] [<which>]

Browse a tag. The argument 'which' is the tag to open (e.g. 'v0.1.4'). If the
release flag is given, assume the tag is marked as a release and open the
release instead.

Options:
    -r, --release   Browse a tag that has been marked as a release.
   <which>         Which tag to browse, e.g. 'v1.0.0' or 'my-favorite-tag'.

"""

website_help = """usage: website

Browse the website of the repository if any. Uses the Github API to retrieve
the homepage.

"""

wiki_help = """usage: wiki

Open the wiki page of the repository.

"""

command_help = {
    'help':      help_help,
    'apis':      apis_help,
    'commands':  commands_help,
    'issue':     issue_help,
    'milestone': milestone_help,
    'path':      path_help,
    'pr':        pr_help,
    'stats':     stats_help,
    'tag':       tag_help,
    'website':   website_help,
    'wiki':      wiki_help,
}

# Handy named tuple for parts of a url that is to be assembled and opened
UrlParts = collections.namedtuple('UrlParts',
                                  ['base', 'paths', 'params'],
                                  defaults=['', (), ()])


class APIError(Exception):
    """Raised when an API encounters an error."""


class API:
    """API base class for getting url endpoints based on the command line."""

    _ID_RE = r'^#?(\d+)$'

    def __init__(self, repo_url, pat):
        self._repo_url = repo_url
        self._pat = pat

    def _get_by_id_or_search(self, value: str, by_id_method,
                             search_method, **kwargs) -> UrlParts:
        """Get an issue or pull request by id or search all of them.

        If value is '#2' or an integer, assume it is an id, otherwise assume it
        is a string to search for.

        """
        match = re.match(self._ID_RE, value or '')

        if match:
            return by_id_method(match.group(1), **kwargs)
        else:
            return search_method(value, **kwargs)

    @property
    def name(self) -> str:
        """Return the name of the API."""
        raise NotImplementedError()

    @property
    def api(self) -> str:
        """Return the API url endpoint."""
        raise NotImplementedError()

    @property
    def repo_url(self) -> str:
        """Return the repository's url."""
        return self._repo_url

    @property
    def pat(self) -> str:
        """Return the Personal Access Token for this session."""
        return self._pat

    @classmethod
    def print_aligned_columns(cls, api, keys, result):
        """Print two columns that are left- and right aligned."""
        left_width = max(len(key) for key in keys)
        right_width = min(max(len(str(result.get(key, ''))) for key in keys
                              if key != 'description'), 50)

        if 'description' in result:
            wrapped_description = os.linesep.join(
                textwrap.wrap(result['description'],
                width=left_width + right_width + 4)
            )

            print('Description:{0}{1}'.format(os.linesep, wrapped_description))
            print()

        print('{0:<{1}}    {2:>{3}}'.format('API', left_width, api,
                                            right_width))

        for key in keys:
            if key == 'description':
                continue

            name = key.title().replace('_', ' ')
            value = result.get(key, 'N/A') or 'N/A'

            print('{0:<{1}}    {2:>{3}}'
                .format(name, left_width, value, right_width))

    def get_user_repo_names(self) -> List[str]:
        """Return the name of the repository's user and its name."""
        info, _ = posixpath.splitext(urlparse(self.repo_url).path)

        return info.strip('/').split('/')

    def add_authorization_token(self, request):
        """Add an authorization token to the header of a request."""
        raise NotImplementedError()

    def get_json(self, url_parts: UrlParts) -> Dict[str, Union[str, list]]:
        """Request and return json data from a url."""
        url = construct_url(url_parts)
        request = Request(url)
        self.add_authorization_token(request)

        try:
            return json.loads(urlopen(request).read())
        except URLError as ex:
            raise APIError(f"Failed to get json from '{url}' ({ex})")
        except json.JSONDecodeError as ex:
            raise APIError(f"Failed to decode json from '{url}' ({ex})")

    def api_url_parts(self, *paths, params={}) -> UrlParts:
        """Return an API url from multiple paths."""
        return UrlParts(self.api, paths, params)

    def _make_url_parameters(self, parameters, query, values, raw_queries=[]):
        """Create a dictionary of url parameters."""
        params = []

        for key, param_key, param_value in parameters:
            value = values[key]

            if value:
                if type(value) is list:
                    for elem in value:
                        params.append((param_key, elem))
                else:
                    param_value = param_value if param_value else value
                    params.append((param_key, param_value))

        filters = []

        for key, fmt in query:
            value = values[key]

            if value:
                if type(value) is list:
                    filters.extend([fmt.format(v) for v in value])
                else:
                    filters.append(fmt.format(value))

        filters.extend([q for q in raw_queries if q])

        if filters:
            params.append(('q', ' '.join(filters)))

        return params

    def issue(self, issue_id: str, **kwargs) -> UrlParts:
        """Return the url parts for an issue id."""
        return self._get_by_id_or_search(issue_id, self.issue_by_id,
                                         self.search_issues, **kwargs)

    def issue_by_id(self, issue_id: str, **kwargs) -> UrlParts:
        """Return the url parts for an issue given by its id."""
        raise NotImplementedError()

    def search_issues(self, search_string: str, **kwargs) -> UrlParts:
        """Return the url parts browsing issues."""
        raise NotImplementedError()

    def pr_by_id(self, pr_id: str, **kwargs) -> UrlParts:
        """Return the url parts for a pull request given by its id."""
        raise NotImplementedError()

    def search_prs(self, search_string: str, **kwargs) -> UrlParts:
        """Return the url parts browsing pull requests."""
        raise NotImplementedError()

    def milestone(self, **kwargs) -> UrlParts:
        """Return the url parts for the milestone page."""
        raise NotImplementedError()

    def pull_request(self, pr_id: str, **kwargs) -> UrlParts:
        """Return the url parts for a pull request id."""
        return self._get_by_id_or_search(pr_id, self.pr_by_id,
                                         self.search_prs, **kwargs)

    def website(self) -> Optional[UrlParts]:
        """Return the url parts for the repository's website."""
        raise NotImplementedError()

    def wiki(self) -> UrlParts:
        """Return the url parts for the repository's wiki."""
        raise NotImplementedError()

    def reference(self, ref) -> UrlParts:
        """Return the url parts for a specific commit."""
        raise NotImplementedError()

    def stats(self) -> None:
        """Print a list of statistics for the repository."""
        raise NotImplementedError()


class GitHubAPI(API):
    """Github API class."""

    @property
    def name(self) -> str:
        """Return the name of the API."""
        return 'Github'

    @property
    def api(self) -> str:
        return 'https://api.github.com/'

    def _make_url_parameters(self, parameters, query, values, raw_queries=[]):
        url_params = super()._make_url_parameters(parameters, query,
                                                  values, raw_queries)

        if 'q' in url_params:
            if not values['closed']:
                url_params.append(('q', 'is:open'))

        url_params.append(('utf8', '✓'))

        return url_params

    def add_authorization_token(self, request):
        """Add an authorization token to the header of a request."""
        request.add_header('Authorization', f'token {self.pat}')

    def issue_by_id(self, issue_id: str, **kwargs) -> UrlParts:
        return UrlParts(self.repo_url, ['issues', issue_id], url_params)

    def search_issues(self, search_string: str, **kwargs) -> UrlParts:
        url_params = self._make_url_parameters(
            [],
            [
                ('author',   'author:{0}'),
                ('assignee', 'assignee:{0}'),
                ('closed',   'is:closed'),
                ('label',    'label:{0}'),
            ],
            kwargs,
            raw_queries=[search_string]
        )

        return UrlParts(self.repo_url, ['issues'], url_params)

    def milestone(self, **kwargs) -> UrlParts:
        url_params = self._make_url_parameters(
            [], [('closed',  'is:closed')], kwargs
        )

        return UrlParts(self.repo_url, ['milestones'], url_params)

    def pr_by_id(self, pr_id: str, **kwargs) -> UrlParts:
        url_params = self._make_url_parameters(
            [],
            [('closed', 'is:closed'), ('merged', 'is:merged')],
            kwargs,
            raw_queries=['is:pr']
        )

        return UrlParts(self.repo_url, ['pull', pr_id], url_params)

    def search_prs(self, search_string: str, **kwargs) -> UrlParts:
        url_params = self._make_url_parameters(
            [], [('closed', 'is:closed'), ('merged', 'is:merged')], kwargs,
            raw_queries=[search_string]
        )

        return UrlParts(self.repo_url, ['pulls'], url_params)

    def path(self, which: str, **kwargs) -> Optional[UrlParts]:
        paths = ['blob']
        commit = kwargs['commit']

        if commit:
            paths.append(resolve_commit(commit))
        else:
            paths.append(kwargs['branch'])

        paths.append(which)

        return UrlParts(self.repo_url, paths)

    def tag(self, which: str, **kwargs) -> UrlParts:
        paths = []

        if which:
            paths.extend(['releases', 'tag'] if kwargs['release']
                         else ['tree'])
            paths.append(which)
        else:
            paths.append('releases' if kwargs['release'] else 'tags')

        return UrlParts(self.repo_url, paths)

    def website(self) -> Optional[UrlParts]:
        user, repo = self.get_user_repo_names()
        result = self.get_json(self.api_url_parts('repos', user, repo))

        if not result.get('homepage', ''):
            raise APIError('No website associated with repository')

        return UrlParts(result['homepage'])

    def wiki(self) -> UrlParts:
        return UrlParts(self.repo_url, ['wiki'])

    def reference(self, ref) -> UrlParts:
        return UrlParts(self.repo_url, ['tree', resolve_commit(ref)])

    def stats(self) -> None:
        keys = [
            'name',
            'id',
            'language',
            'created_at',
            'default_branch',
            'homepage',
            'forks',
            'open_issues',
            'watchers'
        ]

        user, repo = self.get_user_repo_names()
        result = self.get_json(self.api_url_parts('repos', user, repo))

        GitHubAPI.print_aligned_columns(self.name, keys, result)


class GitlabAPI(API):
    """Gitlab API class."""

    @property
    def name(self) -> str:
        """Return the name of the API."""
        return 'Gitlab'

    @property
    def api(self):
        return 'https://gitlab.com/api/v4/'

    def add_authorization_token(self, request):
        """Add an authorization token to the header of a request."""
        pass

    def issue_by_id(self, issue_id: str, **kwargs) -> UrlParts:
        return UrlParts(self.repo_url, ['issues', issue_id])

    def search_issues(self, search_string: str, **kwargs) -> UrlParts:
        kwargs.update(search=search_string)

        url_params = self._make_url_parameters(
            [
                ('author',   'author_username',     None),
                ('assignee', 'assignee_username[]', None),
                ('closed',   'state',               'closed'),
                ('label',    'label_name[]',        None),
                ('search',   'search',              search_string)
            ],
            [], kwargs
        )

        return UrlParts(self.repo_url, ['issues'], url_params)

    def milestone(self, **kwargs) -> UrlParts:
        url_params = self._make_url_parameters(
            [('closed', 'state', 'closed')], [], kwargs
        )

        return UrlParts(self.repo_url, ['-', 'milestones'], url_params)

    def pr_by_id(self, pr_id: str, **kwargs) -> UrlParts:
        return UrlParts(self.repo_url, ['merge_requests', pr_id])

    def search_prs(self, search_string: str, **kwargs) -> UrlParts:
        kwargs.update(search=search_string)

        url_params = self._make_url_parameters(
            [
                ('closed', 'state',  'closed'),
                ('merged', 'state',  'merged'),
                ('search', 'search', search_string)
            ],
            [], kwargs
        )

        return UrlParts(self.repo_url, ['merge_requests'], url_params)

    def path(self, which: str, **kwargs) -> Optional[UrlParts]:
        paths = ['blob' if os.path.isfile(which) else 'tree']

        if kwargs['commit']:
            paths.append(resolve_commit(kwargs['commit']))
        else:
            paths.append(kwargs['branch'])

        paths.append(which)

        return UrlParts(self.repo_url, paths)

    def tag(self, which: str, **kwargs) -> UrlParts:
        paths = []

        if which:
            # Ignore --release switch, just show the tag since you cannot view
            # individual releases on Gitlab
            paths.append(which)
        else:
            paths.extend(['-', 'releases' if kwargs['release'] else 'tags'])

        return UrlParts(self.repo_url, paths)

    def website(self) -> Optional[UrlParts]:
        raise APIError('The website command is not supported by the '
                       f'{self.name} API')

    def wiki(self) -> UrlParts:
        return UrlParts(self.repo_url, ['-', 'wikis', 'home'])

    def reference(self, ref) -> UrlParts:
        return UrlParts(self.repo_url, ['src', resolve_commit(ref)])

    def stats(self) -> None:
        keys = [
            'name',
            'description',
            'created_at',
            'default_branch',
            'star_count',
            'forks_count',
            'last_activity_at',
        ]

        user, repo = self.get_user_repo_names()
        encoded_path = quote_plus(f'{user}/{repo}')
        result = self.get_json(self.api_url_parts('projects', encoded_path))

        GitlabAPI.print_aligned_columns(self.name, keys, result)


class BitbucketAPI(API):
    """Bitbucket API class."""

    @property
    def name(self) -> str:
        """Return the name of the API."""
        return 'Bitbucket'

    @property
    def api(self):
        return 'https://api.bitbucket.org/2.0/'

    def add_authorization_token(self, request):
        """Add an authorization token to the header of a request."""
        pass

    def issue_by_id(self, issue_id: str, **kwargs) -> UrlParts:
        return UrlParts(self.repo_url, ['issues', issue_id])

    def search_issues(self, search_string: str, **kwargs) -> UrlParts:
        params = [
            ('closed', 'status', 'closed'),
            ('author', 'reported_by', None),
        ]

        raw_queries = []

        if kwargs['assignee'].lower() != 'unassigned':
            params.append(('assignee', 'responsible', None))
        else:
            # Handle Bitbucket support for unassigned issues
            raw_queries.append(('responsible', ''))

        url_params = self._make_url_parameters(
            params, [], kwargs, raw_queries=raw_queries
        )

        if 'closed' not in kwargs:
            url_params.append(('status', 'new'))
            url_params.append(('status', 'open'))

        return UrlParts(self.repo_url, ['issues'], url_params)

    def milestone(self, **kwargs) -> UrlParts:
        raise APIError(f'{self.name} does not have milestones')

    def pr_by_id(self, pr_id: str, **kwargs) -> UrlParts:
        return UrlParts(self.repo_url, ['pull-requests', pr_id])

    def search_prs(self, search_string: str, **kwargs) -> UrlParts:
        kwargs.update(query=search_string)

        url_params = self._make_url_parameters(
            [
                ('closed', 'state', 'declined'),
                ('merged', 'state', 'merged'),
                ('query',  'query', None),
            ], [], kwargs
        )

        if not kwargs['closed'] and not kwargs['merged']:
            url_params.append(('state', 'open'))

        return UrlParts(self.repo_url, ['pull-requests'], url_params)

    def path(self, which: str, **kwargs) -> Optional[UrlParts]:
        if kwargs['commit']:
            resolved_commit = resolve_commit(kwargs['commit'])
            return UrlParts(self.repo_url, ['src', resolved_commit, which])

        return UrlParts(self.repo_url, ['src', kwargs['branch'], which])

    def tag(self, which: str, **kwargs) -> UrlParts:
        if which:
            if kwargs['release']:
                # Cannot browse individual releases on Bitbucket
                return UrlParts(self.repo_url, ['downloads'])

            # Cannot browse individual tags on Bitbucket
            return UrlParts(self.repo_url, ['commits', resolve_commit(which)])
        else:
            url_params = ('tab', 'downloads' if kwargs['release'] else 'tags')
            return UrlParts(self.repo_url, ['downloads'], url_params)

    def website(self) -> Optional[UrlParts]:
        user, repo = self.get_user_repo_names()
        result = self.get_json(self.api_url_parts('repositories', user, repo))

        if not result.get('website', ''):
            raise APIError('No website associated with repository')

        return UrlParts(result['website'])

    def wiki(self) -> UrlParts:
        raise APIError(f'{self.name} does not have wikis')

    def reference(self, ref) -> UrlParts:
        return UrlParts(self.repo_url, ['src', resolve_commit(ref)])

    def stats(self) -> None:
        keys = [
            'name',
            'language',
            'created_on',
            'updated_on',
            'has_wiki',
            'has_issues',
            'website',
            'description',
            # 'mainbranch.default'
        ]

        user, repo = self.get_user_repo_names()
        result = self.get_json(self.api_url_parts('repositories', user, repo))

        BitbucketAPI.print_aligned_columns(self.name, keys, result)


_APIS = {
    'github':    GitHubAPI,
    'gitlab':    GitlabAPI,
    'bitbucket': BitbucketAPI,
}


def run_git_command(cmd: str) -> str:
    """Run a git command and return the result."""
    try:
        return subprocess.check_output(
            cmd,
            shell=True,
            stderr=subprocess.STDOUT
        ).strip().decode('utf-8')
    except subprocess.CalledProcessError as ex:
        error_msg = ex.stdout.decode('utf-8').strip()
        sys.exit(f'Error: Failed to run git command: {error_msg} ({ex})')


def get_repository_url() -> str:
    """Return the repository url."""
    url = run_git_command('git config --local remote.origin.url')

    if url.endswith('.git'):
        return url[:-4]

    return url


def get_api_name_from_url(url: str) -> str:
    """Get the API from a repository url."""
    return urlparse(url).netloc.split('.')[0]


def resolve_commit(commit):
    """Check and return that a commit is valid (e.g. a2c19f)."""
    return run_git_command(f'git rev-parse --verify {commit}')


def construct_url(url_parts: UrlParts) -> str:
    """Construct a url from url parts and return it."""
    base, paths, params = url_parts
    scheme, netloc, path, _, _, fragment = urlparse(base)
    query = urlencode(params)

    return urlunparse([
            scheme,
            netloc,
            posixpath.join(path, *paths),
            '',
            query,
            fragment
        ])


def args_as_dict(args, key_subset):
    """Convert docopt command line argument keys to dictionary-like keys.

    E.g. '--closed' -> 'closed'.

    """
    return {k.lstrip('--').replace('-', '_'): v
            for k, v in args.items() if k in key_subset}


def execute_command(api, args) -> Optional[UrlParts]:
    """Execute the browse action specified on the command line."""
    command = args['<command>']

    if command in command_help:
        command_args = docopt(command_help[command], argv=args['<cmd_args>'])

        if args['--debug']:
            print(f'command_args: {command_args}')

        if command == 'help':
            sys.stderr.write(command_help[args['<cmd_args>'][0]])
            sys.exit()
        elif command == 'apis':
            print('Supported APIs:')

            for api_key in _APIS:
                print(f'    * {api_key.title()}')

            sys.exit()
        elif command == 'commands':
            print(command_docs.strip(), end='')
            sys.exit()
        elif command == 'path':
            kwargs = args_as_dict(command_args, ['--commit', '--branch'])

            if not kwargs['branch']:
                kwargs['branch'] =\
                    run_git_command('git rev-parse --abbrev-ref HEAD')

            return api.path(command_args['<path>'], **kwargs)
        elif command == 'issue':
            kwargs = args_as_dict(command_args,
                                  ['--author', '--assignee', '--closed',
                                   '--label'])
            return api.issue(command_args['<which>'], **kwargs)
        elif command == 'milestone':
            kwargs = args_as_dict(command_args, ['--closed'])
            return api.milestone(**kwargs)
        elif command == 'pr':
            kwargs = args_as_dict(command_args, ['--closed', '--merged'])
            return api.pull_request(command_args['<which>'], **kwargs)
        elif command == 'stats':
            api.stats()
            sys.exit()
        elif command == 'tag':
            kwargs = args_as_dict(command_args, ['--release'])
            return api.tag(command_args['<which>'], **kwargs)
        elif command == 'website':
            return api.website()
        elif command == 'wiki':
            return api.wiki()
    else:
        if args['<command>']:
            return api.reference(args['<command>'])
        else:
            return UrlParts(api.repo_url)


def get_api() -> API:
    """Return the API class for the current remote."""
    repo_url = get_repository_url()

    if not repo_url:
        sys.exit('Failed to get repository url from local git config')

    api_name = get_api_name_from_url(repo_url)

    if api_name not in _APIS:
        sys.exit(f"Error: Unsupported API \'{api_name}\' (choose from: "
                 f"{', '.join(_APIS)})\n")

    # TODO: Good idea to get Personal Access Token from the command line (it is
    # in history) or from an environment variable?
    # pat = args['--pat'] or os.environ.get('GIT_BROWSE_PAT', None)

    return _APIS[api_name](repo_url, None)


def main() -> None:
    """Main function."""
    args = docopt(__doc__ + command_docs, help=True,
                  version=f'git-browse v{__version__}',
                  options_first=True)

    api = get_api()

    if args['--debug']:
        sys.stderr.write(f'API: {api.name}\n')
        sys.stderr.write(f'args: {args}\n')

    try:
        url_parts = execute_command(api, args)
    except APIError as ex:
        sys.exit(f'Error: {ex}')

    if args['--debug']:
        print(f'Url parts: {url_parts}')

    url = construct_url(url_parts)

    if args['--dry-run']:
        print(url)
    else:
        try:
            webbrowser.open(url)
        except webbrowser.Error as ex:
            sys.exit(f'Error: {ex}')


if __name__ == '__main__':
    main()
