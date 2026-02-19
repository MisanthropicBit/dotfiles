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
