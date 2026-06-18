;; extends

;; Injects mysql syntax highlighting in call expressions like:
;;
;; await db.query("insert into ...", 'instance')
(call_expression
  function: (member_expression
    object: (identifier) @obj (#eq? @obj "db")
    property: (property_identifier) @member (#eq? @member "query")
  )
  arguments: (arguments
    ((string) @injection.content (#set! injection.language "sql") (#set! injection.include-children) (#offset! @injection.content 0 1 0 -1))
    (string)
  )
)

; TODO: Combine the queries below

; Match async call expressions in a variable declarator (template string)
(call_expression
  function: (await_expression
    (member_expression
      object: (identifier)
      property: (property_identifier) @method (#eq? @method "query")
    ))
    arguments: (arguments
        ((template_string) @injection.content
         (#match? @injection.content "^.(select|insert|update|delete|truncate|SELECT|INSERT|UPDATE|DELETE|TRUNCATE)")
         (#set! injection.language "sql")
         (#set! injection.include-children)
         (#offset! @injection.content 0 1 0 -1)
        )
    )
)

; Match async call expressions in a variable declarator (string)
(call_expression
  function: (await_expression
    (member_expression
      object: (identifier)
      property: (property_identifier) @method (#eq? @method "query")
    ))
    arguments: (arguments
        ((string) @injection.content
         (#match? @injection.content "^.(select|insert|update|delete|truncate|SELECT|INSERT|UPDATE|DELETE|TRUNCATE)")
         (#set! injection.language "sql")
         (#set! injection.include-children)
         (#offset! @injection.content 0 1 0 -1)
        )
    )
)

; Match bare async call expressions (template string)
(call_expression
  function: (
    (member_expression
      object: (identifier)
      property: (property_identifier) @method (#eq? @method "query")
    ))
    arguments: (arguments
      ((template_string) @injection.content
        (#match? @injection.content "^.(select|insert|update|delete|truncate|SELECT|INSERT|UPDATE|DELETE|TRUNCATE)")
        (#set! injection.language "sql")
        (#set! injection.include-children)
        (#offset! @injection.content 0 1 0 -1)
      )
    )
)

; Match bare async call expressions (string)
(call_expression
  function: (
    (member_expression
      object: (identifier)
      property: (property_identifier) @method (#eq? @method "query")
    ))
    arguments: (arguments
      ((string) @injection.content
        (#match? @injection.content "^.(select|insert|update|delete|truncate|SELECT|INSERT|UPDATE|DELETE|TRUNCATE)")
        (#set! injection.language "sql")
        (#set! injection.include-children)
        (#offset! @injection.content 0 1 0 -1)
      )
    )
)
