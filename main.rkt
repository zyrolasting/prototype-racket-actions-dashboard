#lang racket/base

(require net/url
         racket/dict
         racket/file
         racket/format
         racket/function
         racket/list
         racket/runtime-path
         setup/getinfo
         web-server/web-server
         web-server/http
         web-server/dispatchers/dispatch
         [prefix-in lifter: web-server/dispatchers/dispatch-lift]
         [prefix-in sequencer: web-server/dispatchers/dispatch-sequencer])

(define-runtime-path here ".")

(define (show-build-record records req)
  (let* ([path/params (url-path (request-uri req))]
         [id (and (> (length path/params) 0)
                  (string->number (path/param-path (first path/params))))])
    (response/xexpr
     `(html (head (title ,(format "Record: ~a" id)))
            (body (pre ,(if (dict-has-key? records id)
                            (~e (dict-ref records id))
                            (format "Record ~a not found" id))))))))

(module+ main
  (require racket/cmdline)

  (define port (box 8080))
  (command-line
    #:program "racket-ci-dashboard"
    #:once-each
    [("-p" "--port")
     user-port
     "Port on which to listen for connections"
     (let ([parsed (string->number user-port)])
           (if (exact-positive-integer? parsed)
               (set-box! port parsed)
               (begin
                 (printf "The port doesn't look right: ~v~n" parsed)
                 (exit 1))))]
    #:args () (void))

  (define records (file->value (build-path here
                                           "records.rkt-list")))

  (define show-build-record/loaded
    (curry show-build-record records))

  (writeln records)

  (define stop (serve #:dispatch (lifter:make show-build-record/loaded)
                      #:port (unbox port)))

  (printf "CI Dashboard v~a listening on http://[::1]:~a~n"
          ((get-info/full here) 'version)
          (unbox port))

  (with-handlers ([exn:break? (λ _
                                (displayln "User break: Shutting down")
                                (stop))])
    (sync/enable-break never-evt)))
