#!/usr/bin/env fish

function show_error -a message
    printf "\x1b[31mError\x1b[0m: $message\n"
end

function create_pr -d "Create a pull request from the command line"
    argparse --name="create_pr" "s/skip-ci" "r/reviewer=?" "n/no-view" -- $argv

    gh auth status > /dev/null

    if test $status -eq 1
        gh auth login
    end

    gh pr view > /dev/null

    if test $status -eq 0
        # PR already exists, open browser
        gh pr view --web
        return 0
    end

    set -f branch (git branch --show-current)

    if test "$branch" = "master"
        show_error "Cannot create PR on master branch"
        return 1
    end

    # Parse shortcut IDs from branch name
    set -f shortcut_ids (string match --regex --groups-only "sc-(\d+)" "$branch")

    if test "$shortcut_ids" = ""
        read -f --prompt-str "Shortcut ID (comma-separated list, leave empty for no IDs): " shortcut_ids
    end

    if test -n "$shortcut_ids"
        set -l ids (string split , "$shortcut_ids")
        set -l parsed_ids

        for id in $ids
            set -l trimmed_id (string trim "$id")

            if not string match --regex '\d+' "$trimmed_id"
                show_error "Invalid shortcut ID '$trimmed_id'"
                return 1
            end

            set -a parsed_ids "[sc-$trimmed_id]"
        end

        set -f pr_body (string join \n "$parsed_ids")

        if set -ql _flag_skip_ci
            set -f pr_body "$pr_body"\n"[skip-ci]"
        end
    end

    read -f --prompt-str "Additional body text: " extra_body

    if test -n "$extra_body"
        set -f pr_body "$pr_body"\n\n"$extra_body"
    end

    # Parse the part of the branch name denoting the story title
    set -f branch_tokens (string split "/" "$branch")
    set -f branch_name (string split "-" "$branch_tokens[-1]" | string join " ")
    set -f branch_name (string sub -l 1 "$branch_name" | string upper)(string sub -s 2 "$branch_name")

    read -f --prompt-str "Title will be '$branch_name'? (leave empty to accept): " accept_title

    if test -n "$accept_title"
        read -f --prompt-str "Title: " --command "$branch_name" branch_name
    end

    if set -ql _flag_reviewer
        set -f reviewer "$_flag_reviewer"

        if test -z "$reviewer" -a -n "$COMPANY_REVIEW_TEAM"
            set -f reviewer $COMPANY_REVIEW_TEAM
        end
    end

    # DEBUG
    # echo "$branch_name"
    # echo "$pr_body"
    # echo "sc-$shortcut_id"

    gh pr create\
        (test -n "$reviewer" && --reviewer "$reviewer")\
        --title "$branch_name"\
        --body "$pr_body"

    if test -z "$_flag_no_view"
        gh pr view --web
    end
end

create_pr "$argv"
