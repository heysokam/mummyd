from std/os import `/`
from std/strformat import `&`
from std/strutils import join
import std/[ sets,sequtils ]
# @section Package tools
const nimBin {.strdefine.}= "../../bin/.nim/bin/nim"
var deps :HashSet[string]
var libDir :string
proc nim (opts :varargs[string,`$`]) :void=  exec nimBin&" "&opts.join(" ")
proc nimc (opts :varargs[string,`$`]) :void=
  let paths :string= "--path:" & deps.toSeq.join(" --path:")
  nim &"c --outDir:{binDir} {paths} "&opts.join(" ")
proc require (name,url :string) :void=
  deps.incl url
  if not fileExists(libDir/".gitignore"): writeFile(libDir/".gitignore", "*\n!.gitignore")
  if not dirExists(libDir/name): exec &"git clone {url} {libDir/name} --depth 1"
# @section Package Info
packageName   = "mummyd"
version       = "0.0.0"
author        = "sOkam"
description   = "HTTP dev server using Mummy"
license       = "LGPL-3.0-or-later"
srcDir        = "src"
binDir        = "bin"
libDir        = srcDir/"lib"
bin           = @["mummyd"]
# @section Dependencies
require "webby", "https://github.com/treeform/webby"
require "zippy", "https://github.com/treeform/zippy"
require "mummy", "https://github.com/guzba/mummy"
# @section Buildsystem tasks
task build, &"Build {packageName}":
  for it in bin: nimc &"{srcDir/it}"
task run, &"Build and run {packageName}":
  for it in bin: nimc &"-r {srcDir/it}"
