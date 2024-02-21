(import trytond.pool [PoolMeta Pool]
        trytond.model [ModelSQL ModelView fields]
        trytond.modules.hyton.sugar [pool-new]
        trytond.ir.attachment [store_prefix]
        )
(require 
  trytond.modules.hyton.sugar [default      
                                      default-value])

(defclass AttachmentPurgatory [ModelView ModelSQL]
  "Attachment Purgatory. You when to hell get ready to be purged."
  (setv __name__ "attachment.purgatory"
        binary-prefix (.Char fields "Prefix")
        file-id (.Char fields "File Id")
        name (.Char fields "Filename")
        description (.Char fields "Description")
        type (.Char fields "Type")
        state (.Selection fields 
                          [#("pending" "Pending")
                           #("hold" "Hold")
                           #("done" "Done")]                          
                          "State"))
  (default-value state "pending")

  (defn [classmethod] purge [cls]
    (let [attachments-purgatory (pool-search "attachment.purgatory" [#("state", "=", "pending")])]
      (for [a-purgatory
            attachments-purgatory]
        (.delete filestore a-purgatory.file-id store-prefix)
        (setv a-purgatory.state "done")
        ))))

(defclass Attachment [:metaclass PoolMeta]
  (setv __name__ "ir.attachment")

  (defn [classmethod] delete [cls records]
    (.save (.get(Pool) "attachment.purgatory")
           (lfor attachment records
                 (pool-new "attachment.purgatory"
                           ;;:binary-prefix attachment.data.prefix
                           :file-id attachment.file-id
                           :name attachment.name
                           :type attachment.type
                           :description attachment.description
                           )))
    (.delete (super) records)))
