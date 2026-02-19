;; extends

(expression_statement
  (assignment_expression
    left: (subscript_expression
      object: (identifier) @object (#eq? @object "exports")
      index: (template_string)
    )
    right: (
        (template_string) @injection.content
            (#match? @injection.content "^`\"(select|insert|update|delete|truncate)")
            (#set! injection.language "sql")
            (#set! injection.include-children)
            (#offset! @injection.content 0 2 0 -2)
            (#gsub! @injection.content "\\`" "")
    )
  )
)
