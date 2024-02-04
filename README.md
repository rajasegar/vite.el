# vite.el
An Emacs plugin to work with [Vite](https://vitejs.dev/) - the next generation frontend tooling


vite.el is an Emacs plugin to work with the Vite - the next generation frontend tooling using which you can create Vite projects within Emacs without opening a new shell


## Installation
Download the package into your Emacs directory
```
git clone https://github.com/rajasegar/vite.el.git ~/.emacs.d/elpa
```

Use `use-package` to install the package
```elisp
(use-package vite
  :load-path "elpa/vite.el/")
```

## Usage
To create new Vite projects
```elisp
(vite/create)
```

To run vite in the current project/directory
```elisp
(vite/run)
```

To run vite build in the current project/directory
```elisp
(vite/build)
```

Other functions available:
```elisp
(vite/optimize)
(vite/preview)
```
