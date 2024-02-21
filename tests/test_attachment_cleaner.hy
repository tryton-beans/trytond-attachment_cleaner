(import
  trytond.tests.test_tryton [ModuleTestCase with-transaction]
  trytond.modules.hyton.sugar [pool-search pool-create])

(defn list-purgatory [] (pool-search "attachment.purgatory" []))

(defn create-attachment []
  (pool-create "ir.attachment"
               :name "test"
               :data (.encode "test")
               :description "descripcio"
               :resource (pool-create "res.group"
                                     :name "test-group")))

(defn delete-attachment [attachment]
  (.delete attachment [attachment]))

(defclass AttachmentCleanerTestCase [ModuleTestCase]
  "Test Module"
  (setv module "attachment_cleaner")

  (defn [(with-transaction)] test-test [self]
    (.assertEqual self 0 (len (list-purgatory)))
    (delete-attachment (create-attachment))
    (.assertEqual self 1 (len (list-purgatory)))
    (let [[a-purgatory] (list-purgatory)]
      (.assertEqual self "test" a-purgatory.name)
      (.assertEqual self "descripcio" a-purgatory.description)
      ;; md5 data
      (.assertEqual self "098f6bcd4621d373cade4e832627b4f6" a-purgatory.file-id)
      )))
