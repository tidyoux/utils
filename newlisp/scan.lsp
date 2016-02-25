;
; 递归地遍历指定目录，收集特定类型的文件。
;

(context 'scan)

(define (walk path type-list)
	(let ((type-list (if type-list type-list '(".")))
			(ret '())
			(lst (directory path {^[^.]})))
		(if lst
			(dolist (it lst)
				(if (directory (append path it "/"))
						(set 'ret (union (walk (append path it "/") type-list) ret))
					(find it type-list (fn (a x) (or (= x ".") (ends-with a x))))
						(set 'ret (cons (list it path) ret)))))
		ret))


