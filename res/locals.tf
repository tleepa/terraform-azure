locals {
  jbs = {
    "jb1" = { fnc = "jb", count_index = 1 }
  }
  vms = {
    "web1" = { os = "win", fnc = "web", count_index = 1 }
    "web2" = { os = "win", fnc = "web", count_index = 2 }
    "jnk1" = { os = "lx", fnc = "jnk", count_index = 1, size = "Standard_B2s" }
  }
}
