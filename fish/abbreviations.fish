function is_kubectl_command -a token
    set -f kubectl_alias_keys\
        "cc"\
        "shell"\
        "taints"

    set -f kubectl_alias_values\
        "config current-context"\
        "exec --stdin --tty % -- /bin/bash"\
        "get node % -o jsonpath='{.metadata.labels} {.spec.taints}' | jq"

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
