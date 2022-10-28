{
  description = "Personal collection of flake templates";

  outputs = { self }: {

    templates = {
      purescript = {
        path = ./purescript;
        description = "A PureScript Project Template";
        welcomeText = ''
          You just created a purescript project from the purescript template.
          You can now jump into the nix shell using `nix develop` and run
          `purs-nix compile`, `purs-nix run`, etc.
          If you are going to use javascript libraries in your purescript code,
          please first initialize a package.json using `npm init` first.
        '';
      };
    };

    defaultTemplate = self.templates.purescript;
  };
}
