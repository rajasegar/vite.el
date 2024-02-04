;;; vite.el --- An Emacs plugin to work with Vite  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Rajasegar Chandran

;; Author: Rajasegar Chandran <rajasegar.c@gmail.com>
;; Version: 1.0
;; Keywords: vite, bundler
;; URL: https://github.com/rajasegar/vite.el

;;; Commentary:

;; vite.el is an Emacs plugin to work with the Vite -
;; the next generation frontend tooling using which
;; you can create Vite projects within Emacs without
;; opening a new shell

;; Full documentation is available as an Info manual.

;;; Code:

(defvar frameworks '((:name "vanilla" :label "Vanilla"
                            :variants [(:name "vanilla-ts" :display "TypeScript")
                                       (:name "vanilla" :display "JavaScript")])
                     (:name "react" :label "React"
                            :variants [(:name "react-ts" :display "TypeScript")
                                       (:name "react-swc-ts" :display "TypeScrpt + SWC")
                                       (:name "react" :display "JavaScript")
                                       (:name "react-swc" :display "JavaScript + SWC")])
                     (:name "vue" :label "Vue"
                            :variants [(:name "vue" :display "JavaScript")
                                       (:name "vue-ts" :display "TypeScript")
                                       (:name "custom-create-vue" :display "Customize with create-vue" :custom-command "create vue@latest")
                                       (:name "custom-nuxt" :display "Nuxt ↗" :custom-commad "exec nuxi init")])
                     (:name "preact" :label "Preact"
                            :variants [(:name "preact-ts" :display "TypeScript")
                                       (:name "preact" :display "JavaScript")])
                     (:name "lit" :label "Lit"
                            :variants [(:name "lit-ts" :display "TypeScript")
                                       (:name "lit" :display "JavaScript")])
                     (:name "svelte" :label "Svelte"
                            :variants [(:name "svelte-ts" :display "TypeScript")
                                       (:name "svelte" :display "JavaScript")
                                       (:name "custom-svelte-kit" :display "SvelteKit ↗" :custom-command "create svelte@latest")])
                     (:name "solid" :label "Solid"
                            :variants [(:name "solid-ts" :display "TypeScript")
                                       (:name "solid" :display "JavaScript")])
                     (:name "qwik" :label "Qwik"
                            :variants [(:name "qwik-ts" :display "TypeScript")
                                       (:name "qwik" :display "JavaScript")
                                       (:name "custom-qwik-city" :display "QwikCity ↗" :custom-commad "create qwik@latest basic")])
                     (:name "others" :label "Others"
                            :variants [(:name "create-vite-extra" :display "create-vite-extra ↗" :custom-commad "create vite-extra@latest")
                                       (:name "create-electron-vite" :display "create-electron-vite ↗" :custom-commad "create electron-vite@latest")])))

(defvar vite/package-manager "npm")


(defun find-framework-by-name (name)
  "Find framework item by NAME."
  (car (remove-if-not (lambda (x)
                        (string-equal (plist-get x :name) name)) frameworks)))

(defun get-variant (framework variant-name)
  "Get the variant from FRAMEWORK and VARIANT-NAME."
(elt
 (remove-if-not
  (lambda (x) (equal (plist-get x :name) variant-name))
  (plist-get (find-framework-by-name framework) :variants))
0))




(defun select-framework (str pred _)
  "Callback function for `ivy-read' for frameworks list.
Argument STR display name or label for the option.
Argument PRED predicate function."
  (let* ((props (cl-mapcar (lambda (x) (plist-get x :name)) frameworks))
         (strs (cl-mapcar (lambda (x) (plist-get x :label)) frameworks)))
    (cl-mapcar (lambda (s p) (propertize s 'property p))
               strs
               props)))


(defun run-vite-command (project-name project-dir template custom-command)
  "Run create-vite command with params.
Argument PROJECT-NAME name of the project.
Argument PROJECT-DIR directory where the new project will be created.
Argument TEMPLATE name of the project template.
Argument CUSTOM-COMMAND custom command to run instead of default vite command."
  (let ((default-directory project-dir))
    (async-shell-command
     (if custom-command
         (progn
           (let ((new-dir (concat project-dir project-name)))

           (make-directory project-name project-dir)
             
           (if (equal vite/package-manager "npm")
               (format "npm %s %s" custom-command new-dir)
             (format "%s %s %s" vite/package-manager custom-command new-dir))))
       (progn
         (if (equal vite/package-manager "npm")
             (format "npm create vite %s -- --template %s" project-name template)
           (format "%s create vite %s --template %s" vite/package-manager project-name template)))))))

(defun bootstrap-project (project-name project-dir framework)
  "Select a variant.
Argument PROJECT-NAME name of the project.
Argument PROJECT-DIR directory of the new project.
Argument FRAMEWORK name of the JavaScript framework."
  (let ((variants (plist-get (find-framework-by-name framework) :variants)))
    (ivy-read "Select a variant: "
              (lambda (str pred _)
                (let* ((props (cl-mapcar (lambda (x) (plist-get x :name)) variants))
                       (strs (cl-mapcar (lambda (x) (plist-get x :display)) variants)))
                  (cl-mapcar (lambda (s p) (propertize s 'property p))
                             strs
                             props
                             )))
              :action (lambda (x)
                        (let ((variant (get-text-property 0 'property x)))
                        (run-vite-command project-name project-dir variant
                                          (plist-get (get-variant framework variant) :custom-command)))))))
;;;###autoload
(defun vite/create ()
  "Create vite."
  (let ((project-name (read-string "Project name: " "vite-project"))
        (project-dir (read-directory-name "Project directory: " "~/www")))

    ;; Select a framework
    (ivy-read "Select a framework: "
              #'select-framework
              :action (lambda (x)
                        (bootstrap-project project-name project-dir (get-text-property 0 'property x))))))


;;;###autoload
(defun vite/vite ()
  "Run vite command in current directory."
  (async-shell-command "vite"))

;;;###autoload
(defun vite/build ()
  "Run vite build command in current directory."
  (async-shell-command "vite build"))

;;;###autoload
(defun vite/optimize ()
  "Run vite optimize command in current directory."
  (async-shell-command "vite optimize"))

;;;###autoload
(defun vite/preview ()
  "Run vite preview command in current directory."
  (async-shell-command "vite preview"))

;; Local Variables:
;; coding: utf-8
;; End:
;;; vite.el ends here
