# Package
packageName   = "mummyd"
version       = "0.0.0"
author        = "sOkam"
description   = "HTTP dev server using Mummy"
license       = "LGPL-3.0-or-later"
srcDir        = "src"
binDir        = "bin"
bin           = @["mummyd"]
# Dependencies
requires "nim >= 2.0.2"
requires "https://github.com/guzba/mummy#head"
