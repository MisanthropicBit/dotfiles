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
    (string (string_fragment) @injection.content @injection.include-children)
    (string)
  )

  (#set! injection.language "mysql")
)
