import confy

cfg.verbose = off
cfg.quiet   = on
cfg.libDir  = cfg.srcDir/"lib"

build Program.new(
  src  = cfg.srcDir/"mummyd.nim",
  deps = Dependencies.new(
    submodule( "nstd",  "https://github.com/heysokam/nstd"  ),
    submodule( "webby", "https://github.com/treeform/webby" ),
    submodule( "zippy", "https://github.com/treeform/zippy" ),
    submodule( "mummy", "https://github.com/guzba/mummy"    ),
    ) # << Dependencies.new( ... )
  ) # << Program.new( ... )
