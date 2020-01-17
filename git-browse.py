#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""View git repositories and more via the command line.

Open your .gitconfig file and add the following line to the [alias] section:

    browse = !<my_path>/git-browse.py

Requires Python 3.6+.

Changelog:
    0.1.0:
        * Initial version

    0.2.0:
        * Added the 'website' command to open the repository's website
        * Refactored code

"""


import argparse
import json
import posixpath
import re
import subprocess
import sys
from typing import Dict, List, Tuple
from urllib.error import URLError
from urllib.request import urlopen
from urllib.parse import urlencode, urljoin, urlparse, urlunparse
import webbrowser


__author__ = 'Alexander Asp Bock'
__version__ = '0.2.0'
__license__ = 'MIT'

_API = 'https://api.github.com/'
_TAG_RE = r'v?(\d+(\.\d+)+)'
_SHA1_RE = r'[a-fA-F0-9]{6,}'
_NUMBER_RE = r'^\d+$'


def run_git_command(cmd: str) -> str:
    """Run a git command."""
    try:
        return subprocess.check_output(cmd, shell=True).strip().decode('utf-8')
    except subprocess.CalledProcessError as ex:
        sys.exit(str(ex))


def get_repository_url() -> str:
    """Return the repository url."""
    url = run_git_command('git config --local remote.origin.url')

    if url.endswith('.git'):
        return url[:-4]

    return url


def get_release_hash(release: str) -> str:
    """Return the sha256 hash for a release such as 0.3.0."""
    return run_git_command('git rev-parse ' + release + '^0')


def construct_api_url(paths, params={}):
    """Construct a url for the Github API v3."""
    return construct_url(_API, paths, params)


def construct_url(base, extra, params):
    """Properly construct a url from components and return it."""
    scheme, netloc, path, _, _, fragment = urlparse(base)
    query = urlencode(params)

    return urlunparse([
            scheme,
            netloc,
            posixpath.join(path, *extra),
            '',
            query,
            fragment
        ])


# TODO: Refactor this function
# TODO: Only get repo URL when necessary
# TODO: Uniform error handling
def parse_object(args: argparse.Namespace, extra_args: List[str],
                 repo_url: str) -> Tuple[str, Tuple[str, ...], Dict]:
    """Parse a git object given on the command line.

    Return a list of paths and a dict of query parameters.

    """
    int_re = r'^\d+$'

    if args.command == 'pr':
        if re.match(int_re, extra_args[0]):
            return repo_url, ('pull', extra_args[0]), {}
        else:
            return repo_url, ('pulls', ), {
                    'utf8': '✓',
                    'q':    'is:pr is:open ' + extra_args[0]
                }
    elif args.command == 'issue':
        if re.match(int_re, extra_args[0]):
            return repo_url, ('issues', extra_args[0]), {}
        else:
            return repo_url, ('issues', ), {
                    'utf8': '✓',
                    'q':    'is:issue is:open ' + extra_args[0]
                }
    elif args.command == 'website':
        info, _ = posixpath.splitext(urlparse(repo_url).path)

        try:
            url = construct_api_url(['repos', info.strip('/')])
            result = json.loads(urlopen(url).read())
        except URLError as ex:
            sys.stderr.write(f'Failed to get website ({ex})\n')
            return '', (), {}

        if 'homepage' not in result:
            sys.stderr.write('No homepage associated with repository\n')
            return '', (), {}

        return result['homepage'], (), {}

    match = re.match(_TAG_RE, extra_args[0])

    if match:
        return repo_url, ('tree', get_release_hash(match.group(1))), {}

    match = re.match(_SHA1_RE, extra_args[0])

    if match:
        return repo_url, ('tree', extra_args[0]), {}

    return repo_url, ('blob', args.branch, extra_args[0]), {}


class IgnoreUnknownCommand(argparse.Action):
    """."""

    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, values)


def parse_args() -> Tuple[argparse.Namespace, List[str]]:
    """Parse command line arguments."""
    description = 'View git repositories, files, directories commits and ' +\
                  'tags via the command line.'
    parser = argparse.ArgumentParser(description=description)

    parser.add_argument(
        '-n',
        '--dry-run',
        action='store_true',
        help='Do not open the url in the brower but print it to stdout.'
    )
    parser.add_argument(
        '-b', '--branch', type=str, default='master',
        help='Select which branch to view.'
    )
    parser.add_argument(
        '-v', '--version', action='version', version=__version__,
        help='Print the current version of git-browse.'
    )

    parser.add_argument('git object',
                        help='Any valid git object viewable on Github',
                        nargs='?')

    subparsers = parser.add_subparsers(
        title='Commands',
        description='',
        dest='command',
        required=False
    )

    issue_parser = subparsers.add_parser(
        'issue',
        help='Open an issue by id. If a non-number is given, search '
             'for it in open issues'
    )
    issue_parser.add_argument('-c', '--closed', action='store_true',
                              help='Show only closed issues')

    pr_parser = subparsers.add_parser(
        'pr',
        help='Open a pull request by id. If a non-number is given, search '
             'for it in open pull requests'
    )
    pr_parser.add_argument('-m', '--merged', action='store_true',
                           help='Show only merged pull requests')

    website_parser = subparsers.add_parser(
        'website',
        help='Attempt to open the website for the current repository'
    )
    tag_parser = subparsers.add_parser(
        'tag',
        help='Open the repository for the commit of a specific tag'
    )
    commit_parser = subparsers.add_parser(
        'commit',
        help='Open the repository for a SHA1 hash'
    )

    print(dir(subparsers))
    print(subparsers.required)

    return parser.parse_known_args()


def main() -> None:
    """Main function."""
    args, rest = parse_args()
    print(args, rest)
    url = get_repository_url()
    final_url = ''

    # actions = {
    #     'issue':   (construct_issue_url, ())
    #     'website', (construct_api_url,   ('repos', ))
    #     'pr',
    #     'tag',
    #     'commit',
    # }

    if rest or args.command:
        if len(rest) > 1:
            sys.stderr.write('Ignoring extra {} arguments ({})\n'
                .format(len(rest) - 1, ', '.join(rest[1:])))

        target_url, paths, params = parse_object(args, rest, url)
        print(target_url, paths, params)
        final_url = construct_url(target_url, paths, params)

    if args.dry_run:
        print(final_url)
    else:
        webbrowser.open(final_url)


if __name__ == '__main__':
    main()
