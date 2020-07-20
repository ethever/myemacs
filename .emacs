; ---------------------------------------------------------------------------------------------------------
;; 系统设置
;; 保存桌面状态
(load "desktop")
(desktop-load-default)
(desktop-read)
(add-hook 'kill-emacs-hook
	  '(lambda()(desktop-save "~/.emacs.d/")))
;; 将备份文件放一起
(setq backup-directory-alist (quote (("." . "/root/.emacs-backups"))))
;; 关闭启动欢迎界面
(setq inhibit-startup-message t)
;; 显示时间
(display-time-mode 1)			;常显
;; 显示行号
(global-linum-mode 1)
;; how to display line number
(setq linum-format "%d")
;; 隐藏菜单栏, 工具栏, 滚动条
(tool-bar-mode 0)			
(menu-bar-mode 0)
;; (scroll-bar-mode 0)
;; 高亮当前行
(global-hl-line-mode 1)
;; 设置字体
;;(set-default-font "Monaco-14")
;; 修改窗口title
(setq frame-title-format "famouscat@%b")

(setq scroll-margin 3 scroll-conservatively 10000)
;;防止页面滚动时跳动， scroll-margin 3 可以在靠近屏幕边沿3行时就开始滚动，可以很好的看到上下文。
(setq mouse-avoidance-mode 'animate)
;;光标靠近鼠标指针时，让鼠标指针自动让开，别挡住视线。
(setq-default kill-whole-line t)
;; 在行首 C-k 时，同时删除该行。
;;(setq auto-image-file-mode t)
;;让 Emacs 可以直接打开和显示图片。
;(auto-compression-mode 1)
;打开压缩文件时自动解压缩。
(setq Man-notify-method 'pushy)
;; 当浏览 man page 时，直接跳转到 man buffer。
(setq track-eol t)
;; 当光标在行尾上下移动的时候，始终保持在行尾。

;; emacs 换源-- emacs 官方中国源
(setq package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
			  ("melpa" . "http://elpa.emacs-china.org/melpa/")))
(package-initialize)





;; -------------------------------------------------------------------------------------------------
;; 加载插件
;; c-mode 中函数, 符号定义查找工具
(add-to-list 'load-path' "~/.emacs.d/site-lisp")
(require 'xcscope)

;; 智能编辑插件
(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp"))
(require 'thing-edit)


;; 配置ecb
(add-to-list 'load-path "~/.emacs.d/site-lisp/ecb")
(require 'ecb)


;; Emcas开发环境工具集合
(require 'cedet)
(global-ede-mode t)

; --------------------------------------------------------------------------------------------
;; c-mode 配置
;; c-mode 自动启动插件
(add-hook 'c-mode-hook 'rainbow-delimiters-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'hs-minor-mode)
(add-hook 'c++-mode-hook 'hs-minor-mode)
;; (add-hook 'c-mode-hook 'whitespace-newline-mode)
(add-hook 'c-mode-hook 'electric-pair-mode) ;双括号模式

;; c-mode 下绑定折叠代码快捷键
(add-hook 'c-mode-hook '(lambda ()
			  (local-set-key (kbd "C-,") 'hs-hide-block)
			  (local-set-key (kbd "C-.") 'hs-show-block)))


;; 高亮括号里的内容
;; (setq show-paren-style 'expression)

;; 启动 semantic-mode
(semantic-mode 1)
;;当光标移动到某个函数调用的地方, 或者变量的使用地方时
;;函数的原型会显示在minibuf
(global-semantic-idle-summary-mode)
;; 启动代码补全功能
(global-semantic-idle-completions-mode)
;; 启用bookmark功能, 为了函数 semantic-mrub-switch-tags可以被使用
;; 进而实现当跳转到函数/变量定义后, 还能跳回来
(global-semantic-mru-bookmark-mode)
;; ctrl - 回车键绑定自动补全
(add-hook 'semantic-after-idle-scheduler-reparse-hooks
	  (lambda ()
	    (message "parse done :)")
	    (local-set-key (kdb "C-<return>")
			   'semantic-complete-analyze-inline-idle)))
;; 让speedbar使用由semantic解析出来的tags, semantic 解析出来的tags里的信息比speedbar自己的更详细
(add-hook 'speedbar-load-hook
	  (lambda () (require 'semantic/sb)))
;; 跳转到函数定义
(global-set-key [f12] 'semantic-ia-fast-jump)
;; 为了跳回去, 要使用函数semantic-mrub-switch-tags, 但是报出[semantic bookmark ring is currently empty ] 错误, 原因是函数
;; semantic-ia-fast-jump 调用了函数push-mark, 而函数push-mark里面没有push bookmark操作, 所以要修改push-mark,把bookmark放入
;; semantic-mru-bookmark-ring 里面, 放入后再执行semantic-mrub-switch-tags就不会出错了.
(defadvice push-mark (around semantic-mru-bookmark activate)
  "Push a mark at LOCATION with NOMSG and ACTIVATE passed to `push-mark'.
If `semantic-mru-bookmark-mode' is active, also push a tag onto
the mru bookmark stack."
  (semantic-mrub-push semantic-mru-bookmark-ring
		      (point)
		      'mark)
  ad-do-it)
;; 跳转后再跳回原来的地方
(global-set-key [f11]
		(lambda()
		  (interactive)
		  (if (ring-empty-p (oref semantic-mru-bookmark-ring ring))
		      (error "Semantic Bookmark ring is currently empty"))
		  (let* ((ring (oref semantic-mru-bookmark-ring ring))
			 (alist (semantic-mrub-ring-to-assoc-list ring))
			 (first (cdr (car alist))))
		  (if (semantic-equivalent-tag-p (oref first tag)
						 (semantic-current-tag))
		      (setq first (cdr (car (cdr alist)))))
		  (semantic-mrub-switch-tags first))))
;; 当使用外部库函数时, 下面的命令可以把外部库的头文件所在的目录告诉semantic
(semantic-add-system-include "/usr/include" 'c-mode)


;; gdb 调试
(add-hook 'gdb-mode-hook
	  (lambda ()
	    (gdb-many-windows)		;M-x gdb 后, 是多窗口显示
	    (gud-tooltip-mode)		;minor mode 当鼠标放到变量上后, 会弹出tooltip来显示变量的值
	    (local-set-key [f4] 'gdb-restore-windows) ;恢复gdb多窗口
	    (local-set-key [f5] 'gud-step)	      ;进入函数
	    (local-set-key [f6] 'gud-next)	      ;不进入函数
	    (local-set-key [f7] 'gud-finish)	      ;跳出函数
	    (local-set-key [f8] 'gud-until)))	      ;继续执行









;; -------------------------------------------------------------------------------------------------------------------
;; 配置javascript 编辑环境
(add-hook 'javascript-mode-hook 'rainbow-delimiters-mode)
(add-hook 'javascript-mode-hook 'flycheck-mode)
(add-hook 'javascript-mode-hook 'electric-pair-mode)
(add-hook 'javascript-mode-hook 'company-mode)

;; -------------------------------------------------------------------------------------------------------------------
;; 配置python 编辑环境


(defvar myPackages
  '(better-defaults
    elpy
    material-theme))
(elpy-enable)

;; python-mode 自动启用插件
(add-hook 'python-mode-hook 'rainbow-delimiters-mode) ;彩虹括号
(add-hook 'python-mode-hook 'flycheck-mode)	      ;代码查错
(add-hook 'python-mode-hook 'electric-pair-mode)      ;双括号模式
(add-hook 'python-mode-hook 'company-mode)	      ;自动补全
;(add-hook 'python-mode-hook 'electric-spacing-mode)   ;自动空格
;;(add-hook 'python-mode-hook
;;	  (lambda ()
;;	    (local-set-key (kbd "C-m") 'vi-open-next-line)))


;; -----------------------------------------------------------------------------------------------------
;; js环境配置
(add-hook 'js-mode-hook 'company-mode)
(add-hook 'js-mode-hook 'electric-pair-mode)
(add-hook 'js-mode-hook 'flycheck-mode)
(add-hook 'js-mode-hook 'rainbow-delimiters-mode)




;; -----------------------------------------------------------------------------------------------------
;; web环境配置
(add-hook 'html-mode-hook 'company-mode)
(add-hook 'html-mode-hook 'electric-pair-mode)
(add-hook 'html-mode-hook 'rainbow-delimiters-mode)
(add-hook 'html-mode-hook 'yas-minor-mode)


;; ------------------------------------------------------------------------------------------------------
;; common lisp 环境配置
;; (load (expand-file-name "/root/.quicklisp/slime-helper.el"))
;; (setq inferior-lisp-program "sbcl")
;; (add-to-list 'load-path "/usr/share/common-lisp/source/slime/")
;; (require 'slime)
;; (slime-setup)
;; (slime-setup '(slime-fancy))


;; ------------------------------------------------------------------------------------------------------
;; 全局按键绑定
;;f8就是另开一个buffer然后打开shell
(defun open-eshell-other-buffer ()
  "Open eshell in other buffer"
  (interactive)
  (split-window-vertically)
  (eshell)
  (message "open an eshell successfully :)"))

;;格式化整个文件函数
(defun indent-whole ()
  (interactive)
  (indent-region (point-min) (point-max))
  (message "format successfully :)"))

;; 当编辑完一行后, 直接跳转到下一行
(defun vi-open-next-line (arg)
  "Move to the next line (like vi) and then opens a line."
  (interactive "p")
  (end-of-line)
  (open-line arg)
  (next-line 1)
  (indent-according-to-mode))

(global-set-key (kbd "M-m") 'vi-open-next-line) ;C-m直接跳转到新行
(global-set-key [(f8)] 'open-eshell-other-buffer) ;在新buffer打开一个eshell
(global-set-key [f7] 'indent-whole)	;格式化整个文件
