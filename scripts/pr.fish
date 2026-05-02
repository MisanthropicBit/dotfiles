#!/usr/bin/env fish

function show_error -a message
    printf "\x1b[31mError\x1b[0m: $message\n"
end

function parse_branch_to_pr_title -d "Parse the part of the branch name denoting the story title" -a branch
    set -f branch_tokens (string split "/" "$branch")
    set -f branch_name (string split "-" "$branch_tokens[-1]" | string join " ")
    set -f branch_name (string sub -l 1 "$branch_name" | string upper)(string sub -s 2 "$branch_name")

    printf "$branch_name"
end

function parse_last_commit_message_to_pr_title
    # Command to extract the last commit message body that isn't a merge and isn't a version bump. Also strip PR numbers in parentheses
    set -f title (git log -1 -s --no-merges --format=%B --invert-grep --grep="\d\+\.\d\+\.\d\+" | string collect | string replace -r " \(#\d+\)\$" "")

    printf "$title"
end

function create_pr -d "Create a pull request from the command line"
    argparse --name="create_pr" "s/skip-sc" "r/reviewer=?" "v/view" -- $argv

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

        if set -ql _flag_skip_sc
            set -f pr_body "$pr_body"\n"[skip-sc]"
        end
    end

    read -f --prompt-str "Additional body text: " extra_body

    if test -n "$extra_body"
        set -f pr_body "$pr_body"\n\n"$extra_body"
    end

    set -f branch_pr_title (parse_branch_to_pr_title "$branch")
    set -f commit_pr_title (parse_last_commit_message_to_pr_title)

    printf "Select PR title: \n" 
    printf "  %sb%s: Use branch name ($branch_pr_title)\n" (set_color blue) (set_color normal)
    printf "  %sc%s: Use commit message ($commit_pr_title) [default]\n" (set_color blue) (set_color normal)
    printf "  %se%s: Edit title\n\n" (set_color blue) (set_color normal)

    read -f --prompt-str "> " pr_title

    if test -z "$pr_title"
        set -f pr_title "$commit_pr_title"
    else
        if test "$pr_title" = "c"
            set -f pr_title "$commit_pr_title"
        else if test "$pr_title" = "b"
            set -f pr_title "$branch_pr_title"
        else if test "$pr_title" = "e"
            read -f --prompt-str "Title: " --command "$commit_pr_title" pr_title
        else
            show_error "Invalid choice '$pr_title'"
            exit 1
        end
    end

    if set -ql _flag_reviewer
        set -f reviewer "$_flag_reviewer"

        if test -z "$reviewer" -a -n "$COMPANY_REVIEW_TEAM"
            set -f reviewer $COMPANY_REVIEW_TEAM
        end
    end

    # DEBUG
    # echo "$branch_pr_title"
    # echo "$pr_body"
    # echo "sc-$shortcut_id"

    gh pr create\
        (test -n "$reviewer" && --reviewer "$reviewer")\
        --title "$pr_title"\
        --body "$pr_body"\
        --base master

    if test -n "$_flag_view"
        gh pr view --web
    end
end

create_pr "$argv"
