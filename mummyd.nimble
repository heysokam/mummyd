from std/os import `/`
from std/strformat import `&`
# Package
packageName   = "mummyd"
version       = "0.0.0"
author        = "sOkam"
description   = "HTTP dev server using Mummy"
license       = "LGPL-3.0-or-later"
srcDir        = "src"
binDir        = "bin"
let libDir    = srcDir/"lib"
bin           = @["mummyd"]
# Dependencies
requires "nim >= 2.0.2"
proc require (name,url :string) :void=
  if not fileExists(libDir/".gitignore"): writeFile(libDir/".gitignore", "*\n!.gitignore")
  if not dirExists(libDir/name): exec &"git clone {url} {libDir/name} --depth 1"
require "zippy", "https://github.com/treeform/zippy"
require "mummy", "https://github.com/guzba/mummy"
