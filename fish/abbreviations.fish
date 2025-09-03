function is_kubectl_command -a token
    set -f kubectl_alias_keys\
        "cc"\
        "shell"\
        "taints"\
        "podevents"\
        "des"\
        "gp"

    set -f kubectl_alias_values\
        "config current-context"\
        "exec --stdin --tty % -- /bin/bash"\
        "get node % -o jsonpath='{.metadata.labels} {.spec.taints}' | jq"\
        "events --for=pod/%"\
        "describe"\
        "get pods"

    set -l is_kubectl_cmd (string match --regex "^(kc|kubectl)" (commandline --current-buffer))

    if test -n "$is_kubectl_cmd" 
        if set -l index (contains --index -- "$token" $kubectl_alias_keys)
            echo $kubectl_alias_values[$index]
        else
            echo $token
        end
    else
        echo $token
    end
end

abbr --add cc --position anywhere --function is_kubectl_command
abbr --add shell --position anywhere --function is_kubectl_command --set-cursor="%"
abbr --add taints --position anywhere --function is_kubectl_command --set-cursor="%"
abbr --add podevents --position anywhere --function is_kubectl_command --set-cursor="%"
abbr --add des --position anywhere --function is_kubectl_command
abbr --add gp --position anywhere --function is_kubectl_command

function is_tofu_command -a token
    set -f tofu_alias_keys\
        "ws"\
        "list"\
        "show"

    set -f tofu_alias_values\
        "workspace"\
        "workspace list"\
        "workspace show"

    set -l is_tofu_cmd (string match --regex "^tofu" (commandline --current-buffer))

    if test -n "$is_tofu_cmd" 
        if set -l index (contains --index -- "$token" $tofu_alias_keys)
            echo $tofu_alias_values[$index]
        else
            echo $token
        end
    else
        echo $token
    end
end

abbr --add ws --position anywhere --function is_tofu_command
abbr --add list --position anywhere --function is_tofu_command
abbr --add show --position anywhere --function is_tofu_command
