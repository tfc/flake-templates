# Flake Templates

This is my personal collection of Nix Flake templates

## Usage

First, have a look what templates are there:

```sh
$ nix flake show github:tfc/flake-templates
github:tfc/flake-templates/eb16f12b4dd35baae40dfe1a02bad16b2f243d92
├───defaultTemplate: template: A PureScript Project Template
└───templates
    └───purescript: template: A PureScript Project Template
```

Then, create a project folder and fork off your project from a template:

```sh
$ mkdir my-project && cd my-project
$ nix flake init -t github:tfc/flake-templates#purescipt
...
```

Now you can work as described by the template's welcome message.
