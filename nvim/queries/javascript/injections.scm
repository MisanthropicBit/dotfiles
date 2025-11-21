;; extends

(expression_statement
  (assignment_expression
    left: (subscript_expression
      object: (identifier) @object (#eq? @object "exports")
      index: (template_string)
    )
    right: (template_string
      (string_fragment) @value @injection.content @injection.include-children
    )
  )

  (#offset! @value 0 1 0 -1)
  (#set! injection.language "mysql")
)
