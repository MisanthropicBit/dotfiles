#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""View git repositories and more via the command line.

Open your .gitconfig file and add the following line to the [alias] section:

    browse = !<my_path>/git-browse.py

"""


import argparse
import posixpath
import re
import subprocess
import sys
from typing import Dict, List, Tuple
from urllib.parse import urlencode, urlparse, urlunparse
import webbrowser


__author__ = 'Alexander Asp Bock'
__version__ = '0.1.0'
__license__ = 'MIT'


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


def parse_object(arg: str, args: argparse.Namespace) -> Tuple[Tuple[str, ...], Dict]:
    """Parse a git object given on the command line.

    Return a list of paths and a dict of query parameters.

    """
    int_re = r'^\d+$'

    if args.command == 'pr':
        if re.match(int_re, arg):
            return ('pull', arg), {}
        else:
            return ('pulls', ), {
                    'utf8': '✓',
                    'q':    'is:pr is:open ' + arg
                }
    elif args.command == 'issue':
        if re.match(int_re, arg):
            return ('issues', arg), {}
        else:
            return ('issues', ), {
                    'utf8': '✓',
                    'q':    'is:issue is:open ' + arg
                }

    match = re.match(r'v?(\d+(\.\d+)+)', arg)

    if match:
        return ('tree', get_release_hash(match.group(1))), {}

    match = re.match(r'[a-fA-F0-9]{6,}', arg)

    if match:
        return ('tree', arg), {}

    return ('blob', args.branch, arg), {}



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

    subparsers = parser.add_subparsers(
        title='Commands',
        description='',
        dest='command'
    )

    issue_parser = subparsers.add_parser(
        'issue',
        help='Open an issue by id. If a non-number is given, search '
             'for it in open issues.'
    )
    pr_parser = subparsers.add_parser(
        'pr',
        help='Open a pull request by id. If a non-number is given, search '
             'for it in open pull requests'
    )

    return parser.parse_known_args()


def main() -> None:
    """Main function."""
    args, rest = parse_args()
    url = get_repository_url()

    if rest:
        if len(rest) > 1:
            sys.stderr.write('Ignoring extra {} arguments ({})\n'
                .format(len(rest) - 1, ', '.join(rest[1:])))

        paths, params = parse_object(rest[0], args)
        url = construct_url(url, paths, params)

    if args.dry_run:
        print(url)
    else:
        webbrowser.open(url)


if __name__ == '__main__':
    main()
