# @section Package Info
packageName   = "mummyd"
version       = "0.0.0"
author        = "sOkam"
description   = "HTTP dev server using Mummy"
license       = "LGPL-3.0-or-later"
srcDir        = "src"
binDir        = "bin"
backend       = "c"
bin           = @["mummyd"]
skipFiles     = @["build.nim"]
skipDirs      = @["lib", "src/lib"]
# @section Dependencies
requires "nim >= 2.0.0"
requires "webby"
requires "zippy"
requires "mummy"
