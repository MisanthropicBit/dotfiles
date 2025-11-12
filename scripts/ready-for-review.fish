#!/usr/bin/env fish

function set_as_ready -d "Mark current PR as ready for review"
    gh pr edit --add-reviewer "$COMPANY_REVIEW_TEAM"
end

set_as_ready
